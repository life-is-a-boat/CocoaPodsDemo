//
//  BLEManager.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/5/24.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEManagerDelegate:class {
    func didConnectBLEDevice()
    func didDisconnectBLEDevice()
}

class BLEManager:NSObject,CBCentralManagerDelegate, CBPeripheralDelegate {

    static let shareInstance = BLEManager()
    
    weak var delegate: BLEManagerDelegate?
    private var cbCentralManager:CBCentralManager?
    var peripheral:CBPeripheral?
    var devices = [UUID:DeviceInfo]()
    //MARK: - BLE CBCentralManagerDelegate
    
    //只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
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
            break
        case .poweredOn:
            print("poweredOn")
            startBLEScan()
            break
        }
    }
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]){
//        print("willRestoreState : \(dict)")
//    }
    
    // 发现外设后调用的方法
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            if peripheral.name!.hasPrefix("Megain") { //Megain
                print("rssi:\(RSSI) advertisment:\(advertisementData)")
                if advertisementData["kCBAdvDataIsConnectable"] as! Bool == true {
                    self.peripheral = peripheral
                    var deviceInfo = self.devices[peripheral.identifier] ?? DeviceInfo()
                    deviceInfo.connectable = true
                    deviceInfo.name = advertisementData["kCBAdvDataLocalName"] as? String
                    deviceInfo.rssi = RSSI.intValue
                    deviceInfo.ServiceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID]
                    self.devices[peripheral.identifier] = deviceInfo
                    cbCentralManager!.connect(self.peripheral!, options: nil)
                    print(peripheral)
                }
            }else{
                if peripheral.name != "Sephi" {
                    print(peripheral)
                }
            }
        }
        
    }
    
    // 中心管理者连接外设成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect : \(peripheral.name ?? "")")
        // 连接成功之后,可以进行服务和特征的发现
        //  设置外设的代理
        self.peripheral?.delegate = self;
        // 外设发现服务,传nil代表不过滤
        // 这里会触发外设的代理方法 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
        self.peripheral?.discoverServices(nil)
    }
    
    //外设连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("connect fail : \(peripheral.name ?? "")")
    }
    
    //丢失连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("connect disconnect : \(peripheral.name ?? "")")
        self.peripheral = nil
        delegate?.didDisconnectBLEDevice()        
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheralDidUpdateName(_ peripheral: CBPeripheral){
        print("peripheralDidUpdateName: \(peripheral)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]){
        print("did modify service:\(invalidatedServices)")
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?){
        print("did update RSSI:\(peripheral) error:\(String(describing: error))")
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?){
        print("did read RSSI:\(RSSI) error:\(String(describing: error))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil {
            print("did discover service: \(String(describing: peripheral.services))")
            delegate?.didConnectBLEDevice()
            for service in peripheral.services! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }else{
            print("did didDiscoverServices : \(String(describing: error))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?){
        print("did discover include services for service:\(service) error:\(String(describing: error))")
    }
    
    // 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("====== \(service)==========")
        for characteristic in service.characteristics! {
            print("did discover characteristics : \(characteristic)")
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("did discover update for characteristics: \(characteristic) error:\(String(describing: error))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        print("did WriteValue For characteristics: \(characteristic) error:\(String(describing: error))")
        print("response value: \(String(describing: characteristic.value))")
        peripheral.readValue(for: (characteristic.descriptors?.first)!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("did discover update notification for characteristics: \(characteristic) error:\(String(describing: error))")
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?){
        print("did Discover Descriptors For characteristics: \(characteristic) error:\(String(describing: error))")
        print("discriptions:\(String(describing: characteristic.descriptors))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("did discover update descriptor for descriptor: \(descriptor) error:\(String(describing: error))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?){
        print("did WriteValue For descriptor: \(descriptor) error:\(String(describing: error))")
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral){
        print("toSendWriteWithoutResponse: \(peripheral)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?){
        print("did Open chanel : \(String(describing: channel)) error:\(String(describing: error))")
    }
    
    //MARK: START/STOP SCAN
    @discardableResult
    func startBLEScan() -> Bool{
        if cbCentralManager == nil {
            cbCentralManager = CBCentralManager(delegate: self, queue: nil)
        }else{
            if self.peripheral == nil {
                print("start scan")
                cbCentralManager!.scanForPeripherals(withServices: nil, options: nil)
            }else{
                delegate?.didConnectBLEDevice()
            }
        }
        return true
    }
    
    func stopBLEScan() -> Bool {
        cbCentralManager?.stopScan()
        return true
    }
    
    //MARK: - Send Command
    func SendCommand(bytes:[UInt8],characteristic:CBCharacteristic,withResponse:Bool) {
        let data = Data(bytes: bytes)
        self.peripheral?.writeValue(data, for: characteristic, type: withResponse ? .withResponse : .withoutResponse)
    }
    
    //MARK: - DeviceInfo Struct
    struct DeviceInfo {
        var connectable:Bool?
        var name:String?
        var rssi:Int?
        var ServiceUUIDs:[CBUUID]?
    }
}
