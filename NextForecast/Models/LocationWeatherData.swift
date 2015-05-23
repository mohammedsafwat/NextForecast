//
//  LocationWeatherData.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class LocationWeatherData: NSObject, NSCoding {
    var name : String! = ""
    var locationID : String! = ""
    var latitude : Float! = 0.0
    var longitude : Float! = 0.0
    var isCurrentLocation : Bool! = false
    var todayWeatherData : SingleDayWeatherData! = SingleDayWeatherData()
    var sevenDaysForecastWeatherData : [SingleDayWeatherData]! = []
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as String
        locationID = aDecoder.decodeObjectForKey("locationID") as String
        latitude = aDecoder.decodeObjectForKey("latitude") as Float
        longitude = aDecoder.decodeObjectForKey("longitude") as Float
        isCurrentLocation = aDecoder.decodeObjectForKey("isCurrentLocation") as Bool
        todayWeatherData = aDecoder.decodeObjectForKey("todayWeatherData") as SingleDayWeatherData
        sevenDaysForecastWeatherData = aDecoder.decodeObjectForKey("sevenDaysForecastWeatherData") as [SingleDayWeatherData]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(locationID, forKey: "locationID")
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
