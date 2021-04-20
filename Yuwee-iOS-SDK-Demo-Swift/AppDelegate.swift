//
//  AppDelegate.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/02/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Yuwee.sharedInstance().initWithAppId(Constants.appId, appSecret: Constants.appSecret, clientId: Constants.clientId)
        
        return true
    }


}

