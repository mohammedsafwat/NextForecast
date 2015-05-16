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
    func propagateParsedWeatherData(weatherData : [SingleDayWeatherData]!, error : NSError!)
}

class WeatherDataManager: NSObject {
    var weatherDataManagerDelegate : WeatherDataManagerDelegate?
    
    func retrieveWeatherDataForLocation(location : CLLocation, forecastType : ForecastType)
    {
        let weatherDataUrlString = forecastType == .Today ? AppSettings.sharedInstance.todayForecastURL : AppSettings.sharedInstance.sevenDaysForecastURL
        var formattedWeatherDataUrlString : String! = NSString(format: weatherDataUrlString, location.coordinate.latitude, location.coordinate.longitude)
        
        Alamofire.request(.GET, formattedWeatherDataUrlString)
            .responseJSON {(request, response, JSON, error) in
                if(error == nil)
                {
                    if let weatherDataManagerDelegate = self.weatherDataManagerDelegate
                    {
                        weatherDataManagerDelegate.propagateParsedWeatherData(self.parseWeatherData(JSON, forecastType: forecastType), error: nil)
                    }
                }
                else
                {
                    if let weatherDataManagerDelegate = self.weatherDataManagerDelegate
                    {
                        weatherDataManagerDelegate.propagateParsedWeatherData(nil, error: error)
                    }
                }
        }
    }
    
    func parseWeatherData(JSON : AnyObject?, forecastType : ForecastType) ->  [SingleDayWeatherData]{
        var parsedWeatherData = [SingleDayWeatherData]()
        
        if(forecastType == .Today)
        {
            var singleDayWeatherData = SingleDayWeatherData()

            var JSONDictionary : NSDictionary = JSON as NSDictionary
            var timeStamp : Double? = JSONDictionary.valueForKey("dt") as? Double
            if(timeStamp != nil)
            {
                let timeStampAsDate = NSDate(timeIntervalSince1970: timeStamp!)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dayDateComponent = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday, fromDate: timeStampAsDate)
                let dayIndex = dayDateComponent.weekday
                let dayNameFromTimeStamp = dateFormatter.weekdaySymbols[dayIndex - 1] as String
                singleDayWeatherData.dayName = dayNameFromTimeStamp
            }
            var temperature : Float? = JSONDictionary.valueForKey("main")?.valueForKey("temp") as? Float
            if(temperature != nil)
            {
                singleDayWeatherData.temperature = temperature
            }
        }
        return parsedWeatherData
    }
}
