//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Cristian Costa on 04/12/2021.
//

import Foundation

class LocationModel {
    private var place: String?
    private var longitude: Double?
    private var latitude: Double?

    init(city: String? = nil, long: Double? = nil, lat: Double? = nil) {
        place = city
        longitude = long
        latitude = lat
    }
    
    func getPlace() -> String {
        return place!
    }
    
    func getLat() -> Double {
        return latitude!
    }
    
    func getLon() -> Double {
        return longitude!
    }
    
    func setPlace(pl: String) {
        place = pl
    }
    
    func setLon(lon: Double) {
        longitude = lon
    }
    
    func setLat(lat: Double) {
        latitude = lat
    }
}
