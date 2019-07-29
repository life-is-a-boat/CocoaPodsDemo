//
//  ATAssert.h
//  RuntimeDemo
//
//  Created by ting on 2019/7/23.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAssert : NSObject

+ (void)assertWithCondition:(BOOL)condition withDec:(NSString *)dec;

@end

NS_ASSUME_NONNULL_END
