//
//  GlobalFunction.h
//  RuntimePractice
//
//  Created by I_MT on 16/9/8.
//  Copyright © 2016年 I_MT. All rights reserved.
//
#import <objc/runtime.h>
#ifndef GlobalFunction_h
#define GlobalFunction_h
/**
 *    link:http://my.oschina.net/zhxx/blog/725906
 *    一般情况下，类别里的方法会重写掉主类里相同命名的方法。如果有两个类别实现了相同命名的方法，只有一个方法会被调用。但 +load: 是个特例，当一个类被读到内存的时候， runtime 会给这个类及它的每一个类别都发送一个 +load: 消息。
 */
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
    
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark ---------------------------------------------------------------------------

/**
 *    其实，这里还可以更简化点：直接用新的 IMP 取代原 IMP ，而不是替换。只需要有全局的函数指针指向原 IMP 就可以。
 *   这个做法的主要不同在于，不会修改新加的方法的实现，那么在新的方法里如果调用自身的话就会造成循环咯！
 *   @mark    记住要区分各个的不同，才更明白什么时候改选用哪个！
 *   @eg      个人猜想：是不是说，我们就可以即修改了我们想要的方法，又可以继续调用自己的父类方法咯，那么上一中呢，不可以吗？  。。。。好像也可以哦。。。。
 */

#pragma mark -----注意这里是 函数指针，前面需要*号！！！
#pragma mark MTQ:***?????参数类型不一定是bool，可能是多个呢？

void (* gOriginalViewDidAppear)(id, SEL  , BOOL);//声明的时候当然要加*了，用的时候可以不加，因为方法名本身就是方法起始地址咯

void newViewDidAppear(id self, SEL _cmd, BOOL animated)
{
    // call original implementation
    gOriginalViewDidAppear(self, _cmd, animated);
    
   //do  something
   
}

void methodMapNewImp(Class class,SEL originalselctor,IMP newImp)

{
    //如果自己类没有的话，返回的是父类的方法，切记
    Method originalMethod = class_getInstanceMethod(class,originalselctor);
    gOriginalViewDidAppear = (void *) method_getImplementation(originalMethod);
    //如果该类中就有这个方法的话，就直接调换这个方法的imp
//   (IMP) newViewDidAppear//本身就是IMP，函数指针咯
    if(!class_addMethod(class, originalselctor, newImp, method_getTypeEncoding(originalMethod))) {
        method_setImplementation(originalMethod, newImp);
    }else{//如果这个类中没有这个方法的话，那么添加是会成功的，添加成功，这样就避免了更换了其父类方法实现的情况
    //1.可以再获取一次本类的方法，再替换IMP
//        Method originalMethod = class_getInstanceMethod(class,originalselctor);
    //2.
#pragma mark MTQ:***?????如果通过IMP获取这个字符串集呢？也就是方法的编写类型？
//其实这里已经有了这个方法，当然就不会用到这个方法类型了，还有就是原方法类型肯定是和现在方法的类型一样的呀（目前还没有不一样的地方！）
        /**  来自苹果官方文档  下面的方法，分两步走的！
         *   This function behaves in two different ways:
         
         If the method identified by name does not yet exist, it is added as if class_addMethod were called. The type encoding specified by types is used as given.
         
         If the method identified by name does exist, its IMP is replaced as if method_setImplementation were called. The type encoding specified by types is ignored.
         */
        class_replaceMethod(class,
                            originalselctor,
                            newImp,
                            method_getTypeEncoding(originalMethod));//？？？字符集
    }
}



#endif /* GlobalFunction_h */
