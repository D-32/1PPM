//
//  ClusterCell.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 21/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ClusterCell: UICollectionViewCell {

  var cluster: Cluster? {
    didSet {
      self.reload()
    }
  }

  private let titleLabel = UILabel()
  private var photoCollectionView: UICollectionView!
  fileprivate let numberOfPhotosPerRow = 5

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.white
    self.layer.cornerRadius = 4

    self.clipsToBounds = true

    self.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
    self.titleLabel.textColor = UIColor(white: 0.1, alpha: 1.0)
    self.titleLabel.textAlignment = .center
    self.titleLabel.numberOfLines = 0
    self.addSubview(self.titleLabel)

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 1

    self.photoCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    self.photoCollectionView.dataSource = self
    self.photoCollectionView.delegate = self
    self.photoCollectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: "PhotoPreviewCell")
    self.photoCollectionView.backgroundColor = UIColor.clear
    self.photoCollectionView.isScrollEnabled = false
    self.photoCollectionView.clipsToBounds = true
    self.photoCollectionView.isUserInteractionEnabled = false
    self.addSubview(self.photoCollectionView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func reload() {
    self.titleLabel.text = self.cluster?.title
    self.photoCollectionView.reloadData()
    self.layoutSubviews()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let titleWidth = self.frame.width - 40
    self.titleLabel.frame.size.width = titleWidth
    self.titleLabel.sizeToFit()
    self.titleLabel.frame = CGRect(x: 20, y: 20, width: titleWidth, height: self.titleLabel.frame.height)

    let items = min(self.cluster?.photos.count ?? 0, 20)
    var rows = Int(items / numberOfPhotosPerRow)
    if items % numberOfPhotosPerRow != 0 {
      rows += 1
    }
    self.photoCollectionView.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 20, width: self.frame.width, height: self.previewPhotoSize() * CGFloat(rows))
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width, height: self.photoCollectionView.frame.maxY)
    //return CGSize(width: size.width, height: self.titleLabel.frame.maxY + 20)
  }

  fileprivate func previewPhotoSize() -> CGFloat {
    return CGFloat(Int(self.frame.width / CGFloat(numberOfPhotosPerRow)))
  }
}

extension ClusterCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return min(self.cluster?.photos.count ?? 0, 20)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPreviewCell", for: indexPath) as! PhotoPreviewCell
    cell.photo = self.cluster!.photos[indexPath.row]
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let s = self.previewPhotoSize()
    return CGSize(width: s, height: s)
  }
}

fileprivate class PhotoPreviewCell: UICollectionViewCell {

  var photo: Photo? {
    didSet {
      self.reload()
    }
  }

  private let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(self.imageView)
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
    if self.imageView.frame.size.width == 0 {
      return
    }
    if let photo = self.photo {
      let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetId], options: nil).firstObject!
      photo.getAssetThumbnail(asset: asset, size: self.imageView.frame.size.width, cache: false, completion: { (image: UIImage?) -> (Void) in
        self.imageView.image = image
      })
    } else {
      self.imageView.image = nil
    }
  }
}

