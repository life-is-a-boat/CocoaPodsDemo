//
//  NSObject+Base.h
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/6/13.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Base)
//成员变量列表
- (NSArray *)ivarsOfClass;

//属性列表
- (NSArray *)propertysOfClass;

//实例方法
- (NSArray *)instanceMethodList;

//对象的size
- (long)instance_size;

//对象的name
- (NSString *)instance_name;

@end

NS_ASSUME_NONNULL_END
