//
//  Keys.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 04/02/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation

class Keys {

  static let shared = Keys()
  private var plist: NSDictionary!

  init () {
    let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
    plist = NSDictionary(contentsOfFile:filePath!)
  }

  func key(named keyname:String) -> String {
    let value = plist?.object(forKey: keyname) as! String
    return value
  }
}
