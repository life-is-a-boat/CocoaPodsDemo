//
//  ATCenterManager.h
//  bluetooth
//
//  Created by tingting on 2018/9/17.
//  Copyright © 2018年 mac. All rights reserved.
//
/*!
 *  CBPeripheral  外设
 *  CBUUID
 *  CBService   服务
 *  CBCharacteristic  特征
 *  一个外设可以有一个或多个服务
 *  一个服务中包含一个或多个特征
 *  GATT 通用属性配置文件
 *  18736812179
*/
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ATCenterManager : NSObject

@property (nonatomic, strong) CBCentralManager  *manager;
@property (nonatomic, strong) NSMutableArray *discoverPeripherals;
@property (nonatomic, strong) CBPeripheral *currentPeripheral;

+ (instancetype)shareInstance;
- (void)startScanPeripherals;
- (void)stopScanPeripherals;

@end
