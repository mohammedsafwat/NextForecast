//
//  WeatherDataManager.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

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
        let weatherDataUrlString = forecastType == .Today ? AppSettings.sharedInstance.todayForecastURL : AppSettings.sharedInstance.sevenDaysForecastURL
        var formattedWeatherDataUrlString : String! = NSString(format: weatherDataUrlString, location.coordinate.latitude, location.coordinate.longitude)
        
        Alamofire.request(.GET, formattedWeatherDataUrlString)
            .responseJSON {(request, response, JSON, error) in
                println(JSON)
        }
    }
}
