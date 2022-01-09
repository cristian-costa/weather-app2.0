//
//  CustomCollectionViewCellLocation.swift
//  WeatherApp
//
//  Created by Cristian Costa on 05/12/2021.
//

import UIKit
import SwipeCellKit

class CustomCollectionViewCellLocation: SwipeCollectionViewCell {
    @IBOutlet weak var citylbl: UILabel!
    
    func configure(city: String) {
        citylbl.text = city
    }
}
