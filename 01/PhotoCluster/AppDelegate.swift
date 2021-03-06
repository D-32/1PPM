//
//  AppDelegate.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 01/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    BackgroundProcessor.shared.start()

    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.backgroundColor = UIColor.white
    self.window?.makeKeyAndVisible()

    if UserDefaults.standard.bool(forKey: "fle_shown") {
      self.showMainApp()
    } else {
      self.window?.rootViewController = IntroViewController()
    }

    return true
  }

  func showMainApp() {
    let vc = PhotoStreamViewController()
    let nc = UINavigationController(rootViewController: vc)
    self.window?.rootViewController = nc
  }
}

