//
//  PhotoCell.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 06/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoCell: UICollectionViewCell {

  var photo: Photo? {
    didSet {
      self.reload()
    }
  }
  private let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.imageView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let oldWidth = self.imageView.frame.width
    self.imageView.frame = self.bounds
    if self.imageView.frame.width != oldWidth {
      self.reload()
    }
  }

  private func reload() {
    if let photo = self.photo {
      let oldId = photo.id
      let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetId], options: nil).firstObject!
      self.getAssetThumbnail(asset: asset, size: self.imageView.frame.size.width, completion: { (image: UIImage?) -> (Void) in
        if self.photo?.id == oldId {
          self.imageView.image = image
        }
      })
    } else {
      self.imageView.image = nil
    }
  }

  private func getAssetThumbnail(asset: PHAsset, size: CGFloat, completion:@escaping (_ image: UIImage?) -> (Void)) {
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
      completion(result)
    })
  }
}
