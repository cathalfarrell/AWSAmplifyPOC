//
//  AppDelegate.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 01/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        print("🔆 [CURRENT ENVIRONMENT]: \(Environment.currentEnvironment()) 🏵")

        return true
    }
}
