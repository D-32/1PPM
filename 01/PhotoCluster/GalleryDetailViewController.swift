//
//  GalleryDetailViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 02/02/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import Photos

class GalleryDetailViewController: UIViewController {

  let photo: Photo
  private let iv = UIImageView()

  init(photo: Photo) {
    self.photo = photo
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    iv.frame = self.view.bounds
    iv.contentMode = .scaleAspectFit
    self.view.addSubview(iv)

    self.reloadImage()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let old = iv.frame
    iv.frame = self.view.bounds
    if !old.equalTo(iv.frame) {
      self.reloadImage()
    }
  }

  private func reloadImage() {
    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetId], options: nil).firstObject!
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat

    manager.requestImage(for: asset, targetSize: iv.bounds.size, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
      self.iv.image = result
    })
  }
}
