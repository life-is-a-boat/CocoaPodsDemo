//
//  BLEWrapManager.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/5/25.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation

protocol BLEWrapManagerDelegate:class
{
    func didReadUUID(config:DeviceConfig?,uuid:String)
    func didConnectBLEDevice()
    func didDisconnectBLEDevice()
    func timeOutScanBLE()
    func BLEStateClosed()
    func didReadConfig(dateTime:Date?,
                       latency:Int,
                       sampleIntervale:Int,
                       temperatureUpLimit:Float,
                       temperatureLowLimit:Float,
                       humidityUpLimit:Float,
                       humidityLowLimit:Float)
    func didReadMemoData(data:Data?)
    func didWriteConfig()
    func didWriteUUID()
    func didReadStatus(success:Bool,battery:Int,isRunning:Bool,recordCount:Int)
    func reUsePreDevice()
    func didStartTag()
    func didStopTag()
    func stopTagFail()
    func didClearData()
    func clearDataProgress(index:Int)
    func didReadData(data:Data)
}

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

class BLEWrapManager:NSObject,BLEManagerDelegate {

    // const let for COMMAND
    private let WRITE_SUCCESS_LEN = 2
    private let WRITE_SUCCESS = "0200"
    
    private let READ_UUID_LEN = 17 //uuid 16Bytes :formate 02+data
    private let READ_STATUS_LEN = 10 //0200 0000(电压) 00 00 00 00（采样次数）

    private let WRITE_CONFIG_LEN = 2
    private let READ_CONFIG_LEN = 81
    private var memoLen = 0
    private var memo:Data? = nil
    
//    private let READ_DATA_LEN = 1001 //TODO: 02+4K(data)
    
    private var clearIndex = 0
    //MARK: - properties
    static let shareInstance = BLEWrapManager()
    private var delegates = [BLEWrapManagerDelegate?]()
    
    func addDelegate(delegate:BLEWrapManagerDelegate){
        weak var obj = delegate
        delegates.append(obj)
    }
    
    func removeDelegate(delegate:BLEWrapManagerDelegate){
        let index = delegates.index { (obj) -> Bool in
            obj === delegate
        }
        if index != nil {
            delegates.remove(at: index!)
        }
    }
    
    var peripheral:CBPeripheral?
    var uuid:String? = nil
    var config:DeviceConfig?
    var currentCommand:Command?
    var devices = [UUID:DeviceInfo]()
    var isRunning = false
    var isStarted = false
    
    var hasBeenStarted:Bool {
        get {
            return isStarted || isRunning
        }
    }
    
    var deviceConfigable:Bool {
        get {
            return peripheral != nil
        }
    }
    
    //MARK: - CBCentralManagerDelegate
    func centerManagerStateChange(_ state: CBManagerState) {
        switch state {
        case .unknown:
            print("unknow")
            break
        case .resetting:
            print("resetting")
            break
        case .unsupported:
            print("unsupported")
            break
        case .unauthorized:
            print("unauthorized")
            break
        case .poweredOff:
            print("poweredOff")
            for delegate in delegates {
                delegate?.BLEStateClosed()
            }
            break
        case .poweredOn:
            print("poweredOn")
            startBLEScan()
            break
        }
    }

    func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        self.peripheral = device
        for delegate in delegates {
            delegate?.didConnectBLEDevice()
        }
    }
    
    func stopScanDevice() {
        for delegate in delegates {
            delegate?.timeOutScanBLE()
        }
    }
    
    func didDisconnectDevice(_ device: CBPeripheral!, error: Error!) {
        self.peripheral = nil
        for delegate in delegates {
            delegate?.didDisconnectBLEDevice()
        }
    }
    
    func receiveDeviceDataSuccess_1(_ data: Data!, device: CBPeripheral!) {
        print("Data received callback method (1002 channels):\(data)")
        
        if currentCommand != nil {
            let value = data.hexString()
            switch (data.count,currentCommand!) {
            case (READ_UUID_LEN,Command.READ_UUID):
                uuid = value.substring(from: 2)
                config = Storage.instance.config(uuid: uuid!)
                for delegate in delegates {
                    delegate?.didReadUUID(config: config,uuid: uuid!)
                }
            case (WRITE_SUCCESS_LEN,Command.WRITE_UUID):
                if value == WRITE_SUCCESS {
                    for delegate in delegates {
                        delegate?.didWriteUUID()
                    }
                }
            case (READ_STATUS_LEN, Command.READ_STATUS):
                print("READ STATUS")
                let sucess = value.substring(from: 0, to: 4) == "0200"
                let battery = Int(value.substring(from: 4, to: 8), radix: 16) ?? 0
                isRunning = value.substring(from: 10, to: 12) == "55"
                let recordCount = Int(value.substring(from: 12, to: 20), radix: 16) ?? 0
                for delegate in delegates {
                    delegate?.didReadStatus(success: sucess,
                                            battery: battery,
                                            isRunning: isRunning,
                                            recordCount: recordCount)
                }
                
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
                for delegate in delegates {
                    delegate?.didReadConfig(dateTime: dateTime,
                                            latency: latency,
                                            sampleIntervale: sampleIntervale,
                                            temperatureUpLimit: temperatureUpLimit,
                                            temperatureLowLimit: temperatureLowLimit,
                                            humidityUpLimit: humidityUpLimit,
                                            humidityLowLimit: humidityLowLimit)
                }
            case (_, Command.READ_MEMO_HEAD):
                let len = value.count
                let dataLen = value.substring(from: len-8, to: len-4)
                if (dataLen == "FF"){
                    for delegate in delegates {
                        delegate?.didReadMemoData(data: nil)
                    }
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
                    BLEWrapManager.readMemoDataConent(recievedCount: 0,count: readLen)
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
                    BLEWrapManager.readMemoDataConent(recievedCount:memo!.count, count: readLen)
                }else{
                    for delegate in delegates {
                        delegate?.didReadMemoData(data: memo)
                    }
                    memoLen = 0
                    memo = nil
                }
            case (WRITE_CONFIG_LEN, Command.WRITE_CONFIG):
                if value == WRITE_SUCCESS {
                    for delegate in delegates {
                        delegate?.didWriteConfig()
                    }
                }
            case (WRITE_SUCCESS_LEN,Command.START_TAG):
                if value == WRITE_SUCCESS {
                    isStarted = true
                    for delegate in delegates {
                        delegate?.didStartTag()
                    }
                }
            case (WRITE_SUCCESS_LEN,Command.STOP_TAG):
                if value == WRITE_SUCCESS {
                    for delegate in delegates {
                        delegate?.didStopTag()
                    }
                    isStarted = false
                    isRunning = false
                }else{
                    for delegate in delegates {
                        delegate?.stopTagFail()
                    }
                }
            case (WRITE_SUCCESS_LEN,Command.CLEAR_DATA):
                if value == WRITE_SUCCESS {
                    print("Clear Data...\(clearIndex)")
                    clearIndex += 1
                    if BLEWrapManager.clearData(index: clearIndex){
                        for delegate in delegates {
                            delegate?.clearDataProgress(index: clearIndex)
                        }
                    }else{
                        for delegate in delegates {
                            delegate?.didClearData()
                        }
                    }
                }
            case (_,Command.READ_DATA):
                print("=== READ_DATA ===")
                for delegate in delegates {
                    delegate?.didReadData(data: data[1...]) //remove head 02
                }
                break
            default:
                break
            }
        }
    }
    
    func receiveDeviceDataSuccess_3(_ data: Data!, device: CBPeripheral!) {
        print("Data received callback method (1003 channels):\(data)")
    }
    
    func receive_Data_EventfromModel(_ TXP: Data!, p len: UInt8, dev cb: CBPeripheral!, andMarkId markId: Int) {
        print("receive_Data_EventfromModel:\(TXP) p:\(len) markId:\(markId)")
    }
    
    func receiveDeviceDescriptorValue(_ data: String!, with characteristic: CBCharacteristic!, peripheral: CBPeripheral!) {
        print("receiveDeviceDescriptorValue:\(data)")
    }
    
    //MARK: - OAD
    
    //MARK: - BLE Manager Delegate
    func bleManager(_ central: CBCentralManager!, didDiscover peripheral: CBPeripheral!, advertisementData: [AnyHashable : Any]!, rssi RSSI: NSNumber!) {
        print(peripheral.name as Any)
        let name = peripheral.name ?? ""
        if name.hasPrefix("Megain") { //Megain
            print("rssi:\(RSSI) advertisment:\(advertisementData)")
            if advertisementData["kCBAdvDataIsConnectable"] as! Bool == true {
                let deviceInfo = self.devices[peripheral.identifier] ?? DeviceInfo()
                deviceInfo.name = advertisementData["kCBAdvDataLocalName"] as? String
                deviceInfo.rssi = RSSI.intValue
                deviceInfo.advertisementDic = advertisementData
                self.devices[peripheral.identifier] = deviceInfo
                BLEManager.default().connect(toDevice: peripheral)
                print(peripheral)
            }
        }
    }

    func bleManagerPeripheral(_ peripheral: CBPeripheral!, didWriteValueFor characteristic: CBCharacteristic!, error: Error!) {
        print("didWriteValueFor : \(characteristic) error:\(String(describing: error))")
    }
    
    func bleManagerPeripheral(_ peripheral: CBPeripheral!, didUpdateValueFor characteristic: CBCharacteristic!, error: Error!) {
    }
    
    func bleManagerPeripheral(_ peripheral: CBPeripheral!, didUpdateNotificationStateFor characteristic: CBCharacteristic!, error: Error!) {
        print("didUpdateNotificationStateFor : \(characteristic) error:\(String(describing: error))")
        if (characteristic.uuid.uuidString == "1002"
            && currentCommand == Command.SCAN) {  //haven't init device info
            BLEWrapManager.readDeviceUUID()
        }
    }
    
    //MARK: - Common
    func receiveDeviceVersion(_ version: String!, device: CBPeripheral!) {
        print("receiveDeviceVersion :\(version)")
    }
    
    func receiveDeviceBattery(_ battery: Int, device: CBPeripheral!) {
        print("receiveDeviceBattery :\(battery)")
    }
    
    func receiveDeviceUTFTime(_ year: Int, month: Int, day: Int, hour: Int, minute monute: Int, second: Int, device: CBPeripheral!) {
        print("receiveDeviceUTFTime: year:\(year) month:\(month) day:\(day) hour:\(hour) minute:\(monute)")
    }
    
    func receiveDeviceChannelRate(_ rate: String!, device: CBPeripheral!) {
        print("receiveDeviceChannelRate:\(rate)")
    }
    
    func receiveDeviceTXPower(_ txPower: String!, device: CBPeripheral!) {
        print("receiveDeviceTXPower:\(txPower)")
    }
    
    func receiveDeviceSettingName(_ name: String!, device: CBPeripheral!) {
        print("receiveDeviceTXPower:\(name)")
    }
    
    func receiveDeviceSettingPassword(_ password: String!, device: CBPeripheral!) {
        print("receiveDeviceTXPower:\(password)")
    }
    
    func receiveDeviceAdvertInterval(_ interval: Int, device: CBPeripheral!) {
        print("receiveDeviceAdvertInterval:\(interval)")
    }
    
    func receiveDeviceConnectInterval(_ interval: Int, device: CBPeripheral!) {
        print("receiveDeviceConnectInterval:\(interval)")
    }
    
    func receiveDeviceLatency(_ interval: Int, device: CBPeripheral!) {
        print("receiveDeviceLatency:\(interval)")
    }
    
    func receiveDeviceAdvertData(_ dataStr: String!, device: CBPeripheral!) {
        print("receiveDeviceAdvertData:\(dataStr)")
    }
    
    func readDeviceRSSI(_ peripheral: CBPeripheral!, rssi RSSI: NSNumber!) {
        print("readDeviceRSSI:\(RSSI)")
    }
    
    func receiveDeviceInfoModel(_ string: String!, withDevice cb: CBPeripheral!) {
        print("readDeviceRSSI:\(string)")
    }
    
    func receiveDeviceInfomation(_ string: String!, with cb: CBPeripheral!) {
        print("receiveDeviceInfomation:\(string)")
    }
    
    func receive(_ data: Data!, with2000ServiceDevice cb: CBPeripheral!, with characteristic: CBCharacteristic!) {
        print("receive 2000:\(cb)")
    }
    
    //MARK: START/STOP SCAN
    @discardableResult
    func startBLEScan() -> Bool{
        if self.peripheral == nil {
            if BLEManager.default().delegate == nil {
                BLEManager.default().delegate = self
                BLEManager.default().stopAutoConnect()
                BLEManager.default().isEncryption = false
            }
            BLEManager.default().scanDeviceTime(30)
            currentCommand = Command.SCAN
        }else{
            for delegate in delegates {
                delegate?.reUsePreDevice()
            }
        }
        return true
    }

    func stopBLEScan() -> Bool {
        BLEManager.default().manualStopScanDevice()
        return true
    }
}

