//
//  UnitsConverter.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/27/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

private let _singletonInstance = UnitsConverter()


class UnitsConverter: NSObject {
    
    private func convertTemperatureFromCelsiusToFahrenheit(temperature : Float) -> Float
    {
        return (temperature * 1.8000) + 32.00
    }
    
    private func convertTemperatureFromFahrenheitToCelsius(temperature : Float) ->Float
    {
        return (temperature - 32.00) / 1.8000
    }
    
    private func convertSpeedFromKmPerHourToMilesPerHour(speed : Float) -> Float
    {
        return speed * 0.621371
    }
    
    private func convertSpeedFromMilesPerHourToKmPerHour(speed : Float) -> Float
    {
        return speed * 1.60934
    }
    
    func getCurrentUnitConvertedTemperature(temperature : Float, temperatureUnit : TemperatureUnit) -> Float
    {
        var convertedTemperature : Float = Float()
        let settingsTemperatureUnit : TemperatureUnit = AppSharedData.sharedInstance.settingsTemperatureUnit
        if(settingsTemperatureUnit == .C)
        {
            convertedTemperature = UnitsConverter.sharedInstance.convertTemperatureFromFahrenheitToCelsius(temperature)
            
        }
        else if(settingsTemperatureUnit == .F)
        {
            convertedTemperature = UnitsConverter.sharedInstance.convertTemperatureFromCelsiusToFahrenheit(temperature)
        }
        return convertedTemperature
    }
    
    func getCurrentUnitConvertedSpeed(speed : Float, speedUnit : SpeedUnit) -> Float
    {
        var convertedSpeed : Float = Float()
        let settingsSpeedUnit : SpeedUnit = AppSharedData.sharedInstance.settingsSpeedUnit
        if(settingsSpeedUnit == .milesPerHour)
        {
            convertedSpeed = UnitsConverter.sharedInstance.convertSpeedFromKmPerHourToMilesPerHour(speed)
        }
        else if(settingsSpeedUnit == .kmPerHour)
        {
            convertedSpeed = UnitsConverter.sharedInstance.convertSpeedFromMilesPerHourToKmPerHour(speed)
        }
        return convertedSpeed
    }
    
    class var sharedInstance : UnitsConverter {
        return _singletonInstance
    }
}
