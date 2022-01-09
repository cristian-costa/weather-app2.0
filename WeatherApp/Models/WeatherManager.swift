//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Cristian Costa on 09/11/2021.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    let token: String = "29af9d657d409e90b699b86e4fe0e4b3"
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=minutely&units=metric&lang=es"
    
    func fetchWeather(latitude: CLLocationDegrees, longitute: CLLocationDegrees) {
        let urlString = "\(weatherURL)&appid=\(token)&lat=\(latitude)&lon=\(longitute)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let currentId = decodedData.current.weather[0].id
            let currentDescription = decodedData.current.weather[0].description
            let currentTemp = decodedData.current.temp
            let currentFeelsLike = decodedData.current.feels_like
            var arrayHourlyModel = [HourlyModel]()
            var arrayDailyModel = [DailyModel]()
            let sunrise = decodedData.current.sunrise
            let sunset = decodedData.current.sunset
            
            for i in 0...decodedData.hourly.count-1 {
                let timeHourly = decodedData.hourly[i].dt
                let tempHourly = decodedData.hourly[i].temp
                let weatherHourlyId = decodedData.hourly[i].weather[0].id
                let hourlyModelInstance = HourlyModel(ti: timeHourly, temp: tempHourly, id: weatherHourlyId)
                arrayHourlyModel.append(hourlyModelInstance)
            }
            
            for i in 0...decodedData.daily.count-1 {
                let timeDaily = decodedData.daily[i].dt
                let minDaily = decodedData.daily[i].temp.min
                let maxDaily = decodedData.daily[i].temp.max
                let conditionDailyId = decodedData.daily[i].weather[0].id
                let dailyModelInstance = DailyModel(ti: timeDaily, min: minDaily, max: maxDaily, id: conditionDailyId)
                arrayDailyModel.append(dailyModelInstance)
            }
            
            let weather = WeatherModel(temp: currentTemp, id: currentId, description: currentDescription, hour: arrayHourlyModel, day: arrayDailyModel, feelsLike: currentFeelsLike, sunr: sunrise, suns: sunset)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
    
