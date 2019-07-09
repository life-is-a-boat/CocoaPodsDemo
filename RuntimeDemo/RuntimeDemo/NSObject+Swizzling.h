//
//  NSObject+Swizzling.h
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/6/4.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Swizzling)

#pragma mark - swzilling
//添加属性
//- (void)addProperty:(NSString *)propertyName withValue:(id)value withType:(id)type withPolicy:(objc_AssociationPolicy)policy;

//交换
+ (void)methodSwizzlingWithOriginalSelector:(SEL)originSelector bySwizzlingSelector:(SEL)swizzlingSelector;

//动态添加方法
+ (void)addInstanceMethodSwizzlingWithSelector:(SEL)selector withImplementationClass:(Class)implementClass;


#pragma mark - tool
+ (IMP)impSwizzlingWithSelector:(SEL)selector withClass:(Class)objClass;

+ (IMP)impSwizzlingWithSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
