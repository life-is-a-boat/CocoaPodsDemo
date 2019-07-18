//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/4/9.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "NSObject+Base.h"
#import "NSObject+Swizzling.h"
#import "NSArray+Swizzling.h"

#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.temp_lable.text = @"345uiop[fghj";
    self.temp_lable.font = [UIFont fontWithName:@"PingFang SC Bold" size:15];

//    printf("%c",[self.temp_lable instanceMethodList]);
//    printf("%c",self.temp_lable.ivarsOfClass);
    
    [self method1];

    [self methodExchange];
    
    [self method1];
    
//    NSLog(@"------:%@",[ViewController cla])
    Person *p = [[Person alloc] init];
    for (NSString *value in [p propertysOfClass]) {
        NSLog(@"00000:%@",value);
    }
    p.name = @"at";
    [Person addInstanceMethodSwizzlingWithSelector:@selector(updatePerson:) withImplementationClass:[ViewController class]];
//    class_addMethod([Person class], @selector(updatePerson:), class_getMethodImplementation([ViewController class], @selector(updatePerson:)), "v@:");
    [p performSelector:@selector(updatePerson:) withObject:nil];
    
    [Person addInstanceMethodSwizzlingWithSelector:@selector(nihao) withImplementationClass:[ViewController class]];
    [p performSelector:@selector(nihao)];
    
    
    
//    NSArray *array = [NSArray array];
    /*
     <__NSArrayI 0x60000092d9e0>(
     NSString,
     {(
     )}
     )
     */
//    2019-07-11 01:44:32.335961+0800 RuntimeDemo[29921:2203624] *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArray0 objectAtIndex:]: index 4 beyond bounds for empty NSArray'
    NSArray *array = [[NSArray alloc] initWithObjects:@1, nil];
//    NSArray *array = @[@0, @1];
    NSLog(@"%@",[array objectAtIndex:4]);
    NSLog(@"%@",array[2]);
}

- (void) methodExchange {
//    Method method1 = class_getInstanceMethod([self class], @selector(method1));
//    Method method2 = class_getInstanceMethod([self class], @selector(method2));
//
//    //交换method1 和 method2 的IMP指针
//    method_exchangeImplementations(method1, method2);
    NSLog(@"----1:%p-----2:%p",[ViewController methodForSelector:@selector(method1)],[ViewController impSwizzlingWithSelector:@selector(method1)]);
    [ViewController methodSwizzlingWithOriginalSelector:@selector(method1) bySwizzlingSelector:@selector(method2)];
}
//-[ViewController method1]
//2019-07-08 00:03:33.129012+0800 RuntimeDemo[11957:1602695] ----1:0x10dccb2c0-----2:0x10d3dcfc0
//-[ViewController method2]
- (void) method1 {
    printf("%s \n",__func__);
}

- (void)method2 {
    printf("%s \n",__func__);
}


- (void)personDetail {
    NSLog(@"name:%@",[self valueForKey:@"name"]);
}

- (void)updatePerson:(NSString *)name {
    NSLog(@"000000000000000000000000000");
}

- (void)nihao {
    NSLog(@"1111111111111");
}
@end
