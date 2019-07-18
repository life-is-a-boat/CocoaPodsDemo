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
    /*
     获取一个类的属性列表
     class_copyPropertyList(Class  _Nullable __unsafe_unretained cls, unsigned int * _Nullable outCount)
     入参 cls ：一个类class 对象 用于统计属性数量的整形数的地址
     入参 outCount： 用于记录一个类属性的个数
     返回值 objc_property_t * ：一个属性列表数组
     */
    objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertyList[i];
        //获取单个属性的名字
        const char *property_name = property_getName(property);
        //获取单个属性的所有描述
        const char *property_type = property_getAttributes(property);
        //获取单个属性的值
        const char *value = property_copyAttributeValue(property, property_name);
        printf("\n");
        printf("拥有的属性的类型为%p,名字为 %p,值为 %s",[[NSString alloc] initWithCString:property_type encoding:NSASCIIStringEncoding],[[NSString alloc] initWithCString:property_name encoding:NSASCIIStringEncoding],value);
        
        [list addObject:[[NSString alloc] initWithCString:property_name encoding:NSASCIIStringEncoding]];
        
        
        /*
         获取一个属性所有描述的分组值
         att.name
         T :表示属性的类型 为基本对象类型和基本数据类型，基本对象类型的value为该对象类型名字 如NSArray、NSString、NSMutableDictionary 等；
            基本类型中： Bool为B、 NSInteger 为q、int为i、unsigned int为I、float为f、double为d、long也是q、Point为{Point=ss}、Rect为{Rect=ssss} 等等
         C : 表示该属性为copy
         W : 表示属性为weak
         & :为&表示属性为strong
         空: 表示属性为assgin
         N : 表示为非原子属性 
         V :表示属性的名字
         R :表示只读属性readonly
         G :表示设置getter方法
         */
        unsigned int attCount = 0;
        objc_property_attribute_t *attList = property_copyAttributeList(property, &attCount);
        for (unsigned int j = 0; j < attCount; j ++) {
            objc_property_attribute_t att = attList[j];
            const char * name = att.name;
            const char * value = att.value;
            printf("%s 属性的名字是 %s 值是:%s",property_name,name,value);
        }
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
