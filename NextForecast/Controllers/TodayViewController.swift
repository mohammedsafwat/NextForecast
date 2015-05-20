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
    @IBOutlet weak var todayTemperatureAndDescriptionLabel: UILabel!
    @IBOutlet weak var todayRainValueLabel: UILabel!
    @IBOutlet weak var todayHumidityValueLabel: UILabel!
    @IBOutlet weak var todayPressureValueLabel: UILabel!
    @IBOutlet weak var todayWindSpeedValueLabel: UILabel!
    @IBOutlet weak var todayWindDirectionValueLabel: UILabel!

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
            //Set weather icon according to current weather data
            var weatherIconImage : UIImage! = UIImage(named: weatherData.todayWeatherData.weatherIconName)
            weatherIconImageView.image = weatherIconImage
            locationNameLabel.text = weatherData.name
            //Check if we are getting weather data for the current location
            //Then display the GPS indicator besides the location title
            if(!weatherData.isCurrentLocation) {
                currentLocationIndicatorImageView.hidden = true
            }
            else
            {
                currentLocationIndicatorImageView.hidden = false
            }
            
            //Set current temperature value and label
            let temperatureUnit : TemperatureUnit = weatherData.todayWeatherData.temperatureUnit
            let temperatureFormattedString = NSString(format: "%.0f°%@", weatherData.todayWeatherData.temperature, temperatureUnit == .C ? "C" : "F")
            
            //Set current weather description
            let weatherDescriptionString = weatherData.todayWeatherData.weatherDescription
            
            todayTemperatureAndDescriptionLabel.text = NSString(format: "%@ | %@", temperatureFormattedString, weatherDescriptionString)
            
            //Set other weather data values
            //Rain
            todayRainValueLabel.text = NSString(format: "%0.1f mm", weatherData.todayWeatherData.rain)
            
            //Humidity
            todayHumidityValueLabel.text = NSString(format: "%0.0f%@", weatherData.todayWeatherData.humidity, "%")
            
            //Pressure
            todayPressureValueLabel.text = NSString(format: "%0.0f hPa", weatherData.todayWeatherData.pressure)
            
            //Wind Speed
            todayWindSpeedValueLabel.text = NSString(format: "%0.0f km/h", weatherData.todayWeatherData.wind)
            
            //Wind Direction
            var windDirectionString : String!
            var windDirection : WindDirection
            windDirection = weatherData.todayWeatherData.windDirection
            switch(windDirection){
            case .NE:
                windDirectionString = "NE"
            case .NW:
                windDirectionString = "NW"
            case .SE:
                windDirectionString = "SE"
            case .SW:
                windDirectionString = "SW"
            }
            todayWindDirectionValueLabel.text = windDirectionString
        }
        else
        {
            println(error.localizedDescription)
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

