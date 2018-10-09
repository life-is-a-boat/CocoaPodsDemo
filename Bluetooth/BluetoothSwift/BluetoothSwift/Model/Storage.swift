//
//  Storage.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/6/1.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation
import FMDB

class DeviceConfig {
    var uuidString:String = ""            //配置Id 也是 写到 初始化 数据部分的UUID，每次配置生成一个新的ID
    var userId:String = ""          //用户Id
    var goodNumber:String = ""      //货物单号
    var orderTime:Date? = nil       //运单时间
    var companyName:String = ""     //公司名称
    var productName:String = ""     //产品名称
    var creator:String = ""         //创建人
    var createTime:Date = Date()    //创建/修改 时间
    var configDate:Date = Date()    //配置时间
    var shipAddress:String = ""     //发货地址
    var deliveryAddress:String = "" //收货地址
    var note = ""                   //备注
    
    var latency = 0                 //延迟启动
    var interval = 0                //采集间隔
    var tempUpLimit = 0.0           //温度上限
    var tempLowLimit = 0.0          //温度下限
    var humUpLimit = 0.0            //湿度上限
    var humLowLimit = 0.0           //湿度下限
    
    var valid:Bool = true   //是否有效，如果更新后，旧的配置会设置成无效
    
    func orderTimeString() ->String? {
        guard (orderTime != nil) else { return nil }
        let formate = DateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm"
        return formate.string(from: orderTime!)
    }
    
    func createTimeString() ->String? {
        let formate = DateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm"
        return formate.string(from: createTime)
    }
    
    func initWithDB(_ rs:FMResultSet) {
        uuidString = rs.string(forColumn: "id") ?? ""
        userId = rs.string(forColumn: "user_id") ?? ""
        goodNumber = rs.string(forColumn: "good_no") ?? ""
        orderTime = rs.date(forColumn: "order_time")
        companyName = rs.string(forColumn: "company_name") ?? ""
        productName = rs.string(forColumn: "product_name") ?? ""
        creator = rs.string(forColumn: "creator") ?? ""
        createTime = rs.date(forColumn: "create_time")!
        configDate = rs.date(forColumn: "config_date")!
        shipAddress = rs.string(forColumn: "ship_addr") ?? ""
        deliveryAddress = rs.string(forColumn: "delivery_addr") ?? ""
        note = rs.string(forColumn: "note") ?? ""
        valid = rs.bool(forColumn: "valid")
        
        latency = Int(rs.int(forColumn: "latency"))
        interval = Int(rs.int(forColumn: "interval"))
        tempUpLimit = rs.double(forColumn: "temp_up_limit")
        tempLowLimit = rs.double(forColumn: "temp_low_limit")
        humUpLimit = rs.double(forColumn: "hum_up_limit")
        humLowLimit = rs.double(forColumn: "hum_low_limit")
    }
}

class StatisticInfo {
    var id:Int?              //统计信息数据快的Id
    var uuid:String?    //统计数据对应的配置信息
    var goodNumber:String?
    var companyName:String?
    var productName:String?
    var creator:String?
    var orderTime:Date?
    var uploadTime:Date?        //上传统计数据的时间
    
    func initWithDB(_ rs:FMResultSet) {
        id = Int(rs.int(forColumn: "id"))
        uuid = rs.string(forColumn: "uuid")
        goodNumber = rs.string(forColumn: "good_no")
        companyName = rs.string(forColumn: "company_name")
        productName = rs.string(forColumn: "product_name")
        creator = rs.string(forColumn: "creator")
        orderTime = rs.date(forColumn: "order_time")
        uploadTime = rs.date(forColumn: "upload_time")
    }
    
}

class StatisticData {
    var id:Int?              //这一条数据的Id
    var statisticId:Int?     //统计数据块的Id
    var time:Date?              //数据时间
    var temperature:Double?        //温度数据
    var humidity:Double?           //湿度数据
    
    func initWithDB(_ rs:FMResultSet) {
        id = Int(rs.int(forColumn: "id"))
        statisticId = Int(rs.int(forColumn: "statisticId"))
        temperature = rs.double(forColumn: "temperature")
        humidity = rs.double(forColumn: "humidity")
        time = rs.date(forColumn: "time")
    }
}

class Storage {
    static let instance = Storage()
    private let configTable = "config"
    private let statisticInfoTable = "statisticinfo"
    private let statisticDataTable = "statisticdata"
    
    let db:FMDatabase = {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        
        return FMDatabase(url: fileURL)
    }()
    
    private init() {
        
        guard db.open() else {
            print("Unable to open database")
            return
        }
        
        var sql = ""
        [configTable,statisticInfoTable,statisticDataTable]
            .forEach { (table) in
                if(!db.tableExists(table)){
                    switch table {
                    case configTable :
                        sql +=  ("CREATE TABLE \(table) ( " +
                                "'id'           varchar(200) NOT NULL PRIMARY KEY," +
                                "'user_id'      varchar(200)    NULL, " +
                                "'good_no'      varchar(200)    NULL, " +
                                "'order_time'   datetime        NULL, " +
                                "'company_name' varchar(200)    NULL, " +
                                "'product_name' varchar(200)    NULL, " +
                                "'creator'      varchar(200)    NULL, " +
                                "'create_time'  datetime        NULL, " +
                                "'config_date'  datetime        NULL, " +
                                "'ship_addr'    varchar(200)    NULL, " +
                                "'delivery_addr' varchar(200)   NULL, " +
                                "'note'         text            NULL, " +
                                "'latency'      integer         default 0, " +
                                "'interval'     integer         default 0, " +
                                "'temp_up_limit'    float       default 0, " +
                                "'temp_low_limit'   float       default 0, " +
                                "'hum_up_limit'     float       default 0, " +
                                "'hum_low_limit'    float       default 0, " +
                                "'valid'        boolean         default 1); ")
                    case statisticInfoTable:
                        sql += ("CREATE TABLE \(table) ( " +
                            "'id'           integer NOT NULL PRIMARY KEY AUTOINCREMENT," +
                            "'uuid'         varchar(200) NOT NULL, " +
                            "'good_no'      varchar(200)     NULL, " +
                            "'company_name' varchar(200)     NULL, " +
                            "'product_name' varchar(200)     NULL, " +
                            "'creator'      varchar(200)     NULL, " +
                            "'order_time'   datetime        NULL, " +
                            "'upload_time'  datetime        NULL); ")
                    case statisticDataTable:
                        sql +=  ("CREATE TABLE \(table) ( " +
                            "'id'           integer NOT NULL PRIMARY KEY AUTOINCREMENT," +
                            "'statisticId'  integer NOT NULL, " +
                            "'time'         datetime        NULL, " +
                            "'temperature'  float         NULL, " +
                            "'humidity'     float         NULL); ")
                    default : break
                    }
                }
        }
        
        if sql.trimmingCharacters(in: .whitespaces).count > 0 {
            db.executeStatements(sql)
        }
    }
    
    deinit {
//        db.close()
    }
    
    func fetchAllDeviceConfigs() -> Array<DeviceConfig> {
        var configs = Array<DeviceConfig>()
        let rs = try? db.executeQuery("SELECT * FROM \(configTable) ORDER BY create_time DESC", values: [])
        if rs != nil {
            while(rs!.next()){
                let config = DeviceConfig()
                config.initWithDB(rs!)
                configs.append(config)
            }
        }
        
        return configs
    }
    
    func config(uuid:String) -> DeviceConfig? {
        let uuidString = uuid.uppercased()
//        print("get config uppercased:\(uuidString)")
        var config:DeviceConfig?
        let rs = try? db.executeQuery("SELECT * FROM \(configTable) WHERE id=?", values: [uuidString])
        if rs != nil {
            while(rs!.next()){
                config = DeviceConfig()
                config!.initWithDB(rs!)
            }
        }
        
        return config
    }
    
    func deleteConfig(_ uuid:String){
        let uuidString = uuid.uppercased()
        db.executeUpdate("DELETE FROM \(configTable) WHERE id=?", withArgumentsIn: [uuidString])
    }
    
    func fetchStatistic(statisticId:String) -> Array<StatisticData>? {
        return nil
    }
    
    @discardableResult
    func saveConfig(config:DeviceConfig) -> Bool{
        let uuidString = config.uuidString.uppercased()
        print("save config:\(uuidString)")
        
        let insertSql = "INSERT OR IGNORE INTO \(configTable) " +
                        "('id','user_id','good_no','order_time','company_name'," +
                        "'product_name','creator','create_time','config_date','ship_addr'," +
                        "'delivery_addr','note','latency','interval'," +
                        "'temp_up_limit','temp_low_limit','hum_up_limit','hum_low_limit'" +
                        ") VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        
        let updateSql = "UPDATE \(configTable) SET " +
                        "'user_id'=?,'good_no'=?,'order_time'=?,"  +
                        "'company_name'=?, 'product_name'=?,'creator'=?,'create_time'=?,'config_date'=?," +
                        "'ship_addr'=?, 'delivery_addr'=?,'note'=?,'latency'=?," +
                        "'interval'=?, 'temp_up_limit'=?,'temp_low_limit'=?,'hum_up_limit'=?,'hum_low_limit'=?" +
                        " where id=?;"
        
        
        db.executeUpdate(insertSql, withArgumentsIn: [uuidString,config.userId,config.goodNumber,config.orderTime as Any,config.companyName,config.productName,config.creator,config.createTime,config.configDate as Any,config.shipAddress,config.deliveryAddress,config.note,config.latency,config.interval,config.tempUpLimit,config.tempLowLimit,config.humUpLimit,config.humLowLimit])
        
        db.executeUpdate(updateSql, withArgumentsIn: [config.userId,config.goodNumber,config.orderTime as Any,config.companyName,config.productName,config.creator,config.createTime,config.configDate as Any,config.shipAddress,config.deliveryAddress,config.note,config.latency,config.interval,config.tempUpLimit,config.tempLowLimit,config.humUpLimit,config.humLowLimit,uuidString])
        return true
    }
    
    private func saveStaticInfo(config:DeviceConfig){
        let uuidString = config.uuidString.uppercased()
        print("saveStaticHeader:\(uuidString)")
        let insertSql = "INSERT INTO \(statisticInfoTable) " +
            "('uuid','good_no','company_name','product_name'," +
            "'creator','order_time','upload_time'" +
        ") VALUES(?,?,?,?,?,?,?);"
        db.executeUpdate(insertSql, withArgumentsIn: [uuidString,config.goodNumber,config.companyName,config.productName,config.creator,config.orderTime as Any,Date()])
    }
    
    //MARK: - Statistic
    func statisticAllInfo() -> Array<StatisticInfo> {
        var data = Array<StatisticInfo>()
        let rs = try? db.executeQuery("SELECT * FROM \(statisticInfoTable) ORDER BY upload_time DESC", values: [])
        if rs != nil {
            while(rs!.next()){
                let info = StatisticInfo()
                info.initWithDB(rs!)
                data.append(info)
            }
        }
        return data
    }
    
    func statisticInfos(uuid:String) -> Array<StatisticInfo> {
        let uuidString = uuid.uppercased()
        var data = Array<StatisticInfo>()
        let rs = try? db.executeQuery("SELECT * FROM \(statisticInfoTable) WHERE uuid=? ORDER BY upload_time DESC", values: [uuidString])
        if rs != nil {
            while(rs!.next()){
                let info = StatisticInfo()
                info.initWithDB(rs!)
                data.append(info)
            }
        }
        return data
    }
    
    func statisticDatas(id:Int,start:Date?,end:Date?) -> Array<StatisticData>{
        var data = Array<StatisticData>()
        let startTime = start != nil ? start : Date(timeIntervalSince1970: TimeInterval(0))
        let endTime = end != nil ? end : Date()
        let rs = try? db.executeQuery("SELECT * FROM \(statisticDataTable) WHERE statisticId = ? and time > ? and time < ? ORDER BY time DESC", values: [id,startTime!,endTime!])
        if rs != nil {
            while(rs!.next()){
                let info = StatisticData()
                info.initWithDB(rs!)
                data.append(info)
            }
        }
        return data
    }
    
    func statisticDatas(id:Int) -> Array<StatisticData>{
        var data = Array<StatisticData>()
//        let rs = try? db.executeQuery("SELECT * FROM \(statisticDataTable) WHERE id=? ORDER BY time DESC", values: [id])
        let rs = try? db.executeQuery("SELECT * FROM \(statisticDataTable) WHERE statisticId = ? ORDER BY time DESC", values: [id])
        if rs != nil {
            while(rs!.next()){
                let info = StatisticData()
                info.initWithDB(rs!)
                data.append(info)
            }
        }
        return data
    }
    
    func deletStatisticData(id:Int){
        db.executeUpdate("DELETE FROM \(statisticInfoTable) WHERE id=?", withArgumentsIn: [id])
        db.executeUpdate("DELETE FROM \(statisticDataTable) WHERE statisticId=?", withArgumentsIn: [id])
    }
    
    private func staticInfoId() -> Int {
        var id:Int = 0
        let rs = try?db.executeQuery("SELECT id FROM \(statisticInfoTable) ORDER BY upload_time DESC LIMIT 1 OFFSET 0", values: [])
        if rs != nil {
            while(rs!.next()){
                id = Int(rs!.int(forColumn: "id"))
            }
        }
        return id
    }
    
    func uploadData(config:DeviceConfig,startTime:Date,lantency:Int,intervale:Int,data:Array<StatisticData>) -> Bool {
        saveStaticInfo(config: config)
        let id = staticInfoId()
        
        var isRollBack = false
        db.beginTransaction()
        do {
            var time = Date().addingTimeInterval(TimeInterval(lantency*60))
            for item in data {
                let temp = item.temperature ?? 0
                let hum = item.humidity ?? 0
                time = time.addingTimeInterval(TimeInterval(intervale*60))
                let insertSql = "INSERT INTO \(statisticDataTable) " +
                    "('statisticId','time','temperature','humidity'" +
                ") VALUES(?,?,?,?);"
                try db.executeUpdate(insertSql, values: [id,time,temp,hum])
            }
        } catch {
            isRollBack = true
            db.rollback()
        }
        
        if !isRollBack{
            db.commit()
        }
        
        return !isRollBack
    }
    
    func statisticDataList() -> Array<StatisticInfo>? {
        return nil
    }
    
}
