//
//  LocationViewController.swift
//  WeatherApp
//
//  Created by Cristian Costa on 05/12/2021.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionViewLocation: UICollectionView!
    var weatherManager = WeatherManager()
    private let reuseIdentifierLocation = "CellLocation"
    var locationManager = CLLocationManager()
    var cityArray = [LocationModel]()
    var cityArrayDB = [LocationModel]()
    
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewLocation.dataSource = self
        collectionViewLocation.delegate = self
        let currentLocation = locationManager.location
        let currentLatitude = Double((currentLocation?.coordinate.latitude)!)
        let currentLongitude = Double((currentLocation?.coordinate.longitude)!)
        let location = LocationModel(city: "Mi ubicacion", cord: [currentLongitude, currentLatitude])
        cityArray.append(location)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "continueSegue", sender: self)
    }
    
    @IBAction func unwindToLocation(_ sender: UIStoryboardSegue) {
        collectionViewLocation.reloadData()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - CollectionViewDelegate
extension LocationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentIndex = indexPath.row
        performSegue(withIdentifier: "unwindMainWather", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindMainWather" {
            let destinationVC = segue.destination as! WeatherViewController
            let cityTotal = cityArray + cityArrayDB
            destinationVC.locationToShow = cityTotal[currentIndex]
        }
    }
}

//MARK: - CollectionViewDataSource
extension LocationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cityTotal = cityArray + cityArrayDB
        return cityTotal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let safeCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierLocation, for: indexPath) as? CustomCollectionViewCellLocation {
            let cityTotal = cityArray + cityArrayDB
            let city = cityTotal[indexPath.row].getPlace()
            print(cityTotal[indexPath.row].getCoordinates())
            safeCell.configure(city: city)
            cell = safeCell
        }
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension LocationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return CGFloat(1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}
