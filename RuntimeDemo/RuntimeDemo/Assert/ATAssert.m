//
//  ATAssert.m
//  RuntimeDemo
//
//  Created by ting on 2019/7/23.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "ATAssert.h"

@implementation ATAssert

+ (void)assertWithCondition:(BOOL)condition withDec:(NSString *)dec {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:205 userInfo:@{@"error":dec}];
    
}
@end
