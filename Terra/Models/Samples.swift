//
//  Samples.swift
//  Terra
//
//  Created by Elliott Yu on 24/09/2021.
//

import Foundation

struct HRV: Codable{
    var sdnn: Double
    var timestamp: Date
}

struct HeartRate: Codable{
    var timestamp: Date
    var bpm: Int
}

struct Samples: Codable{
    var hrv: [HRV]
    var heartRates: [HeartRate]
}
