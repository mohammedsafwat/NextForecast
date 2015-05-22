//
//  DatabaseManager.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/22/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import FMDB

private let _singletonInstance = DatabaseManager()

class DatabaseManager: NSObject {
    
    var dbFilePath : String! = ""
    
    func initializeDB() -> Bool {
        //Get path of sqlite database
        if let myFileUrl : NSURL = NSBundle.mainBundle().URLForResource(AppSharedData.sharedInstance.DATABASE_RESOURCE_NAME, withExtension: AppSharedData.sharedInstance.DATABASE_RESOURCE_TYPE){
            dbFilePath = myFileUrl.absoluteString
            return true
        }
        return false
    }
    
    func openDB() -> Bool {
        let db = FMDatabase(path:dbFilePath)
        if(db.open())
        {
            return true
        }
        return false
    }
    
    func getSavedLocations(db : FMDatabase) -> [LocationWeatherData] {
        var savedLocations : [LocationWeatherData] = []
        
        let mainQuery = "SELECT locationData FROM Locations"
        let rsMain: FMResultSet? = db.executeQuery(mainQuery, withArgumentsInArray: [])
        
        while (rsMain!.next() == true) {
            let locationData = rsMain?.dataForColumn("locationData")
            var locationWeatherData : LocationWeatherData = LocationWeatherData()
            locationWeatherData = NSKeyedUnarchiver.unarchiveObjectWithData(locationData!) as LocationWeatherData
            savedLocations.append(locationWeatherData)
        }
        
        return savedLocations
    }
    
    class var sharedInstance : DatabaseManager {
        return _singletonInstance
    }
}
