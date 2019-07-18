//
//  NSString+UTF.m
//  RuntimeDemo
//
//  Created by ting on 2019/7/18.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "NSString+UTF.h"

@implementation NSString (UTF)

- (NSString *)convertWithUTF8ToHexStr {
    NSString *string = self;
    NSInteger length = string.length;
    Byte dst[length << 1];
    int data;
    for (int i = 0; i < length; i ++) {
        data = (int) ([string characterAtIndex:i]);
        int j = i << 1;
        dst[j] = (Byte) (data & 0xff);
        dst[j + 1] = (Byte) ((data >> 8) & 0xff);
    }
    NSMutableString *mustr = [NSMutableString string];
    for (int i = 0 ; i < length * 2; i ++) {
        NSString *hexStr = [NSString stringWithFormat:@"%x", (dst[i]) & 0xff];
        if ([hexStr length] == 2) {
            [mustr appendString:hexStr];
        } else {
            [mustr appendFormat:@"0%@", hexStr];
        }
    }
    return mustr;
}

//- (NSString *)convertUTFStrToStr {
//
//}


@end
