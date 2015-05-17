//
//  AppSettings.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

private let _singletonInstance = AppSettings()

class AppSettings: NSObject {
    var todayForecastURL : String! = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&mode=json"
    var sevenDaysForecastURL : String! = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=7&mode=json"
    
    class var sharedInstance : AppSettings {
        return _singletonInstance
    }
}
