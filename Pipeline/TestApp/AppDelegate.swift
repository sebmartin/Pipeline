//
//  AppDelegate.swift
//  TestApp
//
//  Created by Seb Martin on 2016-03-27.
//  Copyright © 2016 Seb Martin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // This app exists for the sole purpose of running as the Unit Test host app.  Without this app, any unit tests
  // using Cocoa's Target/Action API will fail.
  func applicationDidFinishLaunching(application: UIApplication) {
    let window = UIWindow()
    let viewController = ViewController()
    window.rootViewController = viewController
    window.addSubview(viewController.view)
    window.frame = UIScreen.mainScreen().bounds
    viewController.view.frame = window.bounds
    
    window.makeKeyAndVisible()
  }

}

