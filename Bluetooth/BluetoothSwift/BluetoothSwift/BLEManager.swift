//
//  BLEManager.swift
//  BluetoothSwift
//
//  Created by tingting on 2018/9/22.
//  Copyright © 2018年 lb. All rights reserved.
//

let TARGET_UUID = "FF0F"

enum Command {
    case SCAN
    
    case READ_UUID
    case WRITE_UUID
    
    case READ_STATUS
    
    case WRITE_CONFIG
    case READ_CONFIG
    case READ_MEMO_HEAD
    case READ_MEMO_DATA
    
    case START_TAG
    case STOP_TAG
    
    case READ_DATA
    case CLEAR_DATA
}

import UIKit
import CoreBluetooth

class BLEManager: NSObject,CBCentralManagerDelegate,CBPeripheralDelegate {
    // const let for COMMAND
    private let WRITE_SUCCESS_LEN = 2
    private let WRITE_SUCCESS = "0200"
    
    private let READ_UUID_LEN = 17 //uuid 16Bytes :formate 02+data
    private let READ_STATUS_LEN = 10 //0200 0000(电压) 00 00 00 00（采样次数）
    
    private let WRITE_CONFIG_LEN = 2
    private let READ_CONFIG_LEN = 81
    private var memoLen = 0
    private var memo:Data? = nil
    

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("poweredOn")
            if manager.state == .poweredOn {
                let uuid :CBUUID = CBUUID.init(string: TARGET_UUID)
                manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
            }
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        }
    }
    //MARK: CBCentralManagerDelegate
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(">>>搜到设备\(String(describing: peripheral.name))");
        print(peripheral.name as Any)
        let name = peripheral.name ?? ""
        if name.hasPrefix("Megain") { //Megain
            print("rssi:\(RSSI) advertisment:\(advertisementData)")
            if advertisementData["kCBAdvDataIsConnectable"] as! Bool == true {
                peripherals.add(peripheral)
                central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnNotificationKey:true])
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(">>>连接到名称为\(String(describing: peripheral.name))的设备-成功")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        central.stopScan()
    }
    //MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        if error != nil {
            manager.cancelPeripheralConnection(peripheral)
            return
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")
        if error != nil {
            manager.cancelPeripheralConnection(peripheral)
            return
        }
        
        for characteristic in service.characteristics! {
            peripheral.readValue(for: characteristic)
        }
    }
    var peripheral:CBPeripheral?
    var uuid:String? = nil
    var config:DeviceConfig?
    var currentCommand:Command?
//    var devices = [UUID: DeviceInfo]()
    var isRunning = false
    var isStarted = false
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//    }
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("uuid:\(characteristic.uuid)===error:\(error)---data:\(characteristic.value)")
        if error != nil {
            return
        }
        if characteristic.value == nil {
            return
        }
        if (characteristic.uuid.uuidString == "1002"
            && currentCommand == Command.SCAN) {  //haven't init device info
            
        }
        return
        let data = characteristic.value!
        if characteristic.uuid.uuidString == "System ID" {
            print([String(data: data, encoding: .utf8)])
            print([String(data: data, encoding: .utf16)])
            print([String(data: data, encoding: .utf32)])
            print([String(data: data, encoding: .unicode)])
        }
        if currentCommand != nil {
            let value = data.hexString()
            switch (data.count,currentCommand!) {
            case (READ_UUID_LEN,Command.READ_UUID):
                uuid = value.substring(from: 2)
                config = Storage.instance.config(uuid: uuid!)
//                for delegate in delegates {
//                    delegate?.didReadUUID(config: config,uuid: uuid!)
//                }
            case (WRITE_SUCCESS_LEN,Command.WRITE_UUID):
                if value == WRITE_SUCCESS {
//                    for delegate in delegates {
//                        delegate?.didWriteUUID()
//                    }
                }
            case (READ_STATUS_LEN, Command.READ_STATUS):
                print("READ STATUS")
                let sucess = value.substring(from: 0, to: 4) == "0200"
                let battery = Int(value.substring(from: 4, to: 8), radix: 16) ?? 0
                isRunning = value.substring(from: 10, to: 12) == "55"
                let recordCount = Int(value.substring(from: 12, to: 20), radix: 16) ?? 0
//                for delegate in delegates {
//                    delegate?.didReadStatus(success: sucess,
//                                            battery: battery,
//                                            isRunning: isRunning,
//                                            recordCount: recordCount)
//                }
                
            case (READ_CONFIG_LEN,Command.READ_CONFIG): //READ_CONFIG_LEN
                let bcdFormatter = DateFormatter()
                bcdFormatter.dateFormat = "yyyyMMddHHmmss"
                let dateTime:Date? = bcdFormatter.date(from: value.substring(from: 20, to: 34))
                let latency:Int = Int(value.substring(from: 34, to: 38),radix:16)!
                let sampleIntervale:Int = Int(value.substring(from: 38, to: 42),radix:16)!
                let temperatureUpLimit = Float(Int(value.substring(from: 78, to: 82),radix:16)!)/100
                let temperatureLowLimit = Float(Int(value.substring(from: 86, to: 90),radix:16)!)/100.0
                let humidityUpLimit = Float(Int(value.substring(from: 94, to: 98),radix:16)!)/100.0
                let humidityLowLimit = Float(Int(value.substring(from: 102, to: 106),radix:16)!)/100.0
//                for delegate in delegates {
//                    delegate?.didReadConfig(dateTime: dateTime,
//                                            latency: latency,
//                                            sampleIntervale: sampleIntervale,
//                                            temperatureUpLimit: temperatureUpLimit,
//                                            temperatureLowLimit: temperatureLowLimit,
//                                            humidityUpLimit: humidityUpLimit,
//                                            humidityLowLimit: humidityLowLimit)
//                }
            case (_, Command.READ_MEMO_HEAD):
                let len = value.count
                let dataLen = value.substring(from: len-8, to: len-4)
                if (dataLen == "FF"){
//                    for delegate in delegates {
//                        delegate?.didReadMemoData(data: nil)
//                    }
                }else{
                    memoLen = Int(dataLen,radix:16)!
                    var readLen = 0
                    if memoLen > 0x50 {
                        readLen = 0x50
                    }else{
                        readLen = memoLen
                    }
                    
                    currentCommand = Command.READ_MEMO_DATA
                    memoLen = memoLen - readLen
//                    BLEWrapManager.readMemoDataConent(recievedCount: 0,count: readLen)
                }
            case (_, Command.READ_MEMO_DATA):
                if memo == nil {
                    memo = data[1...]
                }else{
                    memo = memo!+(data[1...])
                }
                if memoLen > 0 {
                    var readLen = 0
                    if memoLen > 0x50 {
                        readLen = 0x50
                    }else{
                        readLen = memoLen
                    }
                    
                    currentCommand = Command.READ_MEMO_DATA
                    memoLen = memoLen - readLen
//                    BLEWrapManager.readMemoDataConent(recievedCount:memo!.count, count: readLen)
                }else{
//                    for delegate in delegates {
//                        delegate?.didReadMemoData(data: memo)
//                    }
                    memoLen = 0
                    memo = nil
                }
            case (WRITE_CONFIG_LEN, Command.WRITE_CONFIG):
                if value == WRITE_SUCCESS {
//                    for delegate in delegates {
//                        delegate?.didWriteConfig()
//                    }
                }
            case (WRITE_SUCCESS_LEN,Command.START_TAG):
                if value == WRITE_SUCCESS {
                    isStarted = true
//                    for delegate in delegates {
//                        delegate?.didStartTag()
//                    }
                }
            case (WRITE_SUCCESS_LEN,Command.STOP_TAG):
                if value == WRITE_SUCCESS {
//                    for delegate in delegates {
//                        delegate?.didStopTag()
//                    }
                    isStarted = false
                    isRunning = false
                }else{
//                    for delegate in delegates {
//                        delegate?.stopTagFail()
//                    }
                }
            case (WRITE_SUCCESS_LEN,Command.CLEAR_DATA):
                if value == WRITE_SUCCESS {
//                    print("Clear Data...\(clearIndex)")
//                    clearIndex += 1
//                    if BLEWrapManager.clearData(index: clearIndex){
//                        for delegate in delegates {
//                            delegate?.clearDataProgress(index: clearIndex)
//                        }
//                    }else{
//                        for delegate in delegates {
//                            delegate?.didClearData()
//                        }
//                    }
                }
            case (_,Command.READ_DATA):
                print("=== READ_DATA ===")
//                for delegate in delegates {
//                    delegate?.didReadData(data: data[1...]) //remove head 02
//                }
                break
            default:
                break
            }
        }
    }
    
    var manager: CBCentralManager!
    var peripherals : NSMutableArray!
    static var shareinstance = BLEManager.init()
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        peripherals = NSMutableArray(capacity: 0)
    }
    //MARK: START/STOP SCAN
    @discardableResult
    public func startScan() -> () {
        print("startScan")
        currentCommand = Command.SCAN
    }
    
    //MARK: START/STOP SCAN
//    @discardableResult
//    func startBLEScan() -> Bool{
//        if self.peripheral == nil {
//            if BLEManager.default().delegate == nil {
//                BLEManager.default().delegate = self
//                BLEManager.default().stopAutoConnect()
//                BLEManager.default().isEncryption = false
//            }
//            BLEManager.default().scanDeviceTime(30)
//            currentCommand = Command.SCAN
//        }else{
//            for delegate in delegates {
//                delegate?.reUsePreDevice()
//            }
//        }
//        return true
//    }
    
//    func stopBLEScan() -> Bool {
//        BLEManager.default().manualStopScanDevice()
//        return true
//    }
}
