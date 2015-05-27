//
//  UserDefaultsManager.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/27/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

private let _singletonInstance = UserDefaultsManager()

class UserDefaultsManager: NSObject {
    
    private var userDefaults = NSUserDefaults.standardUserDefaults()
    
    func saveTemperatureUnitToUserDefaults(temperatureUnit : TemperatureUnit)
    {
        userDefaults.setObject(temperatureUnit.rawValue, forKey: "TemperatureUnit")
        userDefaults.synchronize()
    }
    
    func getTemperatureUnitFromUserDefaults() -> TemperatureUnit
    {
        var temperatureUnit : TemperatureUnit? = TemperatureUnit(rawValue: userDefaults.integerForKey("TemperatureUnit"))
        return temperatureUnit!
    }
    
    func saveSpeedUnitToUserDefaults(speedUnit : SpeedUnit)
    {
        userDefaults.setObject(speedUnit.rawValue, forKey: "SpeedUnit")
        userDefaults.synchronize()
    }
    
    func getSpeedUnitFromUserDefaults() -> SpeedUnit
    {
        var speedUnit : SpeedUnit? = SpeedUnit(rawValue: userDefaults.integerForKey("SpeedUnit"))
        return speedUnit!
    }
    
    class var sharedInstance : UserDefaultsManager {
        return _singletonInstance
    }
}
