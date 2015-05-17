//
//  FirstViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/14/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class TodayViewController: UIViewController, CLLocationManagerDelegate, WeatherDataManagerDelegate {

    var locationManager : CLLocationManager!
    var authorizationStatus : CLAuthorizationStatus!
    var activityIndicator : MBProgressHUD!
    var weatherDataManager : WeatherDataManager!
    var locationUpdated : Bool!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var currentLocationIndicatorImageView: UIImageView!
    @IBOutlet weak var todayTemperatureLabel: UILabel!
    @IBOutlet weak var todayTemperatureUnitLabel: UILabel!
    @IBOutlet weak var todayWeatherDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initValues()
        setupAutoresizingMasks()
        startLocationUpdates()
    }
    
    func initValues() {
        self.title = "Today"
        weatherDataManager = WeatherDataManager()
        weatherDataManager.weatherDataManagerDelegate = self
        locationUpdated = false
    }
    
    func setupAutoresizingMasks() {
        self.weatherIconImageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLocationUpdates() {
        startActivityIndicatorWithStatusText("Updating current location..")
        if(locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.distanceFilter = kCLHeadingFilterNone
        }
        requestAlwaysAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        authorizationStatus = CLLocationManager.authorizationStatus()
        // If the status is denied or only granted for when in use, display an alert
        if(authorizationStatus == .AuthorizedWhenInUse || authorizationStatus == .Restricted || authorizationStatus == .Denied)
        {
            var title : String!
            title = (authorizationStatus == .Denied) ? "Location services are off" : "Background location is not enabled"
            var message : String = "To use background location you must turn on 'Always' in the Location Services Settings"
            displayAlertViewWithMessage(message, otherButtonTitles: "Settings")
        }
            // The user has not enabled any location services. Request background authorization.
        else if (authorizationStatus == .NotDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
        else if(authorizationStatus == .AuthorizedAlways) {
            locationManager.startUpdatingLocation()
        }
    }
    
    //Location Manager Delegates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if(!locationUpdated)
        {
            var location : CLLocation!
            location = locations.last as CLLocation
            print("location.longitude = %f",location.coordinate.longitude)
            print("location.latitude = %f",location.coordinate.latitude)
            locationManager.stopUpdatingLocation()
            stopActivityIndicator()
            locationUpdated = true
            retrieveWeatherForLocation(location)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        displayAlertViewWithMessage("Unable to determine location. You must enable location services for this app in Settings.", otherButtonTitles:"Settings")
        stopActivityIndicator()
    }
    
    func retrieveWeatherForLocation(location : CLLocation) {
        startActivityIndicatorWithStatusText("Updating weather data..")
        weatherDataManager.retrieveWeatherDataForLocation(location, forecastType: .Today)
    }
    
    //WeatherDataManager Delegates
    func propagateParsedWeatherData(weatherData : LocationWeatherData!, error : NSError!) {
        if(error == nil)
        {
            var weatherIconImage : UIImage! = UIImage(named: weatherData.todayWeatherData.weatherIconName)
            weatherIconImageView.image = weatherIconImage
            
            locationNameLabel.text = weatherData.name
            locationNameLabel.sizeToFit()
            
            if(!weatherData.isCurrentLocation) {
                currentLocationIndicatorImageView.hidden = true
            }
            else
            {
                currentLocationIndicatorImageView.hidden = false
            }
            
            todayTemperatureLabel.text = NSString(format: "%.0f°", weatherData.todayWeatherData.temperature)
            let temperatureUnit : TemperatureUnit = weatherData.todayWeatherData.temperatureUnit
            todayTemperatureUnitLabel.text = temperatureUnit == .C ? "C" : "F"
            todayWeatherDescriptionLabel.text = weatherData.todayWeatherData.weatherDescription
            todayWeatherDescriptionLabel.sizeToFit()
        }
        else
        {
            
        }
        stopActivityIndicator()
    }
    
    //Alert Views and HUD Views methods
    //Create and Alert View with a custom message
    func displayAlertViewWithMessage(alertViewMessage : String!, otherButtonTitles : String!) {
        let alertController = UIAlertController(title: "Background Location Access Disabled", message: alertViewMessage, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: otherButtonTitles, style: .Default) {
            (action) in
            if let url = NSURL(string : UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Create HUD View
    func startActivityIndicatorWithStatusText(statusText : String!) {
        activityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        activityIndicator.labelText = statusText;
    }
    //Hid HUD View
    func stopActivityIndicator() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
}

