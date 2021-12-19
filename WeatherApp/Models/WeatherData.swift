//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Cristian Costa on 09/11/2021.
//

import Foundation

struct WeatherData: Codable {
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
}

struct Current: Codable {
    let temp: Double
    let feels_like: Double
    let weather: [Weather]
    let sunrise: Double
    let sunset: Double
}

struct Weather: Codable {
    let id: Int
    let description: String
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Int
    let temp: Temp
    let weather: [Weather]
}

struct Temp: Codable {
    let min: Double
    let max: Double
}
