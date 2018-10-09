//
//  ATPeripheralManager.h
//  bluetooth
//
//  Created by tingting on 2018/9/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ATPeripheralManager : NSObject

@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, strong) CBCentral *currentCentral;
@property (nonatomic, strong) CBMutableCharacteristic  *characteristic;

+ (instancetype)shareInstance;

@end
