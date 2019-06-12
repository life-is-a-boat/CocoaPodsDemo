//
//  NSObject+Swizzling.h
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/6/4.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Swizzling)

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originSelector bySwizzlingSelector:(SEL)swizzlingSelector;

+ (IMP)methodSwizzlingWithSelector:(SEL)selector withClass:(Class)objClass;

@end

NS_ASSUME_NONNULL_END
