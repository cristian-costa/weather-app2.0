//
//  ViewController.swift
//  WeatherApp
//
//  Created by Cristian Costa on 09/11/2021.
//

import UIKit
import CoreLocation

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
    
    var locationToShow: LocationModel?
    var currentLat: Double?
    var currentLon: Double?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("WILL APPEAR?")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if locationToShow == nil {
            print("REQUEST LOCATION")
            locationManager.requestLocation()
        } else {
            print("LOAD LOCATION")
            weatherManager.fetchWeather(latitude: (locationToShow?.getLat())!, longitute: (locationToShow?.getLon())!)
            navigationItem.title = locationToShow?.getPlace()
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
            self.tempLabel.text = weather.getCurrentTemp()
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
                var hour: Int = 999
                if indexPath.row != 0 {
                    hour = Calendar.current.component(.hour, from: hourlyArr[indexPath.row].getTime())
                }
                let temp = hourlyArr[indexPath.row].temperatureHourlyString()
                let time = String(hour)
                safeCell.imageLabel.image = UIImage(named: hourlyArr[indexPath.row].conditionName())
//                print(hourlyArr[indexPath.row].conditionName())
//                print(hour)
//                print(Calendar.current.component(.hour, from: weatherArr.getTimeSunrise()))
//                if hourlyArr[indexPath.row].conditionName() == "sun.max" && (hour < Calendar.current.component(.hour, from: weatherArr.getTimeSunrise()) && hour > Calendar.current.component(.hour, from: weatherArr.getTimeSunset())) {
//                    safeCell.imageLabel.image = UIImage(named: "moon.stars.fill")
//                }
                safeCell.configure(time: time, temp: temp)
                cell = safeCell
            }
        }
        
        if collectionView == collectionViewDaily {
            if let safeCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierDaily, for: indexPath) as? CustomCollectionViewCellDaily {
                let day = dailyArr[indexPath.row].getTime()
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
        var month = dateFormatterNameMonth.string(from: currentDateTime)
        
        switch month {
            case "January":
                month = "Enero"
            case "February":
                month = "Febrero"
            case "March":
                month = "Marzo"
            case "April":
                month = "Abril"
            case "May":
                month = "Mayo"
            case "June":
                month = "Junio"
            case "July":
                month = "Julio"
            case "August":
                month = "Agosto"
            case "September":
                month = "Septiembre"
            case "October":
                month = "Octubre"
            case "November":
                month = "Noviembre"
            case "December":
                month = "Diciembre"
            default:
                month = "Diciembre"
        }
        
        switch date {
            case "Monday":
                date = "Lunes, \(numberDay) de \(month)"
            case "Tuesday":
                date = "Martes, \(numberDay) de \(month)"
            case "Wednesday":
                date = "Miércoles, \(numberDay) de \(month)"
            case "Thursday":
                date = "Jueves, \(numberDay) de \(month)"
            case "Friday":
                date = "Viernes, \(numberDay) de \(month)"
            case "Saturday":
                date = "Sábado, \(numberDay) de \(month)"
            case "Sunday":
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
