//
//  Person.h
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/7/8.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *passport;

- (void)initPersonwithName:(NSString *)name
                       age:(NSInteger)age
                   address:(NSString *)address
                  passport:(NSString *)passport;

+ (id)initPersonwithName:(NSString *)name
                     age:(NSInteger)age
                 address:(NSString *)address
                passport:(NSString *)passport;

- (void)updatePerson:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
