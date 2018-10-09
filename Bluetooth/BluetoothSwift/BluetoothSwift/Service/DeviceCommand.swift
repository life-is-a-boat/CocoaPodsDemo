//
//  DeviceCommand.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/5/24.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation
import CoreBluetooth

class DeviceCommand {
    
    static let STAR_TAG:[UInt8] = [0x02,0x07,0x00]  //启动温湿度标签指令
    static let STOP_TAG:[UInt8] = [0x02,0x07,0x01]  //停止温湿度标签指令
    static let CURRENT_STATUS:[UInt8] = [0x02,0x07,0x02]  //获取当前状态指令

    private static func getCharacteristic(peripheral: CBPeripheral, channel:Int) -> CBCharacteristic?{
        let service = peripheral.services?.first(where: { (service) -> Bool in
            return service.uuid.uuidString == "1000"
        })
        
        return service?.characteristics?.first(where: { (characteristic) -> Bool in
            return Int(characteristic.uuid.uuidString) == channel
        })
    }
    
    static func startTag(peripheral: CBPeripheral?){
        guard peripheral != nil else { return }
        let characteristic:CBCharacteristic = getCharacteristic(peripheral: peripheral!,channel: 1001)!
        BLEManager.shareInstance.SendCommand(bytes: STAR_TAG, characteristic: characteristic, withResponse: true)
    }
    
    static func stopTag(peripheral: CBPeripheral?){
        guard peripheral != nil else { return }
        let characteristic:CBCharacteristic = getCharacteristic(peripheral: peripheral!,channel: 1001)!
        BLEManager.shareInstance.SendCommand(bytes: STOP_TAG, characteristic: characteristic, withResponse: true)
    }
    
    static func currentStatus(peripheral: CBPeripheral?){
        guard peripheral != nil else { return }
        let characteristic:CBCharacteristic = getCharacteristic(peripheral: peripheral!,channel: 1001)!
        BLEManager.shareInstance.SendCommand(bytes:CURRENT_STATUS, characteristic: characteristic, withResponse: true)
    }
}
