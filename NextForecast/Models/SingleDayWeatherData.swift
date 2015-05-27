//
//  SingleDayWeatherData.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SingleDayWeatherData: NSObject, NSCoding{
    var dayName : String! = ""
    var temperature : Float! = 0.0
    var temperatureUnit : TemperatureUnit! = .C
    var weatherDescription : String! = ""
    var weatherIconName : String! = ""
    var pressure : Float! = 0.0
    var humidity : Float! = 0.0
    var rain : Float! = 0.0
    var wind : Float! = 0.0
    var windDirection : WindDirection! = .NE
    var speedUnit : SpeedUnit! = .kmPerHour
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        dayName = aDecoder.decodeObjectForKey("dayName") as String
        temperature = aDecoder.decodeObjectForKey("temperature") as Float
        temperatureUnit = TemperatureUnit(rawValue: aDecoder.decodeIntegerForKey("temperatureUnit"))
        weatherDescription = aDecoder.decodeObjectForKey("weatherDescription") as String
        weatherIconName = aDecoder.decodeObjectForKey("weatherIconName") as String
        pressure = aDecoder.decodeObjectForKey("pressure") as Float
        humidity = aDecoder.decodeObjectForKey("humidity") as Float
        rain = aDecoder.decodeObjectForKey("rain") as Float
        wind = aDecoder.decodeObjectForKey("wind") as Float
        windDirection = WindDirection(rawValue: aDecoder.decodeIntegerForKey("windDirection"))
        speedUnit = SpeedUnit(rawValue: aDecoder.decodeIntegerForKey("speedUnit"))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(dayName, forKey: "dayName")
        aCoder.encodeObject(temperature, forKey: "temperature")
        aCoder.encodeInteger(temperatureUnit.rawValue, forKey: "temperatureUnit")
        aCoder.encodeObject(weatherDescription, forKey: "weatherDescription")
        aCoder.encodeObject(weatherIconName, forKey: "weatherIconName")
        aCoder.encodeObject(pressure, forKey: "pressure")
        aCoder.encodeObject(humidity, forKey: "humidity")
        aCoder.encodeObject(rain, forKey: "rain")
        aCoder.encodeObject(wind, forKey: "wind")
        aCoder.encodeInteger(windDirection.rawValue, forKey: "windDirection")
        aCoder.encodeInteger(speedUnit.rawValue, forKey: "speedUnit")
    }
    
    func data() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}
