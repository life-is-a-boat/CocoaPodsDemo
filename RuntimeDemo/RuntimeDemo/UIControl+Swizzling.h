//
//  UIControl+Swizzling.h
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/7/9.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (Swizzling)

@property (nonatomic, assign) NSTimeInterval  delayTime;

@end

NS_ASSUME_NONNULL_END
