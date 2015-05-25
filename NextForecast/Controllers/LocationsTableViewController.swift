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

class LocationsTableViewController: UITableViewController, WeatherDataManagerDelegate {
    
    var savedLocations : [LocationWeatherData]! = []
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: AppSharedData.sharedInstance.googlePlacesAPIKey,
        placeType: .All
    )
    var weatherDataManger : WeatherDataManager! = WeatherDataManager()
    var addingLocationInProgress : Bool!
    var errorMessageDidAppear : Bool!
    
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
            self.savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.tableView)
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
        locationsTableViewCell?.locationTodayTemperatureLabel.text = NSString(format:"%0.0f°", locationWeatherData.todayWeatherData.temperature)
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
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        var footerView : UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        footerView.contentView.backgroundColor = UIColor.whiteColor()
        var addIconImage : UIImage! = UIImage(named: "AddIcon")
        var addLocationButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        addLocationButton.setBackgroundImage(addIconImage, forState: .Normal)
        addLocationButton.center.x = footerView.center.x
        addLocationButton.addTarget(self, action: "addLocationButtonPressed:", forControlEvents: .TouchUpInside)
        footerView.addSubview(addLocationButton)
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
                displayAlertViewWithMessage(error.localizedDescription, otherButtonTitles: nil)
                errorMessageDidAppear = true
            }
        }
        ActivityIndicatorUtility.sharedInstance.stopActivityIndicatorInView(self.view)
    }
}

extension LocationsTableViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        place.getDetails { details in
            var placeDetails : PlaceDetails = details
            var location : LocationWeatherData = LocationWeatherData()
            location.name = placeDetails.name
            location.longitude = Float(placeDetails.longitude)
            location.latitude = Float(placeDetails.latitude)
            var locationCoordinates : CLLocation = CLLocation(latitude: placeDetails.latitude, longitude: placeDetails.longitude)
            ActivityIndicatorUtility.sharedInstance.startActivityIndicatorInViewWithStatusText(self.view, statusText: "Adding new location..")
            self.weatherDataManger.retrieveWeatherDataForLocation(locationCoordinates, customName: location.name)
        }
        
    }
    
    func placeViewClosed() {
        if(!addingLocationInProgress)
        {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            displayAlertViewWithMessage("Please wait, adding new location is in progress..", otherButtonTitles: nil)
        }
    }
    
    //Alert Views and HUD Views methods
    //Create and Alert View with a custom message
    func displayAlertViewWithMessage(alertViewMessage : String!, otherButtonTitles : String!) {
        let alertController = UIAlertController(title: "Error!", message: alertViewMessage, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

