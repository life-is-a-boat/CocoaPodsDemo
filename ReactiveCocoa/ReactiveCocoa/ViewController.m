//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by mac on 2017/2/15.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self signal];
    [self subject];
    [self replaySubject];
}

-(void)signal {

    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        //3.发送信号
        [subscriber sendNext:@1];

        return [RACDisposable disposableWithBlock:^{
            NSLog(@"默认信号发送完毕被取消！");
        }];

    }];

    //2.订阅信号
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"接收 --- %@",x);
    }];

    [disposable dispose];
}

//RACSubject:信号提供者，自己可以充当信号  又能发送信号
-(void)subject {
    //创建信号
    RACSubject *subject = [RACSubject subject];

    //订阅信号
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅者---%@",x);
    }];

    //
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅者二---%@",x);
    }];

    //发送信号
    [subject sendNext:@"111"];
}

//
-(void)replaySubject {
    //
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
