//
//  IPInfoModel.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Foundation

struct IPInfo: Codable {
    let ip: String
    let ipNumber: String
    let ipVersion: Int
    let countryName: String
    let countryCode2: String
    let isp: String
    let responseCode: String
    let responseMessage: String
}
