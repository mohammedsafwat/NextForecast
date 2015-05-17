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
    func propagateParsedWeatherData(weatherData : LocationWeatherData!, error : NSError!)
}

class WeatherDataManager: NSObject {
    var weatherDataManagerDelegate : WeatherDataManagerDelegate?
    let kelvinConstant : Float = 273.15
    
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
                        var locationWeatherData : LocationWeatherData! = self.parseWeatherData(JSON, forecastType: forecastType)
                        weatherDataManagerDelegate.propagateParsedWeatherData(locationWeatherData, error: nil)
                    }
                }
                else
                {
                    if let weatherDataManagerDelegate = self.weatherDataManagerDelegate
                    {
                        weatherDataManagerDelegate.propagateParsedWeatherData(nil, error: error!)
                    }
                }
        }
    }
    
    func getDayNameFromTimeStamp(var timeStamp : NSTimeInterval!) -> String {
        let timeStampAsDate = NSDate(timeIntervalSince1970: timeStamp)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dayDateComponent = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday, fromDate: timeStampAsDate)
        let dayIndex = dayDateComponent.weekday
        let dayNameFromTimeStamp = dateFormatter.weekdaySymbols[dayIndex - 1] as String
        return dayNameFromTimeStamp
    }
    
    func getWeatherIconName(var weatherConditionId : Int!) -> String {
        var weatherIconName : String!
        if(weatherConditionId >= 200 && weatherConditionId <= 232) {
            weatherIconName = "Thunder"
        }
        else if((weatherConditionId >= 300 && weatherConditionId <= 321) || (weatherConditionId >= 500 && weatherConditionId <= 531)) {
            weatherIconName = "Rain"
        }
        else if(weatherConditionId >= 600 && weatherConditionId <= 622) {
            weatherIconName = "Snow"
        }
        else if((weatherConditionId >= 701 && weatherConditionId <= 781) || (weatherConditionId >= 801 && weatherConditionId <= 804) || (weatherConditionId >= 900 && weatherConditionId <= 962)) {
            weatherIconName = "Wind"
        }
        else {
            weatherIconName = "Clear"
        }
        return "WeatherIcon_" + weatherIconName
    }
    
    func getWindDirection(var windDegree : Float!) -> WindDirection {
        var windDirection : WindDirection!
        if(windDegree >= 0 && windDegree <= 90)
        {
            windDirection = .NE
        }
        else if(windDegree > 90 && windDegree <= 180)
        {
            windDirection = .NW
        }
        else if(windDegree > 90 && windDegree <= 270)
        {
            windDirection = .SW
        }
        else if(windDegree > 270 && windDegree <= 360)
        {
            windDirection = .SW
        }
        return windDirection
    }
    
    func parseWeatherData(JSON : AnyObject?, forecastType : ForecastType) ->  LocationWeatherData{
        var locationWeatherData : LocationWeatherData = LocationWeatherData()
        
        var JSONData : NSDictionary! = JSON as NSDictionary
        
        if(forecastType == .Today)
        {
            var todayWeatherData = SingleDayWeatherData()

            var weatherDataArray : NSArray? = JSONData.valueForKey("weather") as NSArray?
            var weatherDataDictionary : NSDictionary? = weatherDataArray?.objectAtIndex(0) as? NSDictionary
            
            var timeStamp : Double? = JSONData.valueForKey("dt") as? Double
            if(timeStamp != nil)
            {
                todayWeatherData.dayName = getDayNameFromTimeStamp(timeStamp)
            }
            var temperature : Float? = JSONData.valueForKey("main")?.valueForKey("temp") as? Float
            if(temperature != nil)
            {
                todayWeatherData.temperature = roundf(temperature! - kelvinConstant)
                todayWeatherData.temperatureUnit = .C
            }
            var weatherDescription : String? = weatherDataDictionary!.valueForKey("description") as? String
            if(weatherDescription != nil)
            {
                weatherDescription = weatherDescription?.capitalizedString
                todayWeatherData.weatherDescription = weatherDescription
            }
            var weatherConditionId : Int? = weatherDataDictionary!.valueForKey("id") as? Int
            if(weatherConditionId != nil)
            {
                todayWeatherData.weatherIconName = getWeatherIconName(weatherConditionId)
            }
            var pressure : Float? = weatherDataDictionary!.valueForKey("pressure") as? Float
            if(pressure != nil)
            {
                todayWeatherData.pressure = pressure
            }
            var humidity : Float? = weatherDataDictionary!.valueForKey("humidity") as? Float
            if(humidity != nil)
            {
                todayWeatherData.humidity = humidity
            }
            var windSpeed : Float? = weatherDataDictionary!.valueForKey("wind")?.valueForKey("speed") as? Float
            if(windSpeed != nil)
            {
                todayWeatherData.wind = windSpeed
                todayWeatherData.speedUnit = .milesPerSecond
            }
            var windDirectionDegrees : Float? = weatherDataDictionary!.valueForKey("wind")?.valueForKey("deg") as? Float
            if(windDirectionDegrees != nil)
            {
                todayWeatherData.windDirection = getWindDirection(windDirectionDegrees)
            }
            var locationCityName : String? = JSONData.valueForKey("name") as? String
            var locationCountryName : String? = JSONData.valueForKey("sys")?.valueForKey("country") as? String
            var longitude : Float? = JSONData.valueForKey("coord")?.valueForKey("lon") as? Float
            var latitude :Float? = JSONData.valueForKey("coord")?.valueForKey("lat") as? Float
            
            if(locationCityName != nil && locationCountryName != nil)
            {
                locationWeatherData.name = locationCityName! + ", " + locationCountryName!
            }
            else
            {
                locationWeatherData.name = NSString(format: "%f, %f", longitude!, latitude!)
            }
            locationWeatherData.latitude = latitude!
            locationWeatherData.longitude = longitude!
            locationWeatherData.isCurrentLocation = true
            locationWeatherData.todayWeatherData = todayWeatherData
        }
        return locationWeatherData
    }
}
