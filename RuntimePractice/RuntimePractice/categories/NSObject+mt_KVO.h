//
//  NSObject+mt_KVO.h
//  Utilities
//
//  Created by I_MT on 16/9/11.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *    讨论一下，为什么非得用创建一个新类的思路来实现KVO呢？
 *
 *    如果用方法替换呢，可行吗？比如在添加观察者的时候进行判断，
 
 *    如何实现集合类型的KVO呢？？？或者说，如果某个属性不是通过setter方法进行更改value的话那样岂不是不适用了！
 *   
 *    还有一个问题是，这种实现监听的是完全独立于apple自带的监听方法的，所以不会进入observer valueforkey方法
 
 *      runtime创建的对象的生命周期？呢？
 */

typedef void(^MTObserverBlock)(id observer,NSString *key,id oldValue,id newValue);

@interface MTObserverInfo : NSObject


/** 监听者 */
@property (nonatomic, weak) id observer;

/** 监听的属性 */
@property (nonatomic, copy) NSString *key;

/** 回调的block */
@property (nonatomic, copy) MTObserverBlock callback;

- (instancetype)initWithObserver:(id)observer key:(NSString *)key callback:(MTObserverBlock)callback;


@end



@interface NSObject (mt_KVO)
@property(nonatomic,weak)Class kvoSubClass;
-(void)mt_addObsever:(id)observer key:(NSString *)key andBlock:(MTObserverBlock)observerBlock;
-(void)mt_removeObserver:(id)observer key:(NSString *)key;
@end
