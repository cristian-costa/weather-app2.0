//
//  AddWeatherViewController.swift
//  WeatherApp
//
//  Created by Cristian Costa on 06/12/2021.
//

import UIKit
import CoreData

class AddWeatherViewController: UIViewController {
    @IBOutlet weak var collectionViewDaily: UICollectionView!
    @IBOutlet weak var collectionViewHourly: UICollectionView!
    @IBOutlet weak var background: UIImageView!
    
    //First View
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLbl: UILabel!
    
    var weatherManager = WeatherManager()
    var weatherArr = WeatherModel()
    var hourlyArr = [HourlyModel]()
    var dailyArr = [DailyModel]()
    let indentifierHourly = "CellHourly"
    let indentifierDaily = "CellDaily"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var newPlace: String?
    var newLat: Double?
    var newLon: Double?
    
    var newCity = LocationModelPermanent()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewLayer()
        dateLbl.text = getCurrentDate()
        
        weatherManager.delegate = self
        collectionViewHourly.dataSource = self
        collectionViewHourly.delegate = self
        collectionViewDaily.dataSource = self
        collectionViewDaily.delegate = self
        
        weatherManager.fetchWeather(latitude: newLat!, longitute: newLon!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LocationViewController
        newCity = LocationModelPermanent(context: context)
        newCity.place = newPlace!
        newCity.latitude = newLat!
        newCity.longitude = newLon!
        destinationVC.cityArrayDB.append(newCity)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - WeatherManagerDelegate
extension AddWeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherArr = weather
            let hourlyArray = weather.hourly!
            self.dailyArr = weather.daily!
            self.hourlyArr = Array(hourlyArray.prefix(24))
            self.descriptionLabel.text = weather.getCurrentDescription().capitalized
            self.tempLabel.text = "\(weather.getCurrentTemp())"
            self.maxTempLabel.text = "Máx: \(weather.daily![0].maxTemperatureString())"
            self.minTempLabel.text = "Mín: \(weather.daily![0].minTemperatureString())"
            self.feelsLikeLbl.text = "Sensación térmica: \(weather.getCurrentFeelsLike())º"
            
            if self.weatherArr.getCurrentConditionId() == "sun.max" {
                self.background.image = UIImage(named: "sun.background")
            } else {
                self.background.image = UIImage(named: "cloud.background")
            }
            
            self.collectionViewHourly.reloadData()
            self.collectionViewDaily.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - UICollectionViewDataSource
extension AddWeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewHourly {
            return hourlyArr.count
        }
        return dailyArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView == collectionViewHourly {
            if let safeCell = collectionView.dequeueReusableCell(withReuseIdentifier: indentifierHourly, for: indexPath) as? CustomCollectionViewCell {
                //Hour
                let date = Date(timeIntervalSince1970: Double(hourlyArr[indexPath.row].time))
                let formatter = DateFormatter()
                formatter.dateFormat = "HH"
                formatter.timeZone = TimeZone(secondsFromGMT: weatherArr.getTimezone())
                var hour = formatter.string(from: date)
                            
                //Temp
                let temp = hourlyArr[indexPath.row].temperatureHourlyString()
                if indexPath.row == 0 {
                    hour = "999"
                }
                
                //Image
                var dateComponent = DateComponents()
                dateComponent.day = 1
                let futureDate = Calendar.current.date(byAdding: dateComponent, to: weatherArr.getTimeSunrise())
                
                safeCell.imageLabel.image = UIImage(named: hourlyArr[indexPath.row].conditionName())
                
                if hourlyArr[indexPath.row].conditionName() == "sun.max" {
                    if hourlyArr[indexPath.row].getTime(timezone: weatherArr.getTimezone())
                        > weatherArr.getTimeSunset() && hourlyArr[indexPath.row].getTime(timezone: weatherArr.getTimezone()) < futureDate! {
                        safeCell.imageLabel.image = UIImage(named: "moon.full")
                    }
                }
                
                safeCell.configure(time: Int(hour)!, temp: temp)
                cell = safeCell
            }
        }
        
        if collectionView == collectionViewDaily {
            if let safeCell = collectionView.dequeueReusableCell(withReuseIdentifier: indentifierDaily, for: indexPath) as? CustomCollectionViewCellDaily {
                let day = dailyArr[indexPath.row].getTime(time: weatherArr.getTimezone())
                let min = dailyArr[indexPath.row].minTemperatureString()
                let max = dailyArr[indexPath.row].maxTemperatureString()
                safeCell.imageView.image = UIImage(named: dailyArr[indexPath.row].conditionName())
                safeCell.configure(date: day, min: min, max: max)
                cell = safeCell
            }
        }
        
        return cell
    }
}

//MARK: - Others Functions
extension AddWeatherViewController {
    func mainViewLayer() {
        mainView.layer.cornerRadius = 10.0
        mainView.layer.borderWidth = 5.0
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.masksToBounds = true

        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        mainView.layer.shadowRadius = 2.0
        mainView.layer.shadowOpacity = 0.2
        mainView.layer.masksToBounds = false
        mainView.layer.shadowPath = UIBezierPath(roundedRect: mainView.bounds, cornerRadius: mainView.layer.cornerRadius).cgPath
    }

    func getCurrentDate() -> String {
        let currentDateTime = Date()
        let dateFormatterDay = DateFormatter()
        let dateFormatterNameDay = DateFormatter()
        let dateFormatterNameMonth = DateFormatter()
        
        dateFormatterDay.dateFormat = "d"
        dateFormatterNameDay.dateFormat = "EEEE"
        dateFormatterNameMonth.dateFormat = "MMMM"
        
        let numberDay = dateFormatterDay.string(from: currentDateTime)
        var date = dateFormatterNameDay.string(from: currentDateTime)
        let month = dateFormatterNameMonth.string(from: currentDateTime)
        
        switch date {
            case "lunes":
                date = "Lunes, \(numberDay) de \(month)"
            case "martes":
                date = "Martes, \(numberDay) de \(month)"
            case "miércoles":
                date = "Miércoles, \(numberDay) de \(month)"
            case "jueves":
                date = "Jueves, \(numberDay) de \(month)"
            case "viernes":
                date = "Viernes, \(numberDay) de \(month)"
            case "sábado":
                date = "Sábado, \(numberDay) de \(month)"
            case "domingo":
                date = "Domingo, \(numberDay) de \(month)"
            default:
                date = "Lunes, \(numberDay) de \(month)"
        }
        return date
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AddWeatherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionViewHourly {
            return CGFloat(10)
        } else {
            return CGFloat(10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionViewHourly {
            return CGSize(width: 60, height: 122)
        }
        return CGSize(width: view.frame.width, height: 50)
    }
}
