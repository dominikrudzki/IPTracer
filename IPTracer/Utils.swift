//
//  Utils.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Foundation

class Utils {
    static func formatTimeElapsed(_ timeElapsed: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 1

        return formatter.string(from: timeElapsed) ?? ""
    }
}
