//
//  CustomCollectionViewCellDaily.swift
//  WeatherApp
//
//  Created by Cristian Costa on 12/11/2021.
//

import UIKit

class CustomCollectionViewCellDaily: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    func configure(date: String, min: String, max: String) {
        dateLabel.text = date
        minLabel.text = min
        maxLabel.text = max
    }
}
