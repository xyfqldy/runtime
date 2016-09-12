//
//  NSObject+mt_KVO.m
//  Utilities
//
//  Created by I_MT on 16/9/11.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import "NSObject+mt_KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>
#define MTKVOClassPrefix @"MTKVO_"



static char *MTObserverKey;
static char *KvoSubClassKey;
@implementation NSObject (mt_KVO)
-(void)setKvoSubClass:(Class)kvoSubClass{
    objc_setAssociatedObject(self, KvoSubClassKey, kvoSubClass, OBJC_ASSOCIATION_RETAIN);
}
-(Class)kvoSubClass{
   return  objc_getClass(KvoSubClassKey);
}
-(void)mt_addObsever:(id)observer key:(NSString *)key andBlock:(MTObserverBlock)observerBlock{
    //1.检查对象的类中有没有响应的setter方法，如果没有抛出异常
    SEL setterSelector = NSSelectorFromString([self setterForGetter:key]);
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    NSAssert(setterMethod!=nil, @"没此key对应的IMP");
    //2.检查isa指针指向的类是不是一个KVO类。如果不是的话，新建一个继承原来类的子类，并把isa指向这个新建的子类
               Class class = object_getClass(self);
        NSString *className = NSStringFromClass(class);
   /*//通过研究，个人认为是可以如下替换的：
        NSString *className2=[MTKVOClassPrefix stringByAppendingString:key];
        Class class2 =objc_getClass(className2.UTF8String);
    if (class2) {//说明已经是KVO类了
        
    }
    */
    if (![className hasPrefix:MTKVOClassPrefix]) {
       class = [self mt_KVOClassWithOtiginalClassName:className];
//        self.kvoSubClass = class;
        object_setClass(self, class);
    }
    //到此为止，object的类已经不是原来的类了，而是kvo新建的类
    //例如，Person->MTKVOClassPrefixPerson
    
    //3.为kvo class添加setter方法的实现
    const char *types = method_getTypeEncoding(setterMethod);
    class_addMethod(class, setterSelector, (IMP)mt_setter, types);
    //4.添加观察者到观察者列表中，
    //4.1 创建观察者信息
    /**
     这里需要添加一个判断，因为不能添加多个相同属性的监听吧，否则的话，好像也没什么问题，因为每一个key对应一个block，所以虽然key有很多可以相同，结果当然需要所有的key对应的block都能被调用；问题是，移除此key的时候，应该是全部移除，不应该是移除一个就break了吧！（一会儿验证一下就知道了）
     */
    MTObserverInfo *mtObserverInfo =[[MTObserverInfo alloc]initWithObserver:self key:key callback:observerBlock];
    //4.2获取关联对象(装着所有观察者的数组)
    NSMutableArray *observers=objc_getAssociatedObject(self, MTObserverKey);
    if (!observers) {
        observers =[NSMutableArray array];
        objc_setAssociatedObject(self, MTObserverKey, observers, OBJC_ASSOCIATION_RETAIN);
    }
    [observers addObject:mtObserverInfo];
}
-(NSString *)setterForGetter:(NSString *)key{
    //name ->Name->setName
    
    //1.首字母转大写
    //关于unichar可参考：http://my.oschina.net/scanf/blog/183117
    unichar c = [key characterAtIndex:0];
    NSString *str =[key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c",c-32]];
    // 2. 最后增加set，最后增加：
    NSString *setter = [NSString stringWithFormat:@"set%@:",str];
    return setter;
}
-(NSString *)getterForSetter:(NSString *)key{
    //setName: -> Name ->name
    
    //1.去掉set
    NSRange range = [key rangeOfString:@"set"];
    NSString *subStr1 = [key substringFromIndex:range.location+range.length];
    //2.首字母转换成大写
    unichar c = [subStr1 characterAtIndex:0];
    NSString *subStr2 = [subStr1 stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c",c+32]];
    //3.去掉最后的:
    NSRange range2 = [subStr2 rangeOfString:@":"];
    NSString *getter = [subStr2 substringToIndex:range2.location];
    return getter;
}
-(Class)mt_KVOClassWithOtiginalClassName:(NSString *)className{
    //生成kvo_class的类名
    NSString *kvoClassName = [MTKVOClassPrefix stringByAppendingString:className];
    Class kvoClass = NSClassFromString(kvoClassName);
    
    //如果kvo class 已经被注册过，则直接返回
    
    if (kvoClass) {
        return kvoClass;
    }
    
    
    //如果kvoClass不存在，则创建这个类
    Class originClass = object_getClass(self);
    kvoClass = objc_allocateClassPair(originClass, kvoClassName.UTF8String, 0);
    
    
    //修改kvo class方法的实现，学习Apple的做法，隐瞒这个kvo——class
    Method classMethod = class_getInstanceMethod(kvoClass, @selector(class));
    const char *types = method_getTypeEncoding(classMethod);
    
    class_addMethod(kvoClass, @selector(class), (IMP)mt_class, types);
    
    //注册kvo_class
    objc_registerClassPair(kvoClass);
    return kvoClass;
}
/**
 *    重写setter方法，新方法在调用原方法后，通知每个观察者（调入传入的block）
 *
 */
#pragma mark MTQ:***为什么要用static方法呢？方法里面的self还可以调用实例方法吗？？？

static void mt_setter(id self,SEL _cmd,id newValue){
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = [self getterForSetter:setterName];
    if (!getterName) {
        NSLog(@"找不到getter方法");
        NSAssert(getterName!=nil, @"没有%@的get方法",getterName);
    }
    //获取旧值
      id oldValue;
    @try {
         oldValue = [self valueForKey:getterName];

    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        
    }
    //调用原来的setter方法
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    //这里需要做个类型墙转，否则会报too many arguments的错误
    ((void (*)(void *,SEL,id))objc_msgSendSuper)(&superClass,_cmd,newValue);
#pragma mark MTQ:***?????id 和void *的区别？
//参考：http://blog.csdn.net/k16643275hn/article/details/51934128
    // 为什么不能用下面方法代替上面方法?//只是编译器通过不了吧
    //    ((void (*)(id, SEL, id))objc_msgSendSuper)(self, _cmd, newValue);
    NSMutableArray *observers= objc_getAssociatedObject(self, MTObserverKey);
    for (MTObserverInfo *mtObserverInfo in observers) {
        if ([mtObserverInfo.key isEqualToString:getterName]) {
#pragma mark MTQ:***为什么是异步呢？为什么不是同步调用呢，因为同步调用的话反而更加及时
            //gcd异步调用block
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               mtObserverInfo.callback(mtObserverInfo.observer,mtObserverInfo.key,oldValue,newValue);
            });
        }
    }
    
}
/**
 *    移除监听者
 *
 *    @param observer observer
 *    @param key      keypath
 */
-(void)mt_removeObserver:(id)observer key:(NSString *)key{
    NSMutableArray *observers=objc_getAssociatedObject(self, MTObserverKey);
    for (MTObserverInfo *observerInfo in observers) {
        if ([observerInfo.observer isEqual:observer]&&[observerInfo.key isEqualToString:key]) {
           [observers removeObject:observerInfo];
           #pragma mark -----!!!这里不对！
           break;
        }
    }
}
Class mt_class(id self,SEL cmd){
    Class class = object_getClass(self);
#pragma mark MTQ:***?????为什么这里就不能用superclass呢？找不到呢？
    /*
    NSLog(@"%@",vc.superclass.superclass);
    Class superClass =class.superclass;
    */
    Class superClass = class_getSuperclass(class);
    return superClass;
}

@end
@implementation MTObserverInfo

-(instancetype)initWithObserver:(id)observer key:(NSString *)key callback:(MTObserverBlock)callback{
    MTObserverInfo *observerInfo =[[MTObserverInfo alloc]init];
    observerInfo.observer = observer;
    observerInfo.key =key;
    observerInfo.callback = callback;
    return observerInfo;
}

@end