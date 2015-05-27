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
    var noInformationLabel : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        initValues()
        setUpForecastTableView()
        setUpNoInformationLabel()
    }
    
    func initValues() {
        self.title = "Forecast"
        weatherDataManager = WeatherDataManager()
        weatherDataManager.weatherDataManagerDelegate = self
        errorMessageDidAppear = false
    }
    
    func setUpForecastTableView() {
        //Load ForecastTableViewCell file
        var forecastTableViewCellNib : UINib = UINib(nibName: "ForecastTableViewCell", bundle: NSBundle.mainBundle())
        forecastTableView.registerNib(forecastTableViewCellNib, forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
        forecastTableView.frame = CGRect(x: forecastTableView.frame.origin.x, y: forecastTableView.frame.origin.y, width: forecastTableView.frame.size.width, height: forecastTableView.frame.size.height)
        forecastTableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        forecastTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func setUpNoInformationLabel() {
        noInformationLabel = UILabel(frame: CGRectZero)
        noInformationLabel.textColor = UIColor.lightGrayColor()
        noInformationLabel.textAlignment = .Center
        noInformationLabel.text = "Sorry, weather information is not available."
        noInformationLabel.sizeToFit()
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height
        let tabBarHeight = self.tabBarController?.tabBar.frame.height
        noInformationLabel.center.x = self.forecastTableView.center.x
        noInformationLabel.center.y = self.forecastTableView.center.y - tabBarHeight! - navigationBarHeight!
        noInformationLabel.font = UIFont(name: "ProximaNova-Light", size: 15)
        noInformationLabel.hidden = true
        self.forecastTableView.addSubview(noInformationLabel)
    }
    
    override func viewDidAppear(animated: Bool) {
        updateViewTitleWithCurrentDisplayingLocationName()
        updateForecastWeatherData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.title = "Forecast"
    }
    
    func updateViewTitleWithCurrentDisplayingLocationName() {
        var currentDisplayingLocation : LocationWeatherData = AppSharedData.sharedInstance.currentDisplayingLocation
        if(currentDisplayingLocation.name != "")
        {
            self.title = currentDisplayingLocation.name.componentsSeparatedByString(",")[0]
        }
        else
        {
            self.title = "Forecast"
        }
    }
    
    func updateForecastWeatherData() {
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.forecastTableView, statusText: "Updating forecast data..")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            var locationWeatherData : LocationWeatherData = AppSharedData.sharedInstance.currentDisplayingLocation
            self.forecastWeatherData = locationWeatherData.forecastWeatherData
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.forecastTableView)
                if(self.forecastWeatherData.count > 0)
                {
                    self.forecastTableView.reloadData()
                }
                else
                {
                    self.errorMessageDidAppear = false
                    self.retrieveWeatherDataForLocation(locationWeatherData)
                }
            })
        })
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
        
        //Day Name
        forecastTableViewCell?.forecastDayNameLabel.text = forecastDayWeatherData.dayName
        
        //Temperature
        let temperatureUnit : TemperatureUnit = forecastDayWeatherData.temperatureUnit
        let settingsTemperatureUnit : TemperatureUnit = AppSharedData.sharedInstance.settingsTemperatureUnit
        var temperature = forecastDayWeatherData.temperature
        if(!(temperatureUnit == settingsTemperatureUnit))
        {
            temperature = UnitsConverter.sharedInstance.getCurrentUnitConvertedTemperature(temperature, temperatureUnit: temperatureUnit)
        }
        forecastTableViewCell?.forecastDayTemperatureLabel.text = NSString(format: "%0.0f°", temperature)
        
        //Weather Description
        forecastTableViewCell?.forecastDayWeatherDescriptionLabel.text = forecastDayWeatherData.weatherDescription
        
        //Weather Icon
        var weatherIconImage : UIImage! = UIImage(named: forecastDayWeatherData.weatherIconName)
        forecastTableViewCell?.forecastDayWeatherIconImageView.image = weatherIconImage
        return forecastTableViewCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Retrieving Weather Data Methods
    func retrieveWeatherDataForLocation(location : LocationWeatherData) {
        var locationCoordinates : CLLocation = CLLocation(latitude: Double(location.latitude), longitude: Double(location.longitude))
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.view, statusText: "Updating weather data..")
        weatherDataManager.retrieveWeatherDataForLocation(locationCoordinates, customName: "", isCurrentLocation: location.isCurrentLocation)
    }
    
    // MARK: - WeatherDataManager Delegates
    func propagateParsedWeatherData(locationWeatherData : LocationWeatherData!, error : NSError!) {
        if(error == nil)
        {
            forecastWeatherData = locationWeatherData.forecastWeatherData
            noInformationLabel.hidden = true
            forecastTableView.reloadData()
        }
        else
        {
            if(!errorMessageDidAppear)
            {
                displayAlertViewWithMessage(error.localizedDescription, otherButtonTitles: "Try Again")
                errorMessageDidAppear = true
            }
            if(forecastWeatherData.count == 0)
            {
                noInformationLabel.hidden = false
            }
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
        else if(otherButtonTitles == "Try Again")
        {
            let tryAgainAction = UIAlertAction(title: otherButtonTitles, style: .Default) {
                (action) in
                self.retrieveWeatherDataForLocation(AppSharedData.sharedInstance.currentDisplayingLocation)
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

