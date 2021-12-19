//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Cristian Costa on 04/12/2021.
//

import Foundation

class LocationModel {
    private dynamic var place: String?
    private dynamic var coordinates: [Double]?
    
    init(city: String? = nil, cord: [Double]? = nil) {
        place = city
        coordinates = cord
    }
    
    func getPlace() -> String {
        return place!
    }
    
    func getCoordinates() -> [Double] {
        return coordinates!
    }
    
    func setPlace(pl: String) {
        place = pl
    }
    
    func setCoordinates(coord: [Double]) {
        coordinates = coord
    }
}
