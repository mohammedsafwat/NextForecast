//
//  ForecastTableViewCell.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/23/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    @IBOutlet weak var forecastDayTemperatureLabel: UILabel!
    @IBOutlet weak var forecastDayWeatherIconImageView: UIImageView!
    @IBOutlet weak var forecastDayNameLabel: UILabel!
    @IBOutlet weak var forecastDayWeatherDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
