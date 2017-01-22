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
import RealmSwift

class PhotoCell: UICollectionViewCell {

  var photo: Photo? {
    didSet {
      self.reload()
    }
  }
  var asset: PHAsset! // set before photo

  private var oldId = ""
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
      self.oldId = photo.id
      photo.getAssetThumbnail(asset: self.asset, size: self.imageView.frame.size.width, cache: true, completion: { (image: UIImage?) -> (Void) in
        if self.photo?.id == self.oldId {
          self.imageView.image = image
        } else {
          print("not same")
        }
      })
    } else {
      self.oldId = ""
      self.imageView.image = nil
    }
  }
}
