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
    
    private func openDatabase() -> Bool {
        db = FMDatabase(path:dbFilePath)
        
        if(db.open())
        {
            return true
        }
        return false
    }
    
    private func closeDatabase() {
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
        
        let fetchCountQuery = db.intForQuery("SELECT COUNT(*) FROM Locations WHERE locationID=?", locationID)
        if(fetchCountQuery == 0)
        {
            let addSuccessful = db.executeUpdate("INSERT INTO Locations(locationID,locationData) VALUES (?,?)", locationID, locationData)
            closeDatabase()
            if(!addSuccessful)
            {
                return false
            }
        }
        else
        {
            //Update the location data only if location exists in database
            let updateSuccessful = db.executeUpdate("UPDATE Locations SET locationData=? WHERE locationID=?", locationData, locationID)
            closeDatabase()
            if(!updateSuccessful)
            {
                return false
            }
        }
        return true
    }
    
    func deleteLocation(locationID : String) -> Bool {
        openDatabase()
        
        let deleteQuery = db.executeUpdate("DELETE FROM Locations WHERE locationID=?", locationID)
        closeDatabase()
        if(!deleteQuery)
        {
            return false
        }
        return true
    }
    
    func deleteAllLocations() -> Bool {
        openDatabase()
        let deleteQuery = "DELETE FROM Locations"
        
        let deleteSuccessful = db.executeUpdate(deleteQuery, withArgumentsInArray: [])
        closeDatabase()
        if(!deleteSuccessful)
        {
            return false
        }
        return true
    }
    
    func getLastSelectedLocation() -> LocationWeatherData {
        var lastSelectedLocation : LocationWeatherData! = LocationWeatherData()
        openDatabase()
        let mainQuery = "SELECT locationData FROM LastSelectedLocation"
        let rsMain: FMResultSet? = db.executeQuery(mainQuery, withArgumentsInArray: [])
        
        while (rsMain!.next() == true) {
            var locationData : NSData! = rsMain?.dataForColumn("locationData")
            lastSelectedLocation = NSKeyedUnarchiver.unarchiveObjectWithData(locationData) as LocationWeatherData
        }
        closeDatabase()
        return lastSelectedLocation
    }
    
    func saveLastSelectedLocation(locationData : NSData) -> Bool {
        openDatabase()
        let fetchCountQuery = db.intForQuery("SELECT COUNT(*) FROM LastSelectedLocation", locationData)
        if(fetchCountQuery == 0)
        {
            let addSuccessful = db.executeUpdate("INSERT INTO LastSelectedLocation(locationData) VALUES (?)", locationData)
            closeDatabase()
            if(!addSuccessful)
            {
                return false
            }
        }
        else
        {
            let updateSuccessful = db.executeUpdate("UPDATE LastSelectedLocation SET locationData=?", locationData)
            closeDatabase()
            if(!updateSuccessful)
            {
                return false
            }
        }
        return true
    }
    
    class var sharedInstance : DatabaseManager {
        return _singletonInstance
    }
}
