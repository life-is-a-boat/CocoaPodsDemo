//
//  StringExt.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/5/25.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation

extension String {
//    func HexStringToData() -> Data? {
//        guard let chars = cString(using: String.Encoding.utf8) else { return nil}
//        var i = 0
//        let length = count
//        
//        let data = NSMutableData(capacity: length/2)
//        var byteChars: [CChar] = [0, 0, 0]
//        
//        var wholeByte: CUnsignedLong = 0
//        
//        while i < length {
//            byteChars[0] = chars[i]
//            i+=1
//            byteChars[1] = chars[i]
//            i+=1
//            wholeByte = strtoul(byteChars, nil, 16)
//            data?.append(&wholeByte, length: 1)
//        }
//        return data! as Data
//    }
    
    func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            
            return String(subString)
        } else {
            return self
        }
    }
    
    func substring(from start:Int,to end:Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: end)
        let subString = self[startIndex..<endIndex]
        return String(subString)
    }
    
    func toLocalDate() ->Date? {
        let formate = DateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm"
        return formate.date(from: self)
    }
    
    func trim() -> String{
        return self.trimmingCharacters(in: .whitespaces)
    }
}
