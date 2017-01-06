//
//  Photo.swift
//  Quaero
//
//  Created by Dylan Marriott on 16/06/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import RealmSwift

enum PhotoType: Int {
  case Normal = 0
  case Panorama
  case Screenshot
}

class Photo: Object {

  dynamic var id = NSUUID().uuidString
  dynamic var assetId = ""
  dynamic var creationDate: NSDate! {
    didSet {
      let calendar = NSCalendar.current
      let c = calendar.dateComponents([.day, .month, .year, .weekday, .hour], from: self.creationDate as Date)
      self.day = c.day!
      self.month = c.month!
      self.year = c.year!
      self.dayOfWeek = c.weekday!
      self.hour = c.hour!
    }
  }
  dynamic var day: Int = 0
  dynamic var month: Int = 0
  dynamic var year: Int = 0
  dynamic var dayOfWeek: Int = 0
  dynamic var hour: Int = 0

  dynamic var latitude: Double = 0.0
  dynamic var longitude: Double = 0.0
  dynamic var altitude: Double = 0.0

  dynamic var album: String?
  dynamic var containsText: Bool = false
  dynamic var containsFaces: Bool = false

  dynamic var _type: Int = PhotoType.Normal.rawValue
  var type: PhotoType {
    get {
      return PhotoType(rawValue: self._type)!
    }
    set {
      self._type = newValue.rawValue
    }
  }


  override static func ignoredProperties() -> [String] {
    return ["type"]
  }

  override class func primaryKey() -> String? {
    return "id"
  }
}
