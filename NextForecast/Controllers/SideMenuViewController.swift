//
//  SideMenuViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/24/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

protocol SideMenuDelegate {
    func didSelectLocation(locationWeatherData : LocationWeatherData)
}

class SideMenuViewController: UITableViewController {
    
    var savedLocations : [LocationWeatherData]! = []
    var sideMenuDelegate : SideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var sideMenuTableViewCellNib : UINib = UINib(nibName: "SideMenuTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(sideMenuTableViewCellNib, forCellReuseIdentifier: "SideMenuTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.clearsSelectionOnViewWillAppear = false

    }

    override func viewDidAppear(animated: Bool) {
        reloadSavedLocations()
    }
    
    func reloadSavedLocations() {
        savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
        tableView.reloadData()
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
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionHeaderTitle : String! = ""
        if(section == 0)
        {
            sectionHeaderTitle = "Locations"
        }
        return sectionHeaderTitle
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var headerView : UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        headerView.textLabel.textAlignment = .Center
        headerView.textLabel.font = UIFont(name: "ProximaNova-Light", size: 15)
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        var footerView : UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        footerView.contentView.backgroundColor = UIColor.whiteColor()
        var addIconImage : UIImage! = UIImage(named: "AddIcon")
        var addLocationButton : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        addLocationButton.setBackgroundImage(addIconImage, forState: .Normal)
        addLocationButton.center.x = footerView.center.x
        addLocationButton.addTarget(self, action: "addLocationButtonPressed:", forControlEvents: .TouchUpInside)
        footerView.addSubview(addLocationButton)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var sideMenuTableViewCell : SideMenuTableViewCell? = tableView.dequeueReusableCellWithIdentifier("SideMenuTableViewCell") as? SideMenuTableViewCell
        if(sideMenuTableViewCell == nil)
        {
            sideMenuTableViewCell = SideMenuTableViewCell()
        }
        var locationWeatherData : LocationWeatherData = savedLocations[indexPath.row]
        sideMenuTableViewCell?.locationNameLabel.text = locationWeatherData.name.componentsSeparatedByString(",")[0]
        if(!locationWeatherData.isCurrentLocation)
        {
            sideMenuTableViewCell?.currentLocationIndicatorImageView.hidden = true
        }
        else
        {
            sideMenuTableViewCell?.currentLocationIndicatorImageView.hidden = false
        }
        return sideMenuTableViewCell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedLocation : LocationWeatherData = savedLocations[indexPath.row]
        if(self.sideMenuDelegate != nil)
        {
            sideMenuDelegate?.didSelectLocation(selectedLocation)
        }
    }
    
    func addLocationButtonPressed(sender : UIButton!) {
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var locationsTableViewController : LocationsTableViewController = storyboard.instantiateViewControllerWithIdentifier("LocationsTableViewController") as LocationsTableViewController
        var navigationController : UINavigationController = UINavigationController(rootViewController: locationsTableViewController)
        self.view.window?.rootViewController?.presentViewController(navigationController, animated: true, completion: nil)
    }

}
