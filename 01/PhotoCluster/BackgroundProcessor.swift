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
import Photos
import CoreImage

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
    self.loadThumbImage(photo: photo, metaData: metaData) {
      self.loadFullImage(photo: photo, metaData: metaData) {
        let realm = try! Realm()
        try! realm.write {
          photo.metaData = metaData
        }
        completion()
      }
    }
  }

  private func loadThumbImage(photo: Photo, metaData: PhotoMetaData, completion:@escaping (Void)->(Void)) {
    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetId], options: nil).firstObject!
    photo.getAssetThumbnail(asset: asset, size: 320, cache: false, completion: { (_image: UIImage?) -> (Void) in
      if let image = _image {
        let avgColor = image.areaAverage()
        let comps = avgColor.cgColor.components!
        metaData.red = Double(comps[0])
        metaData.green = Double(comps[1])
        metaData.blue = Double(comps[2])


        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        if avgColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
          metaData.brightness = Double(brightness)
        }
      }
      completion()
    })
  }

  private func loadFullImage(photo: Photo, metaData: PhotoMetaData, completion:@escaping (Void)->(Void)) {
    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetId], options: nil).firstObject!
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat

    manager.requestImageData(for: asset, options: options) { (_data, uti, orientation, info) in
      if let data = _data {
        let image = CIImage(data: data)!
        let options = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
        let faces = faceDetector.features(in: image)
        metaData.faces = faces.count

        let textDetector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: options)!
        let texts = textDetector.features(in: image)
        metaData.texts = texts.count
      }
      completion()
    }
  }
}
