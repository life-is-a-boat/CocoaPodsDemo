//
//  NSObject+Swizzling.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/6/4.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzling)

//方法替代
+ (void)methodSwizzlingWithOriginalSelector:(SEL)originSelector bySwizzlingSelector:(SEL)swizzlingSelector {
    /**
        1.判断originSelector是否实现
        2.如果originSelector实现
     */
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originSelector);
    Method swizzlingMethod = class_getInstanceMethod(class, swizzlingSelector);
    /**
        这里为源SEL添加IMP是为了避免源SEL没有实现IMP的情况。若添加成功则说明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP；若添加失败则说明源SEL已经有IMP了，直接将两个SEL的IMP交换就可以了。
        class_addMethod:实现会覆盖父类的方法实现。但不会取代本类中已存在的实现，如果本类中包含一个同名的实现，则函数返回NO。
        class_replaceMethod:该函数的行为可以分为两种：如果类中不存在name指定的方法，则类似于clss_addMethod函数一样会添加方法；如果类中已存在name指定的方法，则类似于method_setImplementation一样代替原方法的实现。
     method_exchangeImplementations:交换method对应的imp 指针地址
     */
    BOOL didAddMethod = class_addMethod(class, originSelector, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    if (didAddMethod) { //判断 swizzlingSelector 是否实现，如果没有 则添加
        class_replaceMethod(class, swizzlingSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
}

+ (IMP)methodSwizzlingWithSelector:(SEL)selector withClass:(Class)objClass {
    
    return nil;
}


@end
