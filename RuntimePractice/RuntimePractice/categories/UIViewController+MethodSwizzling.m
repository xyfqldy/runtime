//
//  UIViewController+MethodSwizzling.m
//  RuntimePractice
//
//  Created by I_MT on 16/9/7.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import "UIViewController+MethodSwizzling.h"
#import <objc/runtime.h>

@implementation UIViewController (MethodSwizzling)
/**
 *    link ：http://nshipster.com/method-swizzling/
 *    @1  为什么用load方法：
 *    +load is sent when the class is initially loaded, while +initialize is called just before the application calls its first method on that class or an instance of that class
 
 *    +load is guaranteed to be loaded during class initialization, which provides a modicum of consistency for changing system-wide behavior. By contrast, +initialize provides no such guarantee of when it will be executed—in fact, it may never be called, if that class is never messaged directly by the app.
 *
 *    @2
 *
 *    @since 1.0
 */

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        
        swizzleMethod(class,originalSelector,swizzledSelector);
        
        
        SEL org_sel_viewdidload = @selector(viewDidLoad);
        SEL new_sel_viewdidload = @selector(xxx_viewDidload);
        Method new_method_viewdidload = class_getInstanceMethod(self, new_sel_viewdidload);
        IMP new_imp_viewdidload = method_getImplementation(new_method_viewdidload);
        methodMapNewImp(self, org_sel_viewdidload, new_imp_viewdidload);
//        sel
 /*
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        */
    });
}

#pragma mark - Method Swizzling

- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
#pragma mark MTQ:***?????

//    self.view.backgroundColor=[UIColor whiteColor];
    NSLog(@"viewWillAppear: %@", self);
    if (self.navigationController) {//修改rightButtonItem
    
        UIBarButtonItem *rightItem = self.navigationItem.rightBarButtonItem ;
        rightItem.image = [UIImage imageNamed:@"rightItem"];
        SEL sel = NSSelectorFromString(@"rightItemAction");
        if (sel) {
            rightItem.action=sel;
            rightItem.target =self;
        }
        
    }
    
}
-(void)xxx_viewDidload{
    
}
@end
