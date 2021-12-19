//
//  LocationData.swift
//  WeatherApp
//
//  Created by Cristian Costa on 04/12/2021.
//

import Foundation

struct LocationData: Codable {
    let features: [Features]
}

struct Features: Codable {
    let place_name: String
    let center: [Double]
}
