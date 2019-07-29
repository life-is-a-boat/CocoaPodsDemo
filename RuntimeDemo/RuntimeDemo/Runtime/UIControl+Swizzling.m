//
//  UIControl+Swizzling.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/7/9.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "UIControl+Swizzling.h"
#import <objc/runtime.h>

@implementation UIControl (Swizzling)

- (void)setDelayTime:(NSTimeInterval)delayTime {
    objc_setAssociatedObject(self, "delayTime", @(delayTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval) delayTime {
    return [objc_getAssociatedObject(self, "delayTime") doubleValue];
}

+ (void)load {
    Method method = class_getInstanceMethod([self class], @selector(sendAction:to:forEvent:));
    Method swizzling_method = class_getInstanceMethod([self class], @selector(swizzling_sendAction:withTarget:withEvent:));
    method_exchangeImplementations(method, swizzling_method); //交换方法
    printf("----------%s----------",__func__);
}

- (void)swizzling_sendAction:(SEL)sel withTarget:(id)target withEvent:(UIEvent *)event {
    //先执行一部分自定义操作
    self.userInteractionEnabled = false;
    if (self.delayTime > 0) {
        [NSThread sleepForTimeInterval:self.delayTime];
    }
    self.userInteractionEnabled = true;
//    sleep(<#unsigned int#>)
    //执行操作事件
    [self sendAction:sel to:target forEvent:event];
}

//手动释放对象
- (void)dealloc {
    NSLog(@"%s",__func__);
    NSLog(@"%lf",self.delayTime);
    self.delayTime = 0;
}
@end
