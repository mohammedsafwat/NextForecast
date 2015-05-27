//
//  AppSettings.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation

private let _singletonInstance = AppSharedData()

enum TemperatureUnit : Int{
    case C
    case F
}
enum SpeedUnit : Int{
    case kmPerHour
    case milesPerHour
    case milesPerSecond
}

enum WindDirection : Int{
    case NE
    case NW
    case SE
    case SW
}

class AppSharedData: NSObject {
    let todayWeatherDataURL = "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&mode=json"
    let forecastWeatherDataURL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=7&mode=json"
    let googlePlacesAPIKey = "AIzaSyAJonxZ7ZiOy4Eh_cAMBwjaCLXQvbRFu4o"
    let googlePlacesWebserviceURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=AIzaSyAJonxZ7ZiOy4Eh_cAMBwjaCLXQvbRFu4o"
    let DATABASE_RESOURCE_NAME = "nextforecast"
    let DATABASE_RESOURCE_TYPE = "sql"
    let DATABASE_FILE_NAME = "nextforecast.sql"
    
    var savedLocations : [LocationWeatherData]! = []
    var currentDisplayingLocation : LocationWeatherData = LocationWeatherData()
    var currentLocationCoordinates : CLLocation! = CLLocation()
    var settingsSpeedUnit : SpeedUnit! = .kmPerHour
    var settingsTemperatureUnit : TemperatureUnit! = .C
    class var sharedInstance : AppSharedData {
        return _singletonInstance
    }
}
