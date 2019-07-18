//
//  NSData+UTF.h
//  RuntimeDemo
//
//  Created by ting on 2019/7/18.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (UTF)
- (NSString *)convertDataToHexStr;
- (NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
