//
//  ImportHelper.swift
//  Quaero
//
//  Created by Dylan Marriott on 16/06/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Photos

class ImportHelper {

  private var queue = [String]()

  func importAssets(_ assetIds: [String], completion:(Void)->(Void)) {
    self.queue = assetIds
    self.process {
      completion()
    }
  }

  private func process(_ completion:(Void)->(Void)) {
    if (self.queue.isEmpty) {
      completion()
      return
    }

    let next = self.queue.first!
    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [next], options: nil).firstObject!
    self.processAsset(asset) {
      self.queue.removeFirst()
      self.process(completion)
    }
  }

  typealias ProcessAssetCompletion = (Void) -> (Void)
  private func processAsset(_ asset: PHAsset, completion: ProcessAssetCompletion) {
    print("Processing asset:", asset.localIdentifier)

    let photo = Photo()
    photo.assetId = asset.localIdentifier
    photo.creationDate = asset.creationDate ?? Date()
    if let location = asset.location {
      photo.latitude = location.coordinate.latitude
      photo.longitude = location.coordinate.longitude
      photo.altitude = location.altitude
    }

    let realm = try! Realm()
    try! realm.write {
      realm.add(photo)
    }

    completion()
  }
}
