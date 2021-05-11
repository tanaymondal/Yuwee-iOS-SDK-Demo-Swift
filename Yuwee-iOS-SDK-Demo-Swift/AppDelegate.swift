//
//  AppDelegate.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/02/21.
//

import UIKit
import KYDrawerController
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var meetingData: JSON = JSON("")
    static var callTokenId = ""
    static var passCode = ""
    static var isAudioEnabled = false
    static var isVideoEnabled = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Yuwee.sharedInstance().initWithAppId(Constants.appId, appSecret: Constants.appSecret, clientId: Constants.clientId)
        
        return true
    }
    
    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }


}

