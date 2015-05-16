//
//  WeatherDataManager.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import AFNetworking
import CoreLocation

enum ForecastType {
    case Today
    case SevenDays
}

protocol WeatherDataManagerDelegate {
    func propagateParsedWeatherData(weatherData : Dictionary<String, [SingleDayWeatherData]>, error : NSError)
}

class WeatherDataManager: NSObject {
    var weatherDataManagerDelegate : WeatherDataManagerDelegate?
    
    func retrieveWeatherDataForLocation(location : CLLocation, forecastType : ForecastType)
    {
        
    }
}
