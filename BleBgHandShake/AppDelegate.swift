//
//  AppDelegate.swift
//  BleBgHandShake
//
//  Created by Yusuke Takano on 2020/04/04.
//  Copyright © 2020 Yusuke Takano. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BlePeripheralManager.instatiate()
        BleCentralManager.instatiate()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print(" <<<<< applicationDidEnterBackground >>>>> ")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print(" <<<<< applicationWillEnterForeground >>>>> ")
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

