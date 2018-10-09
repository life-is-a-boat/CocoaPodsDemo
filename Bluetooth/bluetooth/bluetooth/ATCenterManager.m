//
//  ATCenterManager.m
//  bluetooth
//
//  Created by tingting on 2018/9/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#define TRANSFER_SERVICE_UUID           @"FEE0"
#define TRANSFER_CHARACTERISTIC_UUID    @"FF0F"

#import "ATCenterManager.h"

@interface ATCenterManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCharacteristic    *_currentCharacteristic;
}
@property (nonatomic, strong) NSTimer   *timer; //定时器 保证与外设之间保持通信

@end
@implementation ATCenterManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [ATCenterManager new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
        _discoverPeripherals = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)startScanPeripherals {
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    _discoverPeripherals = [[NSMutableArray alloc] initWithCapacity:0];
//    [self centralManagerDidUpdateState:_manager];
}

- (void)stopScanPeripherals {
    [_manager stopScan];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    switch (central.state) {
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
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             */
            if (_manager.state == CBCentralManagerStatePoweredOn) {
                //开始扫描        [self.centralManager scanForPeripheralsWithServices:self.deviceServiceArray options:nil];
                [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            }
            break;
        default:
            break;
    }
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict;
{
    NSLog(@"%s__%@",__func__,dict);
}
//扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"当扫描到设备:%@",peripheral.name);
    //接下连接我们的测试设备，如果你没有设备，可以下载一个app叫lightbule的app去模拟一个设备
    //这里自己去设置下连接规则，我设置的是P开头的设备
    //    if ([peripheral.name hasPrefix:@"P"]){
    /*
     一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
     - (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;//连接外设成功的委托
     - (void)centra`lManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//外设连接失败的委托
     - (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;//断开外设的委托
     */
    if ([peripheral.name hasPrefix:@"Megain"]) {
        if ([advertisementData[@"kCBAdvDataIsConnectable"] boolValue]) {
            [_discoverPeripherals addObject:peripheral];
            peripheral.delegate = self;
            _currentPeripheral = peripheral;
            [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];
        }
    }
    
//    //找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
//    [_discoverPeripherals addObject:peripheral];
//    peripheral.delegate = self;
//
//    _currentPeripheral = peripheral;
//    if (!_timer) {
//        　　self.timer = [NSTimer scheduledTimerWithTimeInterval:3.
//                        　　target:self
//                        　　selector:@selector(readRSSI)
//                        　　userInfo:nil
//                        　　repeats:YES];
//        　　[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//    }
//    [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];
}
-(void)readRSSI{
    //    NSLog(@"readRSSI");
    [_currentPeripheral readRSSI];
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
//    serviceUUIDs：可以添加一组CBUUID的service，这样就可以发现指定的Services（官方推荐），如果为nil，则去发现所有有效的Services（相对较慢，不推荐）
    [peripheral discoverServices:nil];
}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
        [self.timer invalidate];
        self.timer = nil;
    //    [manager scanForPeripheralsWithServices:nil options:nil];
    [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                    options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

// 必需执行  [peripheral readRSSI] 才会执行下代理方法
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"didReadRSSI:%lu",RSSI.integerValue);
}
//扫描到Services
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //  NSLog(@">>>扫描到服务：%@",peripheral.services);

    if (error)  //如果有错，则主动断开，然后会走（centralManager:didDisconnectPeripheral:error:）
    {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        [self.manager cancelPeripheralConnection:peripheral];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"service.UUID:---%@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
    
}

//扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)//如果有错，则主动断开，然后会走（centralManager:didDisconnectPeripheral:error:）
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        [self.manager cancelPeripheralConnection:peripheral];
        return;
    }
//     for (CBCharacteristic *aChar in service.characteristics){
//         //判断Characteristic属性类型
//         if ((aChar.properties & CBCharacteristicPropertyRead)){
//             self.readCharacteristic = aChar;
//             [peripheral readValueForCharacteristic:aChar];
//         }
//         if ((aChar.properties & CBCharacteristicPropertyWrite)){
//             self.writeCharacteristic = aChar;
//             [peripheral setNotifyValue:YES forCharacteristic:aChar];
//             NSLog(@"----%@",aChar);
//         }
//     }
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]){
            _currentPeripheral = peripheral;
            _currentCharacteristic = characteristic;
            [self openTime];
        }
    }
    
    //获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
    //搜索Characteristic的Descriptors，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

//获取的charateristic的值  从peripheral 读取数据
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
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic uuid:%@",characteristic.UUID);
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

- (void)readPeripheral:(CBPeripheral *)peripheral
        characteristic:(CBCharacteristic *)characteristic {
    NSLog(@"properties:%lu", (unsigned long)characteristic.properties);
    //只有 characteristic.properties 有read的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyRead){
//        对于Characteristic是CBCharacteristicPropertyRead的写使能，就会回调CBPeripheralDelegate的代理方法
        [peripheral readValueForCharacteristic:characteristic];
    }else{
        NSLog(@"该字段不可读！");
    }
}

//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    //打印出 characteristic 的权限，可以看到有很多种，这是一个NS_OPTIONS，就是可以同时用于好几个值，常见的有read，write，notify，indicate，知知道这几个基本就够用了，前两个是读写权限，后两个都是通知，两种不同的通知方式。
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                                = 0x01,
     CBCharacteristicPropertyRead                                                    = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
     CBCharacteristicPropertyWrite                                                    = 0x08,
     CBCharacteristicPropertyNotify                                                    = 0x10,
     CBCharacteristicPropertyIndicate                                                = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
     CBCharacteristicPropertyExtendedProperties                                        = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)    = 0x200
     };
     
     */
    NSLog(@"properties:%lu", (unsigned long)characteristic.properties);
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        /*
         最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
         */
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}
//写入数据成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@">>>didWriteValueForCharacteristic");
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@">>>didWriteValueForDescriptor");
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    NSLog(@"设置通知");
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    NSLog(@"取消通知");
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    NSLog(@"停止扫描并断开连接");
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}

-(void)openTime
{
    //
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(writeData) userInfo:nil repeats:YES];
    [timer fire];
}
-(void)writeData
{
    //
    NSData *data = [self sportBao];//[@"550504010101AA" dataUsingEncoding:NSUTF16StringEncoding];
    [_currentPeripheral writeValue:data forCharacteristic:_currentCharacteristic type:CBCharacteristicWriteWithoutResponse];
}
// APP请求运动模式基础数据传输时拆分的总包数
- (NSData *)sportBao
{
    Byte reg[6];
    reg[0]=0xa5;
    reg[1]=0x06;
    reg[2]=0x03;
    reg[3]=0x01;
    reg[4]=0x02;
    reg[5]=(Byte)(reg[0]^reg[1]^reg[2]^reg[3]^reg[4]);
    NSData *data=[NSData dataWithBytes:reg length:6];
    return data;
}

@end
