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
    
    //Create HUD View
    func startActivityIndicatorInViewWithStatusText(view : UIView, statusText : String) {
        var activityIndicator : MBProgressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        activityIndicator.labelText = statusText;
    }
    
    //Hide HUD View
    func stopActivityIndicatorInView(view : UIView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
    
    class var sharedInstance : ActivityIndicatorUtility {
        return _singletonInstance
    }
}
