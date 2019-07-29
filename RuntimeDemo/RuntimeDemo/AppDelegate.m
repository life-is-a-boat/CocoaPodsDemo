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
    
    
    NSString *command_data = @"03C80001FFFCFFFD00201907241744090000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB1FF9FFFF124DFFFF1964FFFF03E8FFFFFFFF00004000FFFFFFFFFFFFFFFFFFFFFFFF01FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF030CFFFF7b00220063006f006d00700061006e0079004e0061006d00650022003a002200e451f0513a673a5722002c0022006e0075006d0062006500720022003a002200360039003200320032003600360034003500300033003600350022002c0022007200650063006500690070007400410064006400720022003a0022006c6552910d4e03540354219e22002c002200700072006f0064007500630065004e0061006d00650022003a0022007d59e051b65b22002c00220075007300650072004900640022003a00220031003200330022002c002200730065006e006400410064006400720022003a0022000354219e0d4e9d5b1d8d22002c002200630072006500610074006f00720022003a0022001a810e54df8d22002c002200720065006d00610072006b0022003a002200bf8be0605a80315531554c6b696de5541a521a5222002c002200570061007900620069006c006c00540069006d00650022003a00220032003000310039002d00300037002d00310037002000320033003a003100300022007d00";
//    int command_length = 114;
//    int command_count = Int(ceil(Double(command_data.length)/Double(command_length)));
//    command_index = 0
    
    
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
