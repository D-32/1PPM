//
//  BackgroundProcessor.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 31/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CoreLocation

class BackgroundProcessor: NSObject {

  static let shared = BackgroundProcessor()
  private var processing = false
  private let geocoder = CLGeocoder()

  func start() {
    if processing {
      return
    }
    processing = true
    self.process()
  }

  @objc private func process() {
    let realm = try! Realm()
    let photos = realm.objects(Photo.self).filter { $0.metaData == nil }
    if photos.isEmpty {
      processing = false
      return
    }
    self.loadMetaData(photo: photos.first!) {
      self.process()
    }
  }

  private func loadMetaData(photo: Photo, completion:@escaping (Void)->(Void)) {
    let metaData = PhotoMetaData()

    let realm = try! Realm()
    try! realm.write {
      photo.metaData = metaData
    }
    completion()
  }

}
