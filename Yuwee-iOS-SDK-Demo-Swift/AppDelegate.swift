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
        
//        let mainViewController   = MainViewController()
//                let drawerViewController = DrawerViewController()
//                let drawerController     = KYDrawerController()
//                drawerController.mainViewController = UINavigationController(
//                    rootViewController: mainViewController
//                )
//                drawerController.drawerViewController = drawerViewController
//
//                /* Customize
//                drawerController.drawerDirection = .Right
//                drawerController.drawerWidth     = 200
//                */
//
//                window = UIWindow(frame: UIScreen.mainScreen().bounds)
//                window?.rootViewController = drawerController
//                window?.makeKeyAndVisible()
        
        return true
    }


}

