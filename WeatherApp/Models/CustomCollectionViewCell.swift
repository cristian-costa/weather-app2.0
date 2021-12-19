//
//  CustomCollectionViewCell.swift
//  WeatherApp
//
//  Created by Cristian Costa on 09/11/2021.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    
    //MARK: - Functions
    
    func configure(time: String, temp: String){
        if Int(time)! == 999 {
            timeLabel.text = "Ahora"
        } else if Int(time)! >= 0 && Int(time)! <= 9 {
            timeLabel.text = "0\(time) AM"
        } else if Int(time)! >= 10 && Int(time)! <= 11 {
            timeLabel.text = "\(time) AM"
        } else {
            timeLabel.text = "\(time) PM"
        }
        tempLabel.text = "\(temp)°"
    }
    
}
