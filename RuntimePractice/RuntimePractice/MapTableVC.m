//
//  MapTableVC.m
//  RuntimePractice
//
//  Created by I_MT on 16/9/15.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import "MapTableVC.h"

@interface Person : NSObject<NSCopying>
@property (nonatomic,copy)NSString *name;
@end
@implementation Person

-(void)dealloc{
    
}
-(id)copyWithZone:(NSZone *)zone{
    
    Person *p=[[Person allocWithZone:zone]init];
    p.name=_name;
    return p;
}

@end

@interface Dog  : NSObject
@property (nonatomic,copy)NSString *name;
@end
@implementation Dog

-(void)dealloc{
    
}

@end
@interface NSMapTable  (keyForObj)

@end
@implementation NSMapTable(keyForObj)

-(id)keyForObj:(id)object{
    NSEnumerator *enumerator=[self keyEnumerator];
    id  key;
    while (key=[enumerator nextObject]) {
    id value = [self objectForKey:key];
        if ([value isEqual:object]) {
            return key;
        }
    }
    return nil;
}
- (nullable id)objectForKeyedSubscript:(id<NSCopying>)key{
    return [self objectForKey:key];
} // 取值
- (void)setObject:(nullable id)obj forKeyedSubscript:(id <NSCopying>)key{
    [self setObject:[self objectForKey:key] forKeyedSubscript:key];
} // 设值

@end

@interface MapTableVC ()

@end

@implementation MapTableVC
{
    NSMapTable *mapTabel;
    Person *susan;
//     NSString *string1;
    Dog *xiaohei;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hashTabel];
}
/**
 *    总结一下啊
        1.key是person类型，强引用，value是dog类型，弱引用，dog销毁，就全部从maptable中移除
        2.key是person类型，强引用，value是string类型，弱音容，string可能是copy的原因，在原string销毁的时候，并没有将该条从maptable中销毁
        3.key是string，强引用，value是person弱引用，preson销毁的时候，从maptable中移除
        4.key是string 强，value也是string 弱，除了作用域并没有销毁掉
        5.即便是key，value都是弱引用的string，出了作用域也还是不会从maptable中移除
        6.要防止不被移除的话，必须key和value都不能被销毁，作为string类型，都会重新copy出来一份儿，所以copy出来的不会销毁，而对于其他的对象的话，必须要保证key和value都不被销毁才行！
 */
-(void)hashTabel{
    NSHashTable *hashTable =[NSHashTable hashTableWithOptions:NSHashTableObjectPointerPersonality];
    NSInteger index1= 1;
    NSString *string1=@"123";
    NSString *string2=@"456";
   susan=[[Person alloc]init];
    susan.name=@"susan";
    xiaohei =[[Dog alloc]init];
    xiaohei.name=@"xiaohei";
    mapTabel=[NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory];
    [mapTabel setObject:xiaohei forKey:susan];
//    NSDictionary *dic=mapTabel.dictionaryRepresentation;
//    NSLog(@"%@",dic);
    NSLog(@"%@",[mapTabel objectForKey:susan]);
    
//    NSMutableDictionary *muDic=[NSMutableDictionary dictionary];
    NSPointerFunctions *keyOption=mapTabel.keyPointerFunctions;
    NSPointerFunctions *valueOption =mapTabel.valuePointerFunctions;
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%lu", (unsigned long)mapTabel.count);
    NSLog(@"%@",mapTabel);
    NSEnumerator *enumerator = [mapTabel keyEnumerator];
    
    id person =[mapTabel keyForObj:xiaohei];
    NSLog(@"%@",person);
    NSLog(@"%@",mapTabel[susan]);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
