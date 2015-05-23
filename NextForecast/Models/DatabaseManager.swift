//
//  DatabaseManager.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/22/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

private let _singletonInstance = DatabaseManager()

class DatabaseManager: NSObject {
    
    var dbFilePath : String! = ""
    var db : FMDatabase!
    
    override init() {}
    
    func initializeDB() -> Bool {
        //Get path of sqlite database
        let databaseFileUrl : NSURL! = NSBundle.mainBundle().URLForResource(AppSharedData.sharedInstance.DATABASE_RESOURCE_NAME, withExtension: AppSharedData.sharedInstance.DATABASE_RESOURCE_TYPE)
        let dbfile = "/" + AppSharedData.sharedInstance.DATABASE_FILE_NAME;
        
        let documentFolderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        dbFilePath = documentFolderPath.stringByAppendingString(dbfile)
        let dbFileURL : NSURL! = NSURL(fileURLWithPath: dbFilePath)
        
        let filemanager = NSFileManager.defaultManager()
        if (!filemanager.fileExistsAtPath(dbFilePath))
        {
            if (databaseFileUrl.absoluteString == nil)
            {
                return false
            }
            else
            {
                var error: NSError?
                let copySuccessful = filemanager.copyItemAtURL(databaseFileUrl, toURL: dbFileURL, error: &error)
                if(!copySuccessful)
                {
                    return false
                }
            }
        }

        return true
    }
    
    func openDatabase() -> Bool {
        db = FMDatabase(path:dbFilePath)
        
        if(db.open())
        {
            return true
        }
        return false
    }
    
    func closeDatabase() {
        db.close()
    }
    
    func getSavedLocations() -> [LocationWeatherData] {
        var savedLocations : [LocationWeatherData] = []
        openDatabase()
        let mainQuery = "SELECT locationData FROM Locations"
        let rsMain: FMResultSet? = db.executeQuery(mainQuery, withArgumentsInArray: [])
        
        while (rsMain!.next() == true) {
            var locationData : NSData! = rsMain?.dataForColumn("locationData")
            var locationWeatherData : LocationWeatherData = LocationWeatherData()
            locationWeatherData = NSKeyedUnarchiver.unarchiveObjectWithData(locationData) as LocationWeatherData
            savedLocations.append(locationWeatherData)
        }
        closeDatabase()
        return savedLocations
    }
    
    func saveLocation(locationID : String, locationData : NSData) -> Bool {
        //Check if the location already exists in Locations table
        openDatabase()
        
        let fetchQuery = NSString(format: "SELECT locationID FROM Locations WHERE locationID='%@'", locationID)
        let queryResults: FMResultSet? = db.executeQuery(fetchQuery, withArgumentsInArray: [])
        if((queryResults!.next()) == false)
        {
            //let addQuery = NSString(format: "INSERT INTO Locations (locationID, locationData) VALUES ('%@', '%@')", locationID, locationData)
            //let addSuccessful = db.executeUpdate(addQuery, withArgumentsInArray: nil)
            db.beginTransaction()
            let addSuccessful = db.executeUpdate("INSERT INTO Locations (locationID, locationData) VALUES (?,?)", locationID, locationData)
            if(addSuccessful)
            {
                db.commit()
                closeDatabase()
                return true
            }
        }
        else
        {
            //Update the location data only
            while (queryResults!.next() == true) {
                
            }
        }
        return false
    }
    
    func clearDatabase() -> Bool {
        openDatabase()
        let deleteQuery = "DELETE FROM Locations"
        
        let deleteSuccessful = db.executeUpdate(deleteQuery, withArgumentsInArray: [])
        if(deleteSuccessful)
        {
            closeDatabase()
            return true
        }
        return false
    }
    
    class var sharedInstance : DatabaseManager {
        return _singletonInstance
    }
}
