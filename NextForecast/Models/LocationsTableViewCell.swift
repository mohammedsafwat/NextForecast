//
//  LocationsTableViewCell.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/25/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    @IBOutlet weak var locationTodayTemperatureLabel: UILabel!
    @IBOutlet weak var locationTodayWeatherDescriptionLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationTodayWeatherIconImageView: UIImageView!
    @IBOutlet weak var currentLocationIndicatorImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
