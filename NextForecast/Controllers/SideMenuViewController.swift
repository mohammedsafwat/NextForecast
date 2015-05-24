//
//  SideMenuViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/24/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {

    var savedLocations : [LocationWeatherData]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        
        var sideMenuTableViewCellNib : UINib = UINib(nibName: "SideMenuTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(sideMenuTableViewCellNib, forCellReuseIdentifier: "SideMenuTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func viewDidAppear(animated: Bool) {

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

}
