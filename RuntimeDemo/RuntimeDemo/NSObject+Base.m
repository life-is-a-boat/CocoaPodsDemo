//
//  NSObject+Base.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/6/13.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "NSObject+Base.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>

@implementation NSObject (Base)
//对象的name
- (NSString *)instance_name {
    return [NSString stringWithUTF8String:class_getName([self class])];
}
- (long)instance_size {
//    NSLog(@"objc对象实际分配的内存大小: %zd", malloc_size((__bridge const void *)(objc)));
//    malloc_size((__bridge const void *)self);
    return class_getInstanceSize([self class]);
}

- (NSArray *)ivarsOfClass {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    
    unsigned int methodCount = 0;
    Ivar * ivars = class_copyIvarList([self class], &methodCount);
    for (unsigned int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        NSLog(@"拥有的成员变量的类型为%s,名字为 %s",type,name);
        [list addObject:[[NSString alloc] initWithCString:name encoding:NSASCIIStringEncoding]];
    }
    free(ivars);
    
    return list;
}

- (NSArray *)propertysOfClass {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    
    unsigned int propertyCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertyList[i];
        const char *name = property_getName(property);
        const char *type = property_getAttributes(property);
        NSLog(@"拥有的属性的类型为%@,名字为 %@",[[NSString alloc] initWithCString:type encoding:NSASCIIStringEncoding],[[NSString alloc] initWithCString:name encoding:NSASCIIStringEncoding]);
        [list addObject:[[NSString alloc] initWithCString:name encoding:NSASCIIStringEncoding]];
    }
    
    return list;
}

- (NSArray *)instanceMethodList {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList([self class], &methodCount);
    for (unsigned int i = 0; i < methodCount; i ++) {
        Method method = methodList[i];
        SEL name = method_getName(method);
        const char *type = method_getTypeEncoding(method);
        NSLog(@"拥有的实例方法的类型为%@,名字为 %@",[[NSString alloc] initWithCString:type encoding:NSASCIIStringEncoding],NSStringFromSelector(name));
        [list addObject:NSStringFromSelector(name)];
    }
    return list;
}
- (NSArray *)protoclListOfClass {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    unsigned int protoclCount = 0;
    Protocol * __unsafe_unretained *protoclList = class_copyProtocolList([self class], &protoclCount);
    for (unsigned int i = 0; i < protoclCount; i ++) {
        Protocol *protocol = protoclList[i];
        [list addObject:NSStringFromProtocol(protocol)];
    }
    return list;
}


+ (NSArray *)classMethodList {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    return list;
}

@end
