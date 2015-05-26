//
//  FirstViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/14/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController, CLLocationManagerDelegate, WeatherDataManagerDelegate, ENSideMenuDelegate, SideMenuDelegate {

    var weatherDataManager : WeatherDataManager!
    var locationUpdated : Bool!
    var canUpdateCurrentLocation : Bool!
    var errorMessageDidAppear : Bool!
    var sideMenuContainer :ENSideMenu!
    var sideMenuViewController : SideMenuViewController!
    var sideMenuOpened : Bool!
    
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
        initValues()
        
        createSideMenu()
        DatabaseManager.sharedInstance.initializeDB()
        //DatabaseManager.sharedInstance.clearDatabase()
        //updateCurrentSavedLocations()
    }
    
    func initValues() {
        self.title = "Today"
        weatherDataManager = WeatherDataManager()
        weatherDataManager.weatherDataManagerDelegate = self
        LocationManager.sharedInstance.locationManager.delegate = self
        locationUpdated = false
        errorMessageDidAppear = false
        sideMenuOpened = false
        canUpdateCurrentLocation = false
    }

    override func viewDidAppear(animated: Bool) {
        updateCurrentSavedLocations()
        displayLastSelectedLocation()
        sideMenuContainer.hideSideMenu()
    }
    
    func displayLastSelectedLocation() {
        //Get last selected location from database, if there is no
        //last selected location saved, load the current location's weather data
        var lastSelectedLocation : LocationWeatherData = DatabaseManager.sharedInstance.getLastSelectedLocation()
        //Last selected location from DB should have a name. Last selected location with
        //no name means that the returned is an empty LocationWeatherData object.
        //So we reload the data using the current location.
        
        //If the last selected location is the current location, we update its data
        //because the user may change his location.
        if(lastSelectedLocation.name == "" || (lastSelectedLocation.isCurrentLocation == true))
        {
            canUpdateCurrentLocation = true
            locationUpdated = false
            startLocationUpdates()
        }
        else
        {
            canUpdateCurrentLocation = false
            updateUIWithLocationWeatherData(lastSelectedLocation)
            AppSharedData.sharedInstance.currentDisplayingLocation = lastSelectedLocation
        }
    }
    
    func createSideMenu() {
        var rightNavigationButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 14))
        rightNavigationButton.addTarget(self, action: "sideMenuButtonPressed:", forControlEvents: .TouchUpInside)
        rightNavigationButton.setBackgroundImage(UIImage(named: "SideMenuIcon"), forState: .Normal)
        var rightNavigationBarButton : UIBarButtonItem = UIBarButtonItem(customView: rightNavigationButton)
        self.navigationItem.rightBarButtonItem = rightNavigationBarButton
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        sideMenuViewController = storyboard.instantiateViewControllerWithIdentifier("SideMenuViewController") as SideMenuViewController
        sideMenuViewController.sideMenuDelegate = self
        sideMenuContainer = ENSideMenu(sourceView: self.view, menuViewController: sideMenuViewController, menuPosition: .Right)
        sideMenuContainer.delegate = self
        sideMenuContainer.menuWidth = 180
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height
        let tabBarHeight = self.tabBarController?.tabBar.frame.height
        sideMenuViewController.tableView.frame = CGRect(x: 0, y: navigationBarHeight! + 22, width: 180, height: sideMenuViewController.tableView.frame.height - (navigationBarHeight! + tabBarHeight! + 25))
    }
    
    func sideMenuButtonPressed(sender : UIButton!) {
        sideMenuViewController.reloadSavedLocations()
        if(!sideMenuOpened)
        {
            sideMenuContainer.showSideMenu()
            sideMenuOpened = true
            sideMenuViewController.selectCurrentDisplayedLocationRow(AppSharedData.sharedInstance.currentDisplayingLocation)
        }
        else
        {
            sideMenuContainer.hideSideMenu()
            sideMenuOpened = false
        }
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillClose() {
        sideMenuOpened = false
    }
    
    func sideMenuWillOpen() {
        sideMenuOpened = true
    }
    
    func updateCurrentSavedLocations() {
        //Update the current saved locations array in AppSharedData
        AppSharedData.sharedInstance.savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
    }
    
    func startLocationUpdates() {
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(view, statusText: "Updating current location..")
        
        let startLocationUpdatesSuccessful : Bool = LocationManager.sharedInstance.startLocationUpdates()
        
        if(!startLocationUpdatesSuccessful)
        {
            var title : String!
            title = LocationManager.sharedInstance.authorizationStatus == .Denied ? "Location services are off" : "Background location is not enabled"
            var message : String = "To use background location you must turn on 'Always' in the Location Services Settings"
            displayAlertViewWithMessage(message, otherButtonTitles: "Settings")
        }
    }
    
    // MARK: - Location Manager Delegates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if(!locationUpdated)
        {
            var location : CLLocation!
            location = locations.last as CLLocation
            //print("location.longitude = %f",location.coordinate.longitude)
            //print("location.latitude = %f",location.coordinate.latitude)
            LocationManager.sharedInstance.locationManager.stopUpdatingLocation()
            ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.view)
            locationUpdated = true
            AppSharedData.sharedInstance.currentLocationCoordinates = location
            retrieveWeatherDataForLocation(location)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedAlways){
            if(canUpdateCurrentLocation == true)
            {
                LocationManager.sharedInstance.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        displayAlertViewWithMessage("Unable to determine location. You must enable location services for this app in Settings.", otherButtonTitles:"Settings")
            ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.view)
    }
    
    // MARK: - Retrieving Weather Data Methods
    func retrieveWeatherDataForLocation(location : CLLocation) {
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.view, statusText: "Updating weather data..")
        weatherDataManager.retrieveWeatherDataForLocation(location, customName: "", isCurrentLocation :true)
    }
    
    // MARK: - WeatherDataManager Delegates
    func propagateParsedWeatherData(weatherData : LocationWeatherData!, error : NSError!) {
        if(error == nil)
        {
            updateUIWithLocationWeatherData(weatherData)
            DatabaseManager.sharedInstance.saveLastSelectedLocation(weatherData.data())
        }
        else
        {
            if(!errorMessageDidAppear)
            {
                displayAlertViewWithMessage(error.localizedDescription, otherButtonTitles: "Try Again")
                errorMessageDidAppear = true
            }
            //TODO: Set default data values here for either today or forecast
        }
        ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.view)
    }
    
    func updateUIWithLocationWeatherData(weatherData : LocationWeatherData) {
        //Set weather icon according to current weather data
        var weatherIconImage : UIImage! = UIImage(named: weatherData.todayWeatherData.weatherIconName)
        weatherIconImageView.image = weatherIconImage
        locationNameLabel.text = weatherData.name
        let locationNameWidth = locationNameLabel.intrinsicContentSize().width
        if(locationNameWidth > self.view.frame.size.width * 0.85)
        {
            let locationName = NSString(format: weatherData.name)
            let numberOfCharactersInLocationName : Int = locationName.length
            let toIndex : Int = numberOfCharactersInLocationName / 2
            var truncatedLocationName = locationName.substringToIndex(toIndex - 3)
            locationNameLabel.text = truncatedLocationName + "..."
        }
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
    
    //MARK : - SideMenuDelegate
    func didSelectLocationFromSideMenu(selectedLocationWeatherData: LocationWeatherData) {
        sideMenuContainer.hideSideMenu()
        DatabaseManager.sharedInstance.saveLastSelectedLocation(selectedLocationWeatherData.data())
        AppSharedData.sharedInstance.currentDisplayingLocation = selectedLocationWeatherData
        displayLastSelectedLocation()
    }
    
    //Alert Views and HUD Views methods
    //Create and Alert View with a custom message
    func displayAlertViewWithMessage(alertViewMessage : String!, otherButtonTitles : String!) {
        let alertController = UIAlertController(title: "Background Location Access Disabled", message: alertViewMessage, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if(otherButtonTitles == "Settings")
        {
            let openSettingsAction = UIAlertAction(title: otherButtonTitles, style: .Default) {
                (action) in
                if let url = NSURL(string : UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openSettingsAction)
        }
        else if(otherButtonTitles == "Try Again")
        {
            let tryAgainAction = UIAlertAction(title: otherButtonTitles, style: .Default) {
                (action) in
                self.startLocationUpdates()
            }
            alertController.addAction(tryAgainAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

