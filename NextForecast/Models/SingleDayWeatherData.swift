//
//  SingleDayWeatherData.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/16/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

enum TemperatureUnit {
    case C
    case F
}
enum SpeedUnit {
    case milesPerSecond
    case metersPerSecond
}
enum WindDirection {
    case NE
    case NW
    case SE
    case SW
}

class SingleDayWeatherData: NSObject {
    var dayName : String!
    var temperature : Float!
    var temperatureUnit : TemperatureUnit!
    var weatherDescription : String!
    var weatherIconName : String!
    var pressure : Float!
    var humidity : Float!
    var rain : Float!
    var wind : Float!
    var windDirection : WindDirection!
    var speedUnit : SpeedUnit!
}
