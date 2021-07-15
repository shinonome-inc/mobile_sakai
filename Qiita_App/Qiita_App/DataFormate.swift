//
//  DataFormate.swift
//  Qiita_App
//
//  Created by Sakai Syunya on 2021/07/01.
//  Copyright © 2021 Sakai Syunya. All rights reserved.
//

import UIKit

class SetDataFormat {
    func dateFormat(format: DateFormatter, defaultFormat: String, formatTarget: String) -> Date {
        format.dateFormat = formatTarget
        format.timeStyle = .none
        format.dateStyle = .medium
        format.locale = Locale(identifier: "ja_JP")
               
        let formattedDate = StringToDate(dateValue: formatTarget, format: defaultFormat)
        
        return formattedDate
    }

    func StringToDate(dateValue: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateValue) ?? Date()
    }
}
