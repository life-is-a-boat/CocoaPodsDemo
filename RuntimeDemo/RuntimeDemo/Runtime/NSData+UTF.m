//
//  NSData+UTF.m
//  RuntimeDemo
//
//  Created by ting on 2019/7/18.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "NSData+UTF.h"

@implementation NSData (UTF)

- (NSString *)convertDataToHexStr{
    if (!self || [self length] == 0) {
        return @"";
    }

    char *data_bytes = (char *)[self bytes];
    int length = self.length;
    char *srcChar[(length >> 1)];

    for(int i=0;i<(length >> 1);i++) {
        printf("testByte = %d\n",data_bytes[i]);
        srcChar[i] = ((data_bytes[(i << 1)] & 0xff) << 8) + ((data_bytes[(i << 1) + 1] & 0xff) << 8);
    }
    
    NSString *json = [[NSString alloc] initWithCString:srcChar encoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[self length]];
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        unsigned char *temp_dataBytes = (unsigned char*)bytes;
        int data ;
        for (int i = 0; i < byteRange.length; i++) {
            data = (int) (dataBytes[i]);
            int j = i << 1;
            temp_dataBytes[j] = (Byte) (data & 0xff);
            temp_dataBytes[j + 1] = (Byte) ((data >> 8) & 0xff);
            NSString *hexStr = [NSString stringWithFormat:@"%x", (temp_dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

- (NSString *)hexString {
    NSString *jsonStr = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return jsonStr;
}

@end
