//
//  SecondViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/14/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var forecastTableView: UITableView!
    let forecastTableViewCellHeight : CGFloat! = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Forecast"
        
        //Load ForecastTableViewCell file
        var forecastTableViewCellNib : UINib = UINib(nibName: "ForecastTableViewCell", bundle: NSBundle.mainBundle())
        forecastTableView.registerNib(forecastTableViewCellNib, forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.dataSource = self
        forecastTableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        //Update the current saved locations arrau in AppSharedData
        AppSharedData.sharedInstance.savedLocations = DatabaseManager.sharedInstance.getSavedLocations()
        var currentSelectedLocationID : String! = AppSharedData.sharedInstance.currentSelectedLocationID
        for locationWeatherData in AppSharedData.sharedInstance.savedLocations {
            if(locationWeatherData.locationID == currentSelectedLocationID)
            {
                self.title = locationWeatherData.name
            }
        }
    }
    
    // MARK: - TableViewDelegates
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return forecastTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSharedData.sharedInstance.savedLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var forecastTableViewCell : ForecastTableViewCell? = tableView.dequeueReusableCellWithIdentifier("ForecastTableViewCell") as? ForecastTableViewCell
        
        if(forecastTableViewCell == nil)
        {
            forecastTableViewCell = ForecastTableViewCell()
        }
        
        var locationWeatherData : LocationWeatherData = AppSharedData.sharedInstance.savedLocations[indexPath.row]
        var forecastDayWeatherData : SingleDayWeatherData = locationWeatherData.sevenDaysForecastWeatherData[indexPath.row]
        forecastTableViewCell?.forecastDayNameLabel.text = forecastDayWeatherData.dayName
        forecastTableViewCell?.forecastDayTemperatureLabel.text = NSString(format: "%0.0f°",forecastDayWeatherData.temperature)
        forecastTableViewCell?.forecastDayWeatherDescriptionLabel.text = forecastDayWeatherData.weatherDescription
        var weatherIconImage : UIImage! = UIImage(named: forecastDayWeatherData.weatherIconName)
        forecastTableViewCell?.forecastDayWeatherIconImageView.image = weatherIconImage
        return forecastTableViewCell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

