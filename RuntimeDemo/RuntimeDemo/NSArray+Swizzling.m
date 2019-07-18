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
// Swizzling核心代码
+ (void)load {
    Method method = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
    Method swzilling_method = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(swzilling_objectAtIndex:));
    method_exchangeImplementations(method, swzilling_method);
    
//    Method oldObjectAtIndex1 = class_getInstanceMethod(objc_getClass("__NSArrayI"),@selector(objectAtIndexedSubscript:));
//    Method newObjectAtIndex1 = class_getInstanceMethod(objc_getClass("__NSArrayI"),@selector(safeobjectAtIndexedSubscript:));
//    method_exchangeImplementations(oldObjectAtIndex1, newObjectAtIndex1);
}

//防止数组越界崩溃
- (instancetype)safeobjectAtIndexedSubscript:(NSUInteger)index{
    if(index > (self.count-1)) {// 数组越界
        return nil;
    }else{// 没有越界
        return [self safeobjectAtIndexedSubscript:index];
    }
}

- (id)swzilling_objectAtIndex:(NSUInteger)index {
    //判断下标是否越界，如果越界就进入异常拦截
    if ((self.count == 0) ||( self.count - 1 < index)) {
        NSLog(@"%s:数组越界了！！！",__func__);
        @try {
            return [self swzilling_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }
    else {//如果没有问题，则正常进行方法调用
        return [self swzilling_objectAtIndex:index];
    }
}
@end
