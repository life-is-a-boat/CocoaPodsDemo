//
//  NSArray+Swizzling.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/7/10.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "NSArray+Swizzling.h"
#import <objc/runtime.h>

@implementation NSArray (Swizzling)

/*
 类簇
 __NSPlaceholderArray
 __NSSingleObjectArrayI
 __NSArrayI
 __NSArray0
 __NSArrayM
 
 重点：这里要千万注意，获取数组中的数据有两种方法，一种是[array objectAtIndex:1000]，另一种是arr[1000]，但是千万不要以为这两种方式调用的方法都是一样的（被坑过/(ㄒoㄒ)/~~），arr[1000]的调用方法是objectAtIndexedSubscript:，所以也要针对这个方法处理。
 
 load和initialize方法内部使用了锁，因此它们是线程安全的。实现时要尽可能保持简单，避免阻塞线程，不要再使用锁。

 参考:http://www.manongjc.com/article/56380.html
 */
// Swizzling核心代码
+ (void)load {
    //__NSArrayI
    Method method = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
    Method swzilling_method = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(swizzilling_objectAtIndex:));
    method_exchangeImplementations(method, swzilling_method);
    
    Method subscript_method = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:));
    Method subscript_swzilling_method = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(swizzling_objectAtIndexedSubscript:));
    method_exchangeImplementations(subscript_method, subscript_swzilling_method);

    //__NSArray0
    Method array0_method = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:));
    Method array0_swzilling_method = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(swizzilling_array0_objectAtIndex:));
    method_exchangeImplementations(array0_method, array0_swzilling_method);
    
    Method array0_subscript_method = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:));
    Method array0_subscript_swzilling_method = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(swizzilling_array0_objectAtIndexedSubscript:));
    method_exchangeImplementations(array0_subscript_method, array0_subscript_swzilling_method);
    
    //__NSSingleObjectArrayI
    Method single_method = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:));
    Method single_swizzilling_method = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(swizzilling_single_objectAtIndexedSubscript:));
    method_exchangeImplementations(single_method, single_swizzilling_method);
    Method single_subscript_method = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:));
    Method single_subscript_swizzilling_method = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(swizzilling_single_objectAtIndex:));
    method_exchangeImplementations(single_subscript_method, single_subscript_swizzilling_method);
    
    printf("----------%s----------",__func__);
}

//防止数组越界崩溃
//- (id)swizzilling_single_objectAtIndex:(NSUInteger)index
//- (id)swizzilling_single_objectAtIndexedSubscript:(NSUInteger)index
- (id)swizzilling_array0_objectAtIndex:(NSUInteger)index {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swizzilling_array0_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swizzilling_array0_objectAtIndex:index];
    }
}
- (id)swizzilling_array0_objectAtIndexedSubscript:(NSUInteger)index {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swizzilling_array0_objectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swizzilling_array0_objectAtIndexedSubscript:index];
    }
}

- (id)swizzilling_single_objectAtIndex:(NSUInteger)index {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swizzilling_single_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swizzilling_single_objectAtIndex:index];
    }
}
- (id)swizzilling_single_objectAtIndexedSubscript:(NSUInteger)index  {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swizzilling_single_objectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swizzilling_single_objectAtIndexedSubscript:index];
    }
}

- (id)swizzilling_objectAtIndex:(NSUInteger)index {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swizzilling_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swizzilling_objectAtIndex:index];
    }
}

- (id)swizzling_objectAtIndexedSubscript:(NSUInteger)index {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swizzling_objectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swizzling_objectAtIndexedSubscript:index];
    }
}


@end
