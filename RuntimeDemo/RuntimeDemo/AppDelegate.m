//
//  AppDelegate.m
//  RuntimeDemo
//
//  Created by 刘兵 on 2019/4/9.
//  Copyright © 2019 刘兵. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+UTF.h"
#import "NSData+UTF.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
//    NSDictionary *dict =  [[NSDictionary alloc] initWithDictionary:@{
//                                                                     @"companyName":@"天翼商务科技有限公司",
//                                                                     @"creator":@"无名氏",
//                                                                     @"WaybillTime":@"无名氏",
//                                                                     @"userId":@"无名氏",
//                                                                     @"number":@"无名氏",
//                                                                     @"produceName":@"无名氏",
//                                                                     @"sendAddr":@"无名氏",
//                                                                     @"receiptAddr":@"无名氏",
//                                                                     @"remark":@"无名氏"
//                                                                     }];
    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:nil];
//
//    NSString *jsonStr = [data hexString];
//
//    NSString *utfStr = [jsonStr convertWithUTF8ToHexStr];

//    NSError *error ;
//    NSData *utfData = [utfStr dataUsingEncoding:NSUTF8StringEncoding];//[NSJSONSerialization dataWithJSONObject:utfStr options:NSJSONWritingPrettyPrinted error:&error];
//    if (error) {
//        printf("%@",error.localizedDescription);
//    }
//
//    NSString *dataStr = [utfData convertDataToHexStr];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
