//
//  location.swift
//  WeatherApp
//
//  Created by Cristian Costa on 04/12/2021.
//

import Foundation

protocol LocationManagerDelegate {
    func didUpdateLocation(_ locationManager: LocationManager, location: [LocationModel])
    func didFailWithErrorLocation(error: Error)
}

struct LocationManager {
    var delegate: LocationManagerDelegate?
    let token: String = "pk.eyJ1IjoiY3Jpc3RpYW5jb3N0YTk0IiwiYSI6ImNrcGFmNHBweDBwMmoyeW11bnhhZXB6M3gifQ.olOZwocaBmIv7JsK924Cyg"
    let locationURL = "https://api.mapbox.com/geocoding/v5/mapbox.places/"
    
    func fetchWeather(city: String) {
        let urlString = "\(locationURL)\(city).json?access_token=\(token)"
        print(urlString)
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithErrorLocation(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let location = self.parseJSON(safeData) {
                        self.delegate?.didUpdateLocation(self, location: location)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ locationData: Data) -> [LocationModel]? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(LocationData.self, from: locationData)
            var cityArray = [LocationModel]()
            for i in 0...decodedData.features.count-1 {
                let placeName = decodedData.features[i].place_name
                let longitude = decodedData.features[i].center[0]
                let latitude = decodedData.features[i].center[1]

                let cityInstance = LocationModel(city: placeName, long: longitude, lat: latitude)
                cityArray.append(cityInstance)
            }
            return cityArray
        } catch {
            delegate?.didFailWithErrorLocation(error: error)
            return nil
        }
    }
}
