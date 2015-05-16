//
//  LocationWeatherData.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class LocationWeatherData: NSObject, NSCoding {
    var name : String!
    var latitude : Float!
    var longitude : Float!
    var isCurrentLocation : Bool!
    var todayWeatherData : SingleDayWeatherData!
    var sevenDaysForecastWeatherData : Array<SingleDayWeatherData>!
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as String
        latitude = aDecoder.decodeObjectForKey("latitude") as Float
        longitude = aDecoder.decodeObjectForKey("longitude") as Float
        isCurrentLocation = aDecoder.decodeObjectForKey("isCurrentLocation") as Bool
        todayWeatherData = aDecoder.decodeObjectForKey("todayWeatherData") as SingleDayWeatherData
        sevenDaysForecastWeatherData = aDecoder.decodeObjectForKey("sevenDaysForecastWeatherData") as Array<SingleDayWeatherData>
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(latitude, forKey: "latitude")
        aCoder.encodeObject(longitude, forKey: "longitude")
        aCoder.encodeObject(isCurrentLocation, forKey: "isCurrentLocation")
        aCoder.encodeObject(todayWeatherData, forKey: "todayWeatherData")
        aCoder.encodeObject(sevenDaysForecastWeatherData, forKey: "sevenDaysForecastWeatherData")
    }
    
    func data() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}
