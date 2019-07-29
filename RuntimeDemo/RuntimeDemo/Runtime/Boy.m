//
//  Boy.m
//  RuntimeDemo
//
//  Created by ting on 2019/7/24.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "Boy.h"

@implementation Boy
@synthesize name = _name;

- (void)setName:(NSString *)name {
    name = [name stringByAppendingString:@"is a  Boy!!!"];
    [super setName:name];
}

@end
