//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Cristian Costa on 05/12/2021.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var locationManager = LocationManager()
    
    var locationArray = [LocationModel]()
    
    let segueCategory = "segueSearchToAdd"
    
    var locationToSearch = LocationModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        locationManager.delegate = self
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text! == "") {
            locationArray = []
        }
        locationArray = []
        locationManager.fetchWeather(city: searchBar.text!)
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = locationArray[indexPath.row].getPlace()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueCategory, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AddWeatherViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.newCity.setPlace(pl: locationArray[indexPath.row].getPlace())
            destinationVC.newCity.setLon(lon: locationArray[indexPath.row].getLon())
            destinationVC.newCity.setLat(lat: locationArray[indexPath.row].getLat())
        }
    }
}

extension SearchViewController: LocationManagerDelegate {
    func didUpdateLocation(_ locationManager: LocationManager, location: [LocationModel]) {
        DispatchQueue.main.async {
            for i in 0...location.count-1 {
                let city = location[i].getPlace()
                let latitute = location[i].getLat()
                let longitute = location[i].getLon()
                let locationObject = LocationModel(city: city, long: longitute, lat: latitute)
                self.locationArray.append(locationObject)
            }
            self.tableView.reloadData()
        }
    }
    
    func didFailWithErrorLocation(error: Error) {
        print(error)
    }
}
