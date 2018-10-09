//
//  ViewController.swift
//  BluetoothSwift
//
//  Created by mac on 16/7/1.
//  Copyright © 2016年 lb. All rights reserved.
//


import UIKit
import CoreBluetooth


@available(iOS 10.0, *)
class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {

    var bluManager:CBManager!
    var manager :CBCentralManager!
//    var peripheral :CBPeripheral!
    var label :UILabel!
    var peripherals : NSMutableArray!
    var bleManager: BLEManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bleManager = BLEManager()
        bleManager.startScan()
//        if manager == nil {
//            //该方法设置代理之后会调用  public func centralManagerDidUpdateState(central: CBCentralManager)
////            manager = CBCentralManager.init(delegate: self, queue: DispatchQueue.main)
//            manager = CBCentralManager(delegate: self, queue: DispatchQueue.main);
//        }
//
//        if label == nil {
//            label = UILabel.init()
//            label.center = self.view.center
//            label.bounds = CGRect.init(x: 0, y: 0, width: 200, height: 100);//CGRectMake(0, 0, 200, 100)
//            label.font = UIFont.systemFont(ofSize: 15)
//            label.textColor = UIColor.blue
//            label.layer.masksToBounds = true
//            label.layer.borderWidth = 1
//            label.layer.borderColor = UIColor.groupTableViewBackground.cgColor
//            label.numberOfLines = 0
//            self.view.addSubview(label)
//            label.text = "扫描设备..."
//        }
//
//        if peripherals == nil {
//            peripherals = NSMutableArray.init(capacity: 0)
//        }
    }

//    @available(iOS 10.0, *)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
        switch central.state {
            case CBManagerState.unknown:
                print(">>>CBCentralManagerState.Unknown")
            case CBManagerState.resetting:
                print(">>>CBCentralManagerState.Resetting")
            case CBManagerState.unsupported:
                print(">>>CBCentralManagerState.Unsupported")
            case CBManagerState.unauthorized:
                print(">>>CBCentralManagerState.Resetting")
            case CBManagerState.poweredOff:
                print(">>>CBCentralManagerState.Unauthorized")
            case CBManagerState.poweredOn:
                print(">>>CBCentralManagerState.PoweredOn")
                central.scanForPeripherals(withServices: nil, options: nil)
                //            let uuid :CBUUID = CBUUID.init(string: TARGET_UUID)
        }
    
    }

    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(">>>搜到设备\(String(describing: peripheral.name))");
        label.text = label.text! + "\n 扫描到设备\(String(describing: peripheral.name))"
        if (peripheral.name?.hasPrefix("Megain"))! {
            if (advertisementData["kCBAdvDataIsConnectable"]?.boolValue)! {
                //情景：必须保存搜索到的设备 才能连接成功！
                peripherals.add(peripheral)
                //连接设备
                peripheral.delegate = self;
                central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnNotificationKey:true])
            }
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print(">>>连接设备\(String(describing: peripheral.name))成功！")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(">>>连接设备\(String(describing: peripheral.name))失败！")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(">>>与设备\(String(describing: peripheral.name))断开连接！")
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

