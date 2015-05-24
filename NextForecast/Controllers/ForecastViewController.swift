//
//  SecondViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/14/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation

class ForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WeatherDataManagerDelegate{
    
    @IBOutlet weak var forecastTableView: UITableView!
    let forecastTableViewCellHeight : CGFloat! = 77
    var forecastWeatherData : [SingleDayWeatherData]! = []
    var weatherDataManager : WeatherDataManager!
    var errorMessageDidAppear : Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
        
        updateCurrentSavedLocations()
        updateForecastWeatherData()
    }
    
    func initValues() {
        self.title = "Forecast"
        
        weatherDataManager = WeatherDataManager()
        weatherDataManager.weatherDataManagerDelegate = self
        errorMessageDidAppear = false
        
        //Load ForecastTableViewCell file
        var forecastTableViewCellNib : UINib = UINib(nibName: "ForecastTableViewCell", bundle: NSBundle.mainBundle())
        forecastTableView.registerNib(forecastTableViewCellNib, forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
        forecastTableView.frame = CGRect(x: forecastTableView.frame.origin.x, y: forecastTableView.frame.origin.y, width: forecastTableView.frame.size.width, height: forecastTableView.frame.size.height)
        forecastTableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        forecastTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) {
        //Update the current saved locations array in AppSharedData
        updateCurrentSavedLocations()
        self.title = getLocationWeatherDataForCurrentSelectedLocation().name
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.title = "Forecast"
    }
    
    func updateCurrentSavedLocations() {
        AppSharedData.sharedInstance.savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
    }
    
    func updateForecastWeatherData() {
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.forecastTableView, statusText: "Updating forecast data..")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            var locationWeatherData : LocationWeatherData = self.getLocationWeatherDataForCurrentSelectedLocation()
            self.forecastWeatherData = locationWeatherData.forecastWeatherData
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.forecastTableView)
                
                if(self.forecastWeatherData.count > 0)
                {
                    self.forecastTableView.reloadData()
                }
                else
                {
                    self.retrieveWeatherDataForLocation(AppSharedData.sharedInstance.currentLocationCoordinates)
                }
            })
        })
    }
    
    func getLocationWeatherDataForCurrentSelectedLocation() -> LocationWeatherData {
        var currentSelectedLocationID : String! = AppSharedData.sharedInstance.currentSelectedLocationID
        var currentSelectedLocationWeatherData : LocationWeatherData = LocationWeatherData()
        for locationWeatherData : LocationWeatherData in AppSharedData.sharedInstance.savedLocations {
            if(locationWeatherData.locationID == currentSelectedLocationID)
            {
                currentSelectedLocationWeatherData = locationWeatherData
            }
        }
        return currentSelectedLocationWeatherData
    }
    
    // MARK: - TableViewDelegates
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return forecastTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastWeatherData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var forecastTableViewCell : ForecastTableViewCell? = tableView.dequeueReusableCellWithIdentifier("ForecastTableViewCell") as? ForecastTableViewCell
        
        if(forecastTableViewCell == nil)
        {
            forecastTableViewCell = ForecastTableViewCell()
        }
        
        var forecastDayWeatherData : SingleDayWeatherData = forecastWeatherData[indexPath.row]
        forecastTableViewCell?.forecastDayNameLabel.text = forecastDayWeatherData.dayName
        forecastTableViewCell?.forecastDayTemperatureLabel.text = NSString(format: "%0.0f°",forecastDayWeatherData.temperature)
        forecastTableViewCell?.forecastDayWeatherDescriptionLabel.text = forecastDayWeatherData.weatherDescription
        var weatherIconImage : UIImage! = UIImage(named: forecastDayWeatherData.weatherIconName)
        forecastTableViewCell?.forecastDayWeatherIconImageView.image = weatherIconImage
        return forecastTableViewCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Retrieving Weather Data Methods
    func retrieveWeatherDataForLocation(location : CLLocation) {
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.view, statusText: "Updating weather data..")
        weatherDataManager.retrieveWeatherDataForLocation(location)
    }
    
    // MARK: - WeatherDataManager Delegates
    func propagateParsedWeatherData(locationWeatherData : LocationWeatherData!, error : NSError!) {
        if(error == nil)
        {
            forecastWeatherData = locationWeatherData.forecastWeatherData
            forecastTableView.reloadData()
        }
        else
        {
            if(!errorMessageDidAppear)
            {
                displayAlertViewWithMessage(error.localizedDescription, otherButtonTitles: "Try Again")
                errorMessageDidAppear = true
            }
            //TODO: Set default data values here if an error happened
        }
        ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.view)
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
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

