//
//  Person.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/7/8.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSString *)checkoutPerson {
    if (_name != nil) {
        return _name;
    }
    return @"null";
}

- (void)initPersonwithName:(NSString *)name
                       age:(NSInteger)age
                   address:(NSString *)address
                  passport:(NSString *)passport {
    _name = name;
    _age = age;
    _address = address;
    _passport = passport;
}

- (void)updatePerson:(NSString *)name {
    _name = name;
    NSLog(@"-----------------------:%@",name);
}

@end
