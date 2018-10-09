//
//  ATPeripheralManager.m
//  bluetooth
//
//  Created by tingting on 2018/9/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ATPeripheralManager.h"
@interface ATPeripheralManager ()<CBPeripheralManagerDelegate>

@end
@implementation ATPeripheralManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [ATPeripheralManager new];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBPeripheralManagerOptionShowPowerAlertKey:@YES}];
    }
    return self;
}
#define SERVICE_UUID @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"
- (void)startAdvertising {
    if ([CBPeripheralManager authorizationStatus] == CBPeripheralManagerAuthorizationStatusAuthorized) {
        if (self.manager.state == CBPeripheralManagerStatePoweredOn) {
            //创建服务
            [self setupServiceAndCharacteristics];
            //根据服务的UUID开始广播
            [self.manager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
        }
    }
}

- (void)setupServiceAndCharacteristics {
    // 创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceID primary:YES];
    // 创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    CBMutableCharacteristic *characteristic = [
                                               [CBMutableCharacteristic alloc]
                                               initWithType:characteristicID
                                               properties:
                                               CBCharacteristicPropertyRead |
                                               CBCharacteristicPropertyWrite |
                                               CBCharacteristicPropertyNotify
                                               value:nil
                                               permissions:CBAttributePermissionsReadable |
                                               CBAttributePermissionsWriteable
                                               ];
    // 特征添加进服务
    service.characteristics = @[characteristic];
    // 服务加入管理
    [self.manager addService:service];
    
    // 为了手动给中心设备发送数据
    self.characteristic = characteristic;
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBManagerStateUnknown: //未知
            NSLog(@">>>CBManagerStateUnknown");
            break;
        case CBManagerStateResetting://正在重置
            NSLog(@">>>CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported://不支持
            NSLog(@">>>CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized://未授权
            NSLog(@">>>CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOn://已打开
            NSLog(@">>>CBManagerStatePoweredOn");
            break;
        case CBManagerStatePoweredOff://已关闭
            NSLog(@">>>CBManagerStatePoweredOff");
            break;
        default:
            break;
    }
}

 - (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict {
     NSLog(@"___%s___%@",__func__,dict);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    NSLog(@"___%s______error:%@",__func__,error.localizedDescription);
}
//当中心设备读取这个外设的数据的时候
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"___%s______request:%@",__func__,request.characteristic.UUID);
    //请求中的数据 把数据发给中心设备
    request.value = [self sportBao];
    //成功相应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}
//当中心设备写入数据的时候
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    //写入数据的请求
    CBATTRequest *request = requests.lastObject;
    NSLog(@"___%s______request:%@",__func__,request.characteristic.UUID);

    NSLog(@"__%@",[[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding]);
}
//主动给中心设备发送数据
- (void)sendData {
    BOOL sendSuccess = [self.manager updateValue:[self sportBao] forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    if (sendSuccess) {
        NSLog(@"发送成功！");
    }
    else {
        NSLog(@"发送失败！");
    }
}
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
//中心设备订阅成功的时候回调  服务中需要添加 CBCharacteristicPropertyNotify 否则不会调用下两种方法
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"___%s___characteristic：%@",__func__,characteristic.UUID);
}
//中心设备取消订阅的时候回调
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"___%s___characteristic：%@",__func__,characteristic.UUID);
}

@end
