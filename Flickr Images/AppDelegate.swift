//
//  AppDelegate.swift
//  Flickr Images
//
//  Created by Consultant on 06/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let navigationController = window?.rootViewController as? UINavigationController,
            let masterViewController = navigationController.viewControllers.first as? MasterViewController {
            masterViewController.model = MasterViewControllerModel(FlickrClient())
        }
        
        return true
    }

}

