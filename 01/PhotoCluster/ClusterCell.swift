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
import MapKit

class ClusterCellModel: NSObject {
  dynamic var selected = true
  let cluster: Cluster
  init(cluster: Cluster) {
    self.cluster = cluster
    super.init()
  }
}

class ClusterCell: UICollectionViewCell {

  var model: ClusterCellModel? {
    willSet {
      if !dummy { self.model?.removeObserver(self, forKeyPath: "selected") }
    }
    didSet {
      if !dummy { self.model!.addObserver(self, forKeyPath: "selected", options: .new, context: nil); }
      self.reload()
    }
  }
  var dummy = false

  private let titleLabel = UILabel()
  private let colorLabel = UIView()
  private let thumbnailView = UIImageView()
  private var photoCollectionView: UICollectionView!
  fileprivate let numberOfPhotosPerRow = 5

  convenience init(dummy: Bool) {
    self.init(frame: CGRect.zero)
    self.dummy = dummy
  }

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

    self.colorLabel.layer.cornerRadius = 10
    self.addSubview(self.colorLabel)

    self.thumbnailView.layer.cornerRadius = 35
    self.thumbnailView.clipsToBounds = true
    self.addSubview(self.thumbnailView)

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

  deinit {
    if !dummy { self.model?.removeObserver(self, forKeyPath: "selected") }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "selected" {
      self.alpha = (self.model?.selected ?? false) ? 1.0 : 0.2
    }
  }

  private func reload() {
    let cluster = self.model!.cluster

    self.titleLabel.text = cluster.title
    self.colorLabel.backgroundColor = cluster.color
    self.layoutSubviews()
    self.photoCollectionView.reloadData()

    if let zoomLevel = cluster.zoomLevel {
      self.thumbnailView.downloadedFrom(link: "https://maps.googleapis.com/maps/api/staticmap?center=\(cluster.center[0]),\(cluster.center[1])&zoom=\(zoomLevel)&size=140x140&key=")
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let titleWidth = self.frame.width - 40
    self.titleLabel.frame.size.width = titleWidth
    self.titleLabel.sizeToFit()
    self.titleLabel.frame = CGRect(x: 20, y: 20, width: titleWidth, height: self.titleLabel.frame.height)
    var end = titleLabel.frame.maxY
    self.colorLabel.frame = CGRect.zero
    self.thumbnailView.frame = CGRect.zero

    if self.model?.cluster.color != nil {
      self.colorLabel.frame.origin = CGPoint(x: self.frame.width / 2 - 10, y: 20)
      self.colorLabel.frame.size = CGSize(width: 20, height: 20)
      end = self.colorLabel.frame.maxY
    } else if self.model?.cluster.zoomLevel != nil {
      self.thumbnailView.frame.origin = CGPoint(x: self.frame.width / 2 - 35, y: 20)
      self.thumbnailView.frame.size = CGSize(width: 70, height: 70)
      end = self.thumbnailView.frame.maxY
    }

    let items = min(self.model?.cluster.photos.count ?? 0, 20)
    var rows = Int(items / numberOfPhotosPerRow)
    if items % numberOfPhotosPerRow != 0 {
      rows += 1
    }
    self.photoCollectionView.frame = CGRect(x: 0, y: end + 20, width: self.frame.width, height: self.previewPhotoSize() * CGFloat(rows))
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
    if dummy { return 0 }
    return min(self.model?.cluster.photos.count ?? 0, 20)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPreviewCell", for: indexPath) as! PhotoPreviewCell
    cell.photo = self.model!.cluster.photos[indexPath.row]
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

