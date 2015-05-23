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
    let todayForecastURL = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&mode=json"
    let sevenDaysForecastURL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=7&mode=json"
    let googlePlacesWebserviceURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=AIzaSyAJonxZ7ZiOy4Eh_cAMBwjaCLXQvbRFu4o"
    let DATABASE_RESOURCE_NAME = "nextforecast"
    let DATABASE_RESOURCE_TYPE = "sql"
    let DATABASE_FILE_NAME = "nextforecast.sql"
    
    var savedLocations : [LocationWeatherData]! = []
    
    class var sharedInstance : AppSharedData {
        return _singletonInstance
    }
}
