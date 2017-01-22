//
//  Photo.swift
//  Quaero
//
//  Created by Dylan Marriott on 16/06/16.
//  Copyright © 2016 Dylan Marriott. All rights reserved.
//

import Foundation
import RealmSwift
import Photos

enum PhotoType: Int {
  case Normal = 0
  case Panorama
  case Screenshot
}

class Photo: Object {

  dynamic var id = NSUUID().uuidString
  dynamic var assetId = ""
  dynamic var creationDate: Date! {
    didSet {
      let calendar = NSCalendar.current
      let c = calendar.dateComponents([.day, .month, .year, .weekday, .hour, .minute], from: self.creationDate)
      self.day = c.day!
      self.month = c.month!
      self.year = c.year!
      self.dayOfWeek = c.weekday!
      self.hour = c.hour!
      self.minute = c.minute!
    }
  }
  dynamic var day: Int = 0
  dynamic var month: Int = 0
  dynamic var year: Int = 0
  dynamic var dayOfWeek: Int = 0
  dynamic var hour: Int = 0
  dynamic var minute: Int = 0

  dynamic var latitude: Double = 0.0
  dynamic var longitude: Double = 0.0
  dynamic var altitude: Double = 0.0

  dynamic var album: String?
  dynamic var containsText: Bool = false
  dynamic var containsFaces: Bool = false
  dynamic var panorama: Bool = false

  dynamic var _type: Int = PhotoType.Normal.rawValue
  var type: PhotoType {
    get {
      return PhotoType(rawValue: self._type)!
    }
    set {
      self._type = newValue.rawValue
    }
  }

  var cachedThumbnail: UIImage?


  override static func ignoredProperties() -> [String] {
    return ["type", "cachedThumbnail"]
  }

  override class func primaryKey() -> String? {
    return "id"
  }

  func totalMinutesInDay() -> Int {
    return self.hour * 60 + self.minute
  }

  func getAssetThumbnail(asset: PHAsset, size: CGFloat, cache: Bool, completion:@escaping (_ image: UIImage?) -> (Void)) {
    if let cachedThumbnail = self.cachedThumbnail {
      completion(cachedThumbnail)
      return
    }
    let retinaScale = UIScreen.main.scale
    let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)//(size * retinaScale, size * retinaScale)
    let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
    let square = CGRect(x:0, y: 0,width: CGFloat(cropSizeLength),height: CGFloat(cropSizeLength))
    let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))

    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()

    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat
    options.resizeMode = .exact
    options.normalizedCropRect = cropRect

    manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
      if cache {
        self.cachedThumbnail = result
      }
      completion(result)
    })
  }
}
