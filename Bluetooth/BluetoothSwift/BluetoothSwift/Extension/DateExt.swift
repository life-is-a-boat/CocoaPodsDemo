//
//  DateExt.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/6/1.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation

extension Date {
    func toLocalString() -> String {
        let formate = DateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm"
        return formate.string(from: self)
    }
}
