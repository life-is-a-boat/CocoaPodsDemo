//
//  DataExt.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/6/1.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation

extension Data {
    ///Data转HexString
    func hexString() -> String {
        return self.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: self.count)
            return buffer.map{String(format: "%02hhx", $0)}.reduce("", {$0 + $1})
        })
    }
    
    func Int16()->Int16 {
        return self.withUnsafeBytes {
            (pointer: UnsafePointer<Int16>) -> Int16 in
            return pointer.pointee // reading four bytes of data
        }
    }
}
