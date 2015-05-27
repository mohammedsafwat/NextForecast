//
//  ActivityIndicatorUtility.swift
//  NextForecast
//
//  Created by Mohammad Safwat on 5/24/15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import MBProgressHUD

private let _singletonInstance = ActivityIndicatorUtility()

class ActivityIndicatorUtility: NSObject {
    var activityIndicator : MBProgressHUD!
    //Create HUD View
    func startActivityIndicatorInViewWithStatusText(view : UIView, statusText : String) {
        activityIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
        activityIndicator.labelText = statusText
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    //Hide HUD View
    func stopActivityIndicatorInView(view : UIView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
        activityIndicator.userInteractionEnabled = true
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    class var sharedInstance : ActivityIndicatorUtility {
        return _singletonInstance
    }
}
