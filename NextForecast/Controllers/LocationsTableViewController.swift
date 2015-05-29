//
//  LocationsTableViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/25/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import GooglePlacesAutocomplete
import CoreLocation

class LocationsTableViewController: UITableViewController, WeatherDataManagerDelegate, UIAlertViewDelegate {
    
    var savedLocations : [LocationWeatherData]! = []
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: AppSharedData.sharedInstance.googlePlacesAPIKey,
        placeType: .Cities
    )
    var weatherDataManger : WeatherDataManager! = WeatherDataManager()
    var addingLocationInProgress : Bool!
    var errorMessageDidAppear : Bool!
    var reloadingSavedLocations : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Locations"
        
        var locationsTableViewCellNib : UINib = UINib(nibName: "LocationsTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(locationsTableViewCellNib, forCellReuseIdentifier: "LocationsTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        gpaViewController.placeDelegate = self
        weatherDataManger.weatherDataManagerDelegate = self
        addingLocationInProgress = false
        errorMessageDidAppear = false
        reloadingSavedLocations = true
        createNavigationBarRightAndLeftbuttons()
    }
    
    override func viewDidAppear(animated: Bool) {
        reloadSavedLocations()
    }
    
    func createNavigationBarRightAndLeftbuttons() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        var leftNavigationButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        leftNavigationButton.addTarget(self, action: "closeIconButtonPressed:", forControlEvents: .TouchUpInside)
        leftNavigationButton.setBackgroundImage(UIImage(named: "CloseIcon"), forState: .Normal)
        var leftNavigationBarButton : UIBarButtonItem = UIBarButtonItem(customView: leftNavigationButton)
        self.navigationItem.leftBarButtonItem = leftNavigationBarButton
    }
    
    func reloadSavedLocations() {
        ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(tableView, statusText: "Loading locations..")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            self.reloadingSavedLocations = true
            self.savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.tableView)
                self.reloadingSavedLocations = false
            })
        })
    }
    
    func closeIconButtonPressed(sender : UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return savedLocations.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 77
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var locationsTableViewCell : LocationsTableViewCell? = tableView.dequeueReusableCellWithIdentifier("LocationsTableViewCell") as? LocationsTableViewCell
        if(locationsTableViewCell == nil)
        {
            locationsTableViewCell = LocationsTableViewCell()
        }
        var locationWeatherData : LocationWeatherData = savedLocations[indexPath.row]
        locationsTableViewCell?.locationNameLabel.text = locationWeatherData.name.componentsSeparatedByString(",")[0]
        if(!locationWeatherData.isCurrentLocation)
        {
            locationsTableViewCell?.currentLocationIndicatorImageView.hidden = true
        }
        else
        {
            locationsTableViewCell?.currentLocationIndicatorImageView.hidden = false
        }
        //Temperature
        let temperatureUnit : TemperatureUnit = locationWeatherData.todayWeatherData.temperatureUnit
        let settingsTemperatureUnit : TemperatureUnit = AppSharedData.sharedInstance.settingsTemperatureUnit
        var temperature = locationWeatherData.todayWeatherData.temperature
        if(!(temperatureUnit == settingsTemperatureUnit))
        {
            temperature = UnitsConverter.sharedInstance.getCurrentUnitConvertedTemperature(temperature, temperatureUnit: temperatureUnit)
        }
        locationsTableViewCell?.locationTodayTemperatureLabel.text = NSString(format:"%0.0f°", temperature) as String
        locationsTableViewCell?.locationTodayWeatherDescriptionLabel.text = locationWeatherData.todayWeatherData.weatherDescription
        locationsTableViewCell?.locationTodayWeatherIconImageView.image = UIImage(named: locationWeatherData.todayWeatherData.weatherIconName)
        return locationsTableViewCell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete)
        {
            var locationToBeDeleted : LocationWeatherData = savedLocations[indexPath.row]
            DatabaseManager.sharedInstance.deleteLocation(locationToBeDeleted.locationID)
            //If it's the same location that we are currently displaying
            if(locationToBeDeleted.locationID == AppSharedData.sharedInstance.currentDisplayingLocation.locationID)
            {
                if(savedLocations.count > 1) {
                    var alternativeLocation : LocationWeatherData!
                    if(indexPath.row == 0)
                    {
                        alternativeLocation = savedLocations[indexPath.row + 1]
                    }
                    else
                    {
                        alternativeLocation = savedLocations[indexPath.row - 1]
                    }
                    DatabaseManager.sharedInstance.saveLastSelectedLocation(alternativeLocation.data())
                    AppSharedData.sharedInstance.currentDisplayingLocation = alternativeLocation
                }
                else if(savedLocations.count == 1) {
                    var emptyLocation : LocationWeatherData = LocationWeatherData()
                    DatabaseManager.sharedInstance.saveLastSelectedLocation(emptyLocation.data())
                    AppSharedData.sharedInstance.currentDisplayingLocation = emptyLocation
                }
            }
            savedLocations.removeAtIndex(indexPath.row)
            //Delete table row
            tableView.beginUpdates()
            var indexPathsToDelete : [AnyObject] = [AnyObject]()
            indexPathsToDelete.append(indexPath)
            tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 52
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        var footerView : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footerView.contentView.backgroundColor = UIColor.whiteColor()
        var addIconImage : UIImage! = UIImage(named: "AddIcon")
        var addLocationButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        addLocationButton.setBackgroundImage(addIconImage, forState: .Normal)
        addLocationButton.center.x = footerView.center.x
        addLocationButton.addTarget(self, action: "addLocationButtonPressed:", forControlEvents: .TouchUpInside)
        
        if(!reloadingSavedLocations)
        {
            footerView.addSubview(addLocationButton)
        }
    }
    
    func addLocationButtonPressed(sender : UIButton!) {
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    func propagateParsedWeatherData(weatherData: LocationWeatherData!, error: NSError!) {
        if(error == nil)
        {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            if(!errorMessageDidAppear)
            {
                displayAlertViewWithMessage(error.localizedDescription, otherButtonTitles: "")
                errorMessageDidAppear = true
            }
        }
        ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(gpaViewController.view)
    }
}

extension LocationsTableViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        place.getDetails { details in
            var placeDetails : PlaceDetails! = details
            var location : LocationWeatherData! = LocationWeatherData()
            var locationAlreadyExists : Bool! = false
            for(savedLocation : LocationWeatherData) in self.savedLocations {
                if(round(placeDetails.longitude) == round(Double(savedLocation.longitude)) && round(placeDetails.latitude) == round(Double(savedLocation.latitude)))
                {
                    locationAlreadyExists = true
                    break
                }
            }
            if(!locationAlreadyExists)
            {
                ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.gpaViewController.view, statusText: "Adding new location..")
                location.name = place.description
                println(placeDetails.description)
                location.longitude = Float(placeDetails.longitude)
                location.latitude = Float(placeDetails.latitude)
                var locationCoordinates : CLLocation = CLLocation(latitude: placeDetails.latitude, longitude: placeDetails.longitude)
                self.errorMessageDidAppear = false
                self.weatherDataManger.retrieveWeatherDataForLocation(locationCoordinates, customName: placeDetails.name, isCurrentLocation: false)
            }
            else
            {
                self.displayAlertViewWithMessage("You have already added this location!", otherButtonTitles: "")
            }
        }
    }
    
    func placeViewClosed() {
        if(!addingLocationInProgress)
        {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            displayAlertViewWithMessage("Please wait, adding new location is in progress..", otherButtonTitles: "")
        }
    }
    
    //Alert Views and HUD Views methods
    //Create and Alert View with a custom message
    func displayAlertViewWithMessage(alertViewMessage : String!, otherButtonTitles : String!) {
        var alertView : UIAlertView = UIAlertView(title: "Error", message: alertViewMessage, delegate: self, cancelButtonTitle: "OK")
        alertView.show()
    }
}

