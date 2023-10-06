//
//  Utils.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Foundation

class Utils {
    static func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
