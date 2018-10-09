////
////  BLECommand.swift
////  iOSmodao
////
////  Created by SephirothKwon on 2018/5/26.
////  Copyright © 2018年 SephirothKwon. All rights reserved.
////
//
//import Foundation
//import CoreBluetooth
//
//
//extension BLEWrapManager {
//
//    /// read init uuid
//    static func readDeviceUUID(){
//        BLEWrapManager.shareInstance.currentCommand = Command.READ_UUID
//        BLEManager.default().sendData(toDevice1: "027B1010000010", device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== readDeviceUUID =====================")
//    }
//
//    static func writeUUID() {
//        BLEWrapManager.shareInstance.currentCommand = Command.WRITE_UUID
//        let uuid = UUID()
//        let uuidString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
//        let command = "027B001000" + uuidString
//        BLEManager.default().sendData(toDevice1: command, device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== writeUUID =====================")
//    }
//
//    static func readStatus() {
//        BLEWrapManager.shareInstance.currentCommand = Command.READ_STATUS
//        BLEManager.default().sendData(toDevice1: "027102", device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== readStatus =====================")
//    }
//
//    static func readConfig(){
//        BLEWrapManager.shareInstance.currentCommand = Command.READ_CONFIG
//        BLEManager.default().sendData(toDevice1: "0275000030000050", device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== readConfig =====================")
//    }
//
//    static func readMemoDataHead(){
//        BLEWrapManager.shareInstance.currentCommand = Command.READ_MEMO_HEAD
//        BLEManager.default().sendData(toDevice1: "02750000304A0014", device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== readMemoDataHead =====================")
//    }
//
//    static func readMemoDataConent(recievedCount:Int, count:Int){
//        BLEWrapManager.shareInstance.currentCommand = Command.READ_MEMO_DATA
//        let readCommand = "0275"
//        let startAddr = 0x304A + 0x14 + recievedCount
//        let startAddrString = String(format:"%08X", startAddr)
//        let readLen = String(format:"%04X", count)
//        let command = readCommand + startAddrString + readLen
//        BLEManager.default().sendData(toDevice1: command, device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== readMemoDataConent =====================")
//    }
//
//    static func writeConfig(dateTime:Date,
//                            latency:Int,
//                            sampleIntervale:Int,
//                            temperatureUpLimit:Float,
//                            temperatureLowLimit:Float,
//                            humidityUpLimit:Float,
//                            humidityLowLimit:Float,
//                            config:DeviceConfig){
//        BLEWrapManager.shareInstance.currentCommand = Command.WRITE_CONFIG
//        let sysInit = initTagData(dateTime: dateTime,
//                                  latency: latency,
//                                  sampleIntervale: sampleIntervale,
//                                  temperatureUpLimit: temperatureUpLimit,
//                                  temperatureLowLimit: temperatureLowLimit,
//                                  humidityUpLimit: humidityUpLimit,
//                                  humidityLowLimit: humidityLowLimit)
//        let textMemo = initMemoData(config:config)
//        let command = sysInit + textMemo
//        BLEManager.default().sendData(toDevice1: command, device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== writeConfig =====================")
//
//    }
//
//    static func startTag(){
//        BLEWrapManager.shareInstance.currentCommand = Command.START_TAG
//        BLEManager.default().sendData(toDevice1: "027100", device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== startTag =====================")
//    }
//
//    static func stopTag(){
//        BLEWrapManager.shareInstance.currentCommand = Command.STOP_TAG
//        BLEManager.default().sendData(toDevice1: "027101", device: BLEWrapManager.shareInstance.peripheral)
//        print("=============== stopTag =====================")
//    }
//
//    @discardableResult
//    static func clearData(index:Int) -> Bool{
//        let startAddr = 0x4000 + 0x4000*index
//        let endAddr = 0x1ec480
//        if (startAddr < endAddr) {
//            let addr = String(startAddr,radix:16)
//            let command = "0274" + String(repeating: "0", count: 8-addr.count) + addr
//            BLEWrapManager.shareInstance.currentCommand = Command.CLEAR_DATA
//            BLEManager.default().sendData(toDevice1: command, device: BLEWrapManager.shareInstance.peripheral)
//            print("=============== clearData address:\(addr)) =====================")
//            return true
//        }else{
//            return false
//        }
//    }
//
//    @discardableResult
//    static func readMonitoringData(index:Int) -> Bool{
//        let readLen = 0x00B4
//        let startAddr = 0x4000 + readLen*index
//        let endAddr = 0x1ec480
//        if startAddr < endAddr {
//            let addr = String(format:"%08X", startAddr)
//            let len = String(format:"%04X", readLen)
//            let command = "0275" + addr + len
//            BLEWrapManager.shareInstance.currentCommand = Command.READ_DATA
//            BLEManager.default().sendData(toDevice1: command, device: BLEWrapManager.shareInstance.peripheral)
//            print("=============== readMonitoringData:\(addr)) - len:\(len)=====================")
//            return true
//        }
//        else{
//            return false
//        }
//    }
//
//    //MARK: - Command Code
//
//    /// Init Tag Data
//    ///
//    /// - Parameter dateTime: 0020180404110000
//
//    static func initTagData(dateTime:Date,
//                            latency:Int,
//                            sampleIntervale:Int,
//                            temperatureUpLimit:Float,
//                            temperatureLowLimit:Float,
//                            humidityUpLimit:Float,
//                            humidityLowLimit:Float) -> String{
//        //        (1)027A00003000(2)0000(3)0001(4)FFFC
//        //        (5)FFFD(6)0020180404110000(7)000A(8)0001
//        //        (9)FFFFFFFFFFFFFFFF(10)FFFFFFFFFFFFFFFF(11)FFFB(12)0000
//        //        (13)0000(14)0000(15)0000(16)0000
//        //        (17)0000(18)0000(19)0000(20)0000
//        //        (21)00001000(22)00001000(23)00000000(24)00000000
//        //        (25)00(26)00"
//        let header = "027A00003000"     //1.自定义写指令帧头+地址
//        let fileDescLen = "0000"        //2.文件描述长度
//        let fileCodeType = "0001"       //3.文件编码类型
//        let fileProperty = "FFFC"       //4.文件属性
//
//        let startMode = "FFFD"          //5.启动方式
//        let datetimeCode = initDateCode(date: dateTime)                     //6.设置时间2018年4月4号11点00分00秒
//        let latencyCode = String(format:"%04X", latency)    //7.延迟时间10秒
//        let sampleIntervaleCode = String(format:"%04X", sampleIntervale>0 ? sampleIntervale : 1 )    //8.采样间隔1秒
//
//        let smapleStartTime = "FFFFFFFFFFFFFFFF"    //9.起始时间：卡片开启采集工作时写入 16bit
//        let stopTime = "FFFFFFFFFFFFFFFF"           //10.停止时间 :未用到 16bit
//        let stopMode = "FFFB"                       //11.停止方式
//        let temperatureUpLimitCode = String(format:"%04X", Int(temperatureUpLimit*100))              //12.温度上限
//
//        let allowTempBeyondUpLimit = "0000"         //13. 允许温湿度超上限时间:未用到
//        let temperatureLowLimitCode = String(format:"%04X", Int(temperatureLowLimit*100))            //14.温度下限
//        let allowTempBeyondLowLimit = "0000"        //15. 允许温湿度超下限时间:未用到
//        let humidityUpLimitCode = String(format:"%04X", Int(humidityUpLimit*100))                 //16.湿度上限
//
//        let allowHumidityBeyondUpLimit = "0000"     //17.允许湿度超上限时间:未用到
//        let humidityLowLimitCode = String(format:"%04X", Int(humidityLowLimit*100))               //18.湿度下限
//        let allowHumidityBeyondLowLimit = "0000"    //19:允许湿度超下限时间:未用到
//        let allowBeyondTime = "0000"                //20.允许的总超限时间:未用到
//
//        let sampleStartAddr = "00004000"            //21.采样数据起始页的地址
//        let stopAddress = "00001000"                //22.4字节的终止地址
//        let smapleLen   = "00000000"                //23.4字节采样长度:未用到
//        let valideStopAddr = "00000000"             //24.有效数据终止地址:未用到
//
//        let byteFlag = "00"                         //25.1字节校时标识:未用到
//        let validFlag = "00"                        //26.数据项有效性标识:未用到
//
//        return header + fileDescLen + fileCodeType + fileProperty +
//            startMode + datetimeCode + latencyCode + sampleIntervaleCode +
//            smapleStartTime + stopTime + stopMode + temperatureUpLimitCode +
//            allowTempBeyondUpLimit + temperatureLowLimitCode + allowTempBeyondLowLimit + humidityUpLimitCode +
//            allowHumidityBeyondUpLimit + humidityLowLimitCode + allowHumidityBeyondLowLimit + allowBeyondTime +
//            sampleStartAddr + stopAddress + smapleLen + valideStopAddr +
//            byteFlag + validFlag
//    }
//
//    static func initMemoData(config:DeviceConfig) -> String {
//        //初始化区域总共 起始地址3000 4000开始记录温度湿度数据，总长度1K
//        //180 是初始化芯片所用的长度
//        //16 是保留的字节数
//        //4 是 本文长度 字节 和 文本属性字节
//        let maxTextLen = 0x1000 - 80 - 16 - 4
//
//        let reserved = String(repeating: "FF", count: 16)
//        let dataPrepared:Array<String> = getMemoArray(config)
//        let dataString = dataPrepared.joined(separator: ";")
//        var data = dataString.data(using: .utf8)!.hexString()
//        var dataLen = data.count/2
//        if data.count/2 > maxTextLen {
//            dataLen = maxTextLen
//            data = data.substring(from: 0, to: dataLen*2)
//        }
//        return reserved + String(format:"%04X", dataLen) + "FFFF" + data
//    }
//
//    static private func getMemoArray(_ config:DeviceConfig) -> Array<String>{
//        let userId:String = { if config.userId.count == 0{return " "}else{return config.userId}}()
//        let goodNumber:String = { if config.goodNumber.count == 0{return " "}else{return config.goodNumber}}()
//        var orderTime:String = " "
//        if config.orderTime != nil {
//            orderTime = config.orderTime!.toLocalString()
//        }
//        let companyName:String = { if config.companyName.count == 0{return " "}else{return config.companyName}}()
//        let productName:String = { if config.productName.count == 0{return " "}else{return config.productName}}()
//        let creator:String = { if config.creator.count == 0{return " "}else{return config.creator}}()
//        let shipAddress:String = { if config.shipAddress.count == 0{return " "}else{return config.shipAddress}}()
//        let deliveryAddress:String = { if config.deliveryAddress.count == 0{return " "}else{return config.deliveryAddress}}()
//        let note:String = { if config.note.count == 0{return " "}else{return config.note}}()
//        return [userId,goodNumber,orderTime,companyName,productName ,creator,shipAddress,deliveryAddress,note]
//    }
//
//    static func initDateCode(date:Date)->String {
//        //        设置时间2018年4月4号11点00分00秒 -> 0020180404110000
//        let formate = DateFormatter()
//        formate.dateFormat = "00yyyyMMddHHmmss"
//        return formate.string(from:date)
//    }
//
//
//
//
////    static let CHECK_RTC = "027103"+"201804" + "10170500"
////    static let CHECK_SENSOR = "027104"
////    static let CHECK_RTC_TIME = "027105"
////    static let DEBUG = "027106"
//}
