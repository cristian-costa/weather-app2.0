//
//  LocationViewController.swift
//  WeatherApp
//
//  Created by Cristian Costa on 05/12/2021.
//

import UIKit
import CoreLocation
import CoreData
import SwipeCellKit

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var collectionViewLocation: UICollectionView!
    var weatherManager = WeatherManager()
    private let reuseIdentifierLocation = "CellLocation"
    var locationManager = CLLocationManager()
    var cityArray = [LocationModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cityArrayDB = [LocationModelPermanent]()
    
    var currentIndex = 0

    override func viewDidLoad() {
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        super.viewDidLoad()
        collectionViewLocation.dataSource = self
        collectionViewLocation.delegate = self
        self.loadLocations()
        collectionViewLocation.reloadData()
    }
    
    func saveLocation() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadLocations() {
        let request: NSFetchRequest<LocationModelPermanent> = LocationModelPermanent.fetchRequest()
        do {
            cityArrayDB = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "continueSegue", sender: self)
    }
    
    @IBAction func unwindToLocation(_ sender: UIStoryboardSegue) {
        collectionViewLocation.reloadData()
        self.saveLocation()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actualUbicationBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindActualLocation", sender: self)
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
            let cityTotal = cityArrayDB
            destinationVC.placeToShow = cityTotal[currentIndex].place
            destinationVC.lonToShow = cityTotal[currentIndex].longitude
            destinationVC.latToShow = cityTotal[currentIndex].latitude
        }
        
        if segue.identifier == "unwindActualLocation" {
            let destinationVC = segue.destination as! WeatherViewController
            destinationVC.placeToShow = "Mi ubicacion"
            destinationVC.lonToShow = 0.0
            destinationVC.latToShow = 0.0
        }
    }
}

//MARK: - CollectionViewDataSource
extension LocationViewController: UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.context.delete(self.cityArrayDB[indexPath.row])
            self.cityArrayDB.remove(at: indexPath.row)
            self.saveLocation()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
//        options.transitionStyle = .border
        return options
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cityTotal = cityArrayDB
        return cityTotal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierLocation, for: indexPath) as! CustomCollectionViewCellLocation
        let cityTotal = cityArrayDB
        let city = cityTotal[indexPath.row].place
        cell.configure(city: city!)
        cell.delegate = self
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension LocationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return CGFloat(1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}
