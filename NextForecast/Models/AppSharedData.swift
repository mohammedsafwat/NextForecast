//
//  AppSettings.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

private let _singletonInstance = AppSharedData()

class AppSharedData: NSObject {
    var todayForecastURL : String! = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&mode=json"
    var sevenDaysForecastURL : String! = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=7&mode=json"
    let DATABASE_RESOURCE_NAME = "nextforecast"
    let DATABASE_RESOURCE_TYPE = "sql"
    let DATABASE_FILE_NAME = "nextforecast.sql"
    
    class var sharedInstance : AppSharedData {
        return _singletonInstance
    }
}
