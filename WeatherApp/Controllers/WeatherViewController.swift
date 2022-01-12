//
//  ViewController.swift
//  WeatherApp
//
//  Created by Cristian Costa on 09/11/2021.
//

import UIKit
import CoreLocation
import CoreData

class WeatherViewController: UIViewController {
    @IBOutlet weak var collectionViewHourly: UICollectionView!
    @IBOutlet weak var collectionViewDaily: UICollectionView!
    @IBOutlet weak var background: UIImageView!

    //FirstView
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeLbl: UILabel!
    
    //Identifier CollectionViewControllers
    private let reuseIdentifier = "Cell"
    private let reuseIdentifierDaily = "CellDaily"

    //Segue
    let segueLocation = "goToLocation"
    
    var locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    var location = LocationManager()
    var weatherArr = WeatherModel()
    var hourlyArr = [HourlyModel]()
    var dailyArr = [DailyModel]()
    
    var placeToShow: String?
    var latToShow: Double?
    var lonToShow: Double?
    
    var currentLat: Double?
    var currentLon: Double?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationManager.delegate = self
        
        if latToShow == nil && lonToShow == nil || latToShow == 0.0 && lonToShow == 0.0 {
            print("NIL")
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            navigationItem.title = "Mi ubicacion"
            
        } else {
            print("FETCH")
            weatherManager.fetchWeather(latitude: latToShow!, longitute: lonToShow!)
            navigationItem.title = placeToShow
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherManager.delegate = self
        
        mainViewLayer()
        
        collectionViewHourly.dataSource = self
        collectionViewHourly.delegate = self
        
        collectionViewDaily.dataSource = self
        collectionViewDaily.delegate = self
        
        dateLbl.text = getCurrentDate()
        
    }
    
    @IBAction func locationBtnPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: segueLocation, sender: self)
    }
    
    @IBAction func unwindToMainWeather(_ sender: UIStoryboardSegue) {
        collectionViewDaily.reloadData()
        collectionViewHourly.reloadData()
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
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
extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewHourly {
            return hourlyArr.count
        }
        return dailyArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView == collectionViewHourly {
            if let safeCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CustomCollectionViewCell {
                let GMT = 3600
                let hoursGMT = weatherArr.getTimezone() / GMT
                
                //Hour
                let date = hourlyArr[indexPath.row].getTime(timezone: weatherArr.getTimezone())
                let formatter = DateFormatter()
                formatter.dateFormat = "HH"
                formatter.timeZone = TimeZone(secondsFromGMT: weatherArr.getTimezone())
                var hour = formatter.string(from: date)
                
                var dateComponentsHourly = DateComponents()
                dateComponentsHourly.hour = hoursGMT
                let dateHourly = Calendar.current.date(byAdding: .hour, value: hoursGMT, to: date)
                
                //Temp
                let temp = hourlyArr[indexPath.row].temperatureHourlyString()
                if indexPath.row == 0 {
                    hour = "999"
                }
                
                //Image
                var sunrise = Calendar.current.date(byAdding: .hour, value: hoursGMT, to: weatherArr.getTimeSunrise())
                let sunset = Calendar.current.date(byAdding: .hour, value: hoursGMT, to: weatherArr.getTimeSunset())
                sunrise = Calendar.current.date(byAdding: .day, value: 1, to: sunrise!)

                safeCell.imageLabel.image = UIImage(named: hourlyArr[indexPath.row].conditionName())
                
                if hourlyArr[indexPath.row].conditionName() == "sun.max" {
                    print("ENTER IF")
                    if dateHourly! > sunset! && dateHourly! < sunrise! {
                        safeCell.imageLabel.image = UIImage(named: "moon.full")
                    }
                }
                
                safeCell.configure(time: Int(hour)!, temp: temp)
                cell = safeCell
            }
        }
        
        if collectionView == collectionViewDaily {
            if let safeCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierDaily, for: indexPath) as? CustomCollectionViewCellDaily {
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

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            currentLat = location.coordinate.latitude
            currentLon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: currentLat!, longitute: currentLon!)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get users location.")
    }
}

//MARK: - Other Functions
extension WeatherViewController {
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
extension WeatherViewController: UICollectionViewDelegateFlowLayout {
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
