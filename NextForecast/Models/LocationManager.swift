//
//  LocationManager.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/24/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation

private let _singletonInstance = LocationManager()

class LocationManager: NSObject {
    var locationManager : CLLocationManager!
    var authorizationStatus : CLAuthorizationStatus!
    
    override init() {
        if(locationManager == nil)
        {
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.distanceFilter = kCLHeadingFilterNone
        }
    }

    func startLocationUpdates() -> Bool{
        return requestAlwaysAuthorization()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    private func requestAlwaysAuthorization() -> Bool {
        var error : NSError! = NSError()
        
        authorizationStatus = CLLocationManager.authorizationStatus()
        // If the status is denied or only granted for when in use, display an alert
        if(authorizationStatus == .AuthorizedWhenInUse || authorizationStatus == .Restricted || authorizationStatus == .Denied)
        {
            return false
        }
        // The user has not enabled any location services. Request background authorization.
        else if (authorizationStatus == .NotDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
        else if(authorizationStatus == .AuthorizedAlways) {
            locationManager.startUpdatingLocation()
        }
        return true
    }
    
    class var sharedInstance : LocationManager {
        return _singletonInstance
    }
}
