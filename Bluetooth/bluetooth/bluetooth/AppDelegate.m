//
//  AppDelegate.m
//  bluetooth
//
//  Created by mac on 16/6/14.
//  Copyright © 2016年 mac. All rights reserved.
//

#define TRANSFER_SERVICE_UUID           @"459DB335-56D0-8B73-2DD5-1FADE5021B8B"
#define TRANSFER_CHARACTERISTIC_UUID    @"FF0F"

#define kLocalNotificationKey @"kLocalNotificationKey"
#define kNotificationCategoryIdentifile @"kNotificationCategoryIdentifile"
#define kNotificationActionIdentifileStar @"kNotificationActionIdentifileStar"
#define kNotificationActionIdentifileComment @"kNotificationActionIdentifileComment"

#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<CBCentralManagerDelegate,CBPeripheralDelegate,CLLocationManagerDelegate>
{
    CBCentralManager *manager; //系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    NSMutableArray *peripherals; //用于保存被发现设备
    CBPeripheral    *currentPeripheral;
    CBCharacteristic    *currentCharacteristic;

}

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) NSTimer   *timer;

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@property (nonatomic, strong) CLLocationManager *locationmanager;
@property (nonatomic, strong) NSArray   *beaconArr;
@property (nonatomic, strong) CLBeaconRegion    *beacon1;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

//    manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
//    peripherals = [[NSMutableArray alloc] initWithCapacity:0];
//
//    [self initAPNSNotification:launchOptions];


//    self.beaconArr = [[NSArray alloc] init];
//
//    self.locationmanager = [[CLLocationManager alloc] init];//初始化
//
//    self.locationmanager.delegate = self;
//
//    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许


    return YES;
}

#pragma mark - localtion
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"___%s___",__func__);

    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.beacon1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:TRANSFER_SERVICE_UUID] identifier:@"ebeoo"];//初始化监测的iBeacon信息
        self.beacon1.notifyEntryStateOnDisplay = YES;

        [self.locationmanager startMonitoringForRegion:self.beacon1];//开始MonitoringiBeacon
    }

}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"___%s___",__func__);

    [self.locationmanager startRangingBeaconsInRegion:self.beacon1];//开始RegionBeacons

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //触发通知时间
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    //重复间隔
    //    localNotification.repeatInterval = kCFCalendarUnitMinute;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];

    //通知内容
    localNotification.alertBody = @"您的车辆就在附近，是否进行远程寻车？";
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;

    //通知参数
//    localNotification.userInfo = @{kLocalNotificationKey: @"觉醒吧，少年"};

    localNotification.category = kNotificationCategoryIdentifile;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

}

//找的iBeacon后扫描它的信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    NSLog(@"___%s___",__func__);

    //如果存在不是我们要监测的iBeacon那就停止扫描他

    if (![[region.proximityUUID UUIDString] isEqualToString:TRANSFER_SERVICE_UUID]){

        [self.locationmanager stopMonitoringForRegion:region];

        [self.locationmanager stopRangingBeaconsInRegion:region];

    }

    //打印所有iBeacon的信息

    for (CLBeacon* beacon in beacons) {

        NSLog(@"rssi is :%ld",beacon.rssi);

        NSLog(@"beacon.proximity %ld",beacon.proximity);
    }

    self.beaconArr = beacons;
    
}

#pragma mark - 推送
- (void)initAPNSNotification:(NSDictionary *)launchOptions
{
    //判断是否由远程消息通知触发应用程序启动
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
        //获取应用程序消息通知标记数
        long badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badge > 0) {
            badge --;
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    //消息推送注册
    if ( [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)] ) {

        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

        [[UIApplication sharedApplication] registerForRemoteNotifications];

    } else {

        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];

    }
}

// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    NSLog(@"%@", notification.userInfo);94

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"本地推送通知"
                                                   message:@"您的车辆就在附近，是否进行远程寻车？"
                                                  delegate:nil
                                         cancelButtonTitle:@"知道了"
                                         otherButtonTitles:nil, nil];
    [alert show];

    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge -= notification.applicationIconBadgeNumber;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCenter_HAVE_NEWMESSAGE" object:nil];

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"远程推送"
//                                                   message:@"远程推送1"
//                                                  delegate:nil
//                                         cancelButtonTitle:@"知道了"
//                                         otherButtonTitles:nil, nil];
//    [alert show];
}

#pragma mark - 蓝牙
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{ switch (central.state) {
    case CBCentralManagerStateUnknown:
        NSLog(@">>>CBCentralManagerStateUnknown");
        break;
    case CBCentralManagerStateResetting:
        NSLog(@">>>CBCentralManagerStateResetting");
        break;
    case CBCentralManagerStateUnsupported:
        NSLog(@">>>CBCentralManagerStateUnsupported");
        break;
    case CBCentralManagerStateUnauthorized:
        NSLog(@">>>CBCentralManagerStateUnauthorized");
        break;
    case CBCentralManagerStatePoweredOff:
        NSLog(@">>>CBCentralManagerStatePoweredOff");
        break;
    case CBCentralManagerStatePoweredOn:
        NSLog(@">>>CBCentralManagerStatePoweredOn"); //开始扫描周围的外设
        /*
         第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
         - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
         */
//        [manager scanForPeripheralsWithServices:nil/*@[[CBUUID UUIDWithString:@"1802"]]*/ options:nil];
        [central scanForPeripheralsWithServices:nil//@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                        options:nil//@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}
         ];
        break;
    default: break;
} }
//扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{

    NSLog(@"当扫描到设备name:---%@",peripheral.name); //接下来可以连接设备
//    for (CBService *ser in peripheral.services) {
//        NSLog(@"当扫描到设备UUID:%@---",ser.UUID.UUIDString); //接下来可以连接设备
        //连接设备
    //找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
        [peripherals addObject:peripheral];
    peripheral.delegate = self;
    currentPeripheral = peripheral;
    if (!self.timer) {
        　　self.timer = [NSTimer scheduledTimerWithTimeInterval:1.
                        　　target:self
                        　　selector:@selector(readRSSI)
                        　　userInfo:nil
                        　　repeats:YES];
        　　[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];

//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    //触发通知时间
//    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
//    //重复间隔
//    //    localNotification.repeatInterval = kCFCalendarUnitMinute;
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//
//    //通知内容
//    localNotification.alertBody = @"i am a test local notification";
//    localNotification.applicationIconBadgeNumber = 1;
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//
//    //通知参数
//    localNotification.userInfo = @{kLocalNotificationKey: @"觉醒吧，少年"};
//
//    localNotification.category = kNotificationCategoryIdentifile;
//
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

//    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);

    [peripheral discoverServices:nil];
}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    [central scanForPeripheralsWithServices:nil//@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                    options:nil//@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}
     ];
}

//扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }

}

//获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);

}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{

    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

-(void)readRSSI{
    //    NSLog(@"readRSSI");
    [currentPeripheral readRSSI];
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
//    NSLog(@"didReadRSSI:%lu",RSSI.integerValue);
}

#pragma mark - ===
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //进入后台 处理后台任务
    [self comeToBackgroundMode];
}

#pragma mark 处理后台任务
- (void)comeToBackgroundMode {
    self.count = 0;
    // 初始化一个后台任务BackgroundTask，这个后台任务的作用就是告诉系统当前App在后台有任务处理，需要时间
    [self beginBackgroundTask];
}

#pragma mark 开启一个后台任务
- (void)beginBackgroundTask {
    UIApplication *app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    // 开启定时器，不断向系统请求后台任务执行的时间
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
}
#pragma mark 结束一个后台任务
- (void)endBackgroundTask {
    UIApplication *app = [UIApplication sharedApplication];
    [app endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
    // 结束计时
    [self.timer invalidate];
}
#pragma mark 申请后台运行时间
- (void)applyForMoreTime {
    self.count ++;
    NSLog(@"%ld，剩余时间：%f", (long)self.count, [UIApplication sharedApplication].backgroundTimeRemaining);
    if (self.count % 150 == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 结束当前后台任务
            [self endBackgroundTask];
            // 开启一个新的后台任务
            [self beginBackgroundTask];
        });
    }
    
}

#pragma mark APP进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    // 结束后台任务
    [self endBackgroundTask];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
