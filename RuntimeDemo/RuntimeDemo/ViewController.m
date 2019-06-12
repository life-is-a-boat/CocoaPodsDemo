//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/4/9.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self method1];

    [self methodExchange];
    
    [self method1];
}

- (void) methodExchange {
    Method method1 = class_getInstanceMethod([self class], @selector(method1));
    Method method2 = class_getInstanceMethod([self class], @selector(method2));
    
    //交换method1 和 method2 的IMP指针
    method_exchangeImplementations(method1, method2);
}
- (void) method1 {
    printf("%s \n",__func__);
}

- (void)method2 {
    printf("%s \n",__func__);
}


@end
