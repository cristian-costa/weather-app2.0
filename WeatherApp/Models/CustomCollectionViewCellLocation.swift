//
//  CustomCollectionViewCellLocation.swift
//  WeatherApp
//
//  Created by Cristian Costa on 05/12/2021.
//

import UIKit

class CustomCollectionViewCellLocation: UICollectionViewCell {
    @IBOutlet weak var citylbl: UILabel!
    
    func configure(city: String) {
        citylbl.text = city
    }
}
