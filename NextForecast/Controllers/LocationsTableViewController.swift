//
//  LocationsTableViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/25/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    
    var savedLocations : [LocationWeatherData]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Locations"
        
        var locationsTableViewCellNib : UINib = UINib(nibName: "LocationsTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(locationsTableViewCellNib, forCellReuseIdentifier: "LocationsTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        createNavigationBarRightAndLeftbuttons()
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
        savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
        tableView.reloadData()
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
    
}
