//
//  SettingsViewController.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/15/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIActionSheetDelegate {
    
    @IBOutlet weak var unitOfLengthSettingsButton: UIButton!
    
    @IBOutlet weak var unitOfTemperatureSettingsButton: UIButton!
    let unitOfLengthActionSheetTitle = "Unit of length"
    let unitOfTemperatureActionSheetTitle = "Unit of temperature"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Settings"
        unitOfLengthSettingsButton.addTarget(self, action: "openUnitOfLengthSettingsActionSheet:", forControlEvents: .TouchUpInside)
        unitOfTemperatureSettingsButton.addTarget(self, action: "openUnitOfTemperatureSettingsActionSheet:", forControlEvents: .TouchUpInside)
        
        updateTemperatureUnitSettingsButtonTitle(UserDefaultsManager.sharedInstance.getTemperatureUnitFromUserDefaults())
        updateLengthUnitSettingsButtonTitle(UserDefaultsManager.sharedInstance.getSpeedUnitFromUserDefaults())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openUnitOfLengthSettingsActionSheet(sender : UIButton!)
    {
        displayActionSheet(unitOfLengthActionSheetTitle, buttonsTitles: ["Meters", "Miles"])
    }
    
    func openUnitOfTemperatureSettingsActionSheet(sender : UIButton!)
    {
        displayActionSheet(unitOfTemperatureActionSheetTitle, buttonsTitles: ["C", "F"])
    }
    
    private func displayActionSheet(title : String, buttonsTitles : [String]) {
        let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: buttonsTitles[0], buttonsTitles[1])
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let buttonTitle = actionSheet.buttonTitleAtIndex(buttonIndex)
        if(actionSheet.title == unitOfLengthActionSheetTitle)
        {
            if(buttonTitle == "Meters")
            {
                AppSharedData.sharedInstance.settingsSpeedUnit = .kmPerHour
            }
            else if(buttonTitle == "Miles")
            {
                AppSharedData.sharedInstance.settingsSpeedUnit = .milesPerHour
            }
            updateLengthUnitSettingsButtonTitle(AppSharedData.sharedInstance.settingsSpeedUnit)
            UserDefaultsManager.sharedInstance.saveSpeedUnitToUserDefaults(AppSharedData.sharedInstance.settingsSpeedUnit)
        }
        else if(actionSheet.title == unitOfTemperatureActionSheetTitle)
        {
            if(buttonTitle == "C")
            {
                AppSharedData.sharedInstance.settingsTemperatureUnit = .C
            }
            else if(buttonTitle == "F")
            {
                AppSharedData.sharedInstance.settingsTemperatureUnit = .F
            }
            updateTemperatureUnitSettingsButtonTitle(AppSharedData.sharedInstance.settingsTemperatureUnit)
            UserDefaultsManager.sharedInstance.saveTemperatureUnitToUserDefaults(AppSharedData.sharedInstance.settingsTemperatureUnit)
        }
    }
    
    func updateTemperatureUnitSettingsButtonTitle(temperatureUnit : TemperatureUnit)
    {
        var buttonTitle : String! = ""
        if(temperatureUnit == .C)
        {
            buttonTitle = "C"
        }
        else if(temperatureUnit == .F)
        {
            buttonTitle = "F"
        }
        unitOfTemperatureSettingsButton.setTitle(buttonTitle, forState: .Normal)
    }
    
    func updateLengthUnitSettingsButtonTitle(speedUnit : SpeedUnit)
    {
        var buttonTitle : String! = ""
        if(speedUnit == .kmPerHour)
        {
            buttonTitle = "Meters"
        }
        else if (speedUnit == .milesPerHour)
        {
            buttonTitle = "Miles"
        }
        unitOfLengthSettingsButton.setTitle(buttonTitle, forState: .Normal)
    }
}
