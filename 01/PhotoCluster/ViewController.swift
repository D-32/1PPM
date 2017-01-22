//
//  ViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 01/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class ViewController: UIViewController {

  private var collectionView: UICollectionView!
  fileprivate var photos: [Photo]?
  fileprivate var assetCache = [String:PHAsset]()
  private var filterItem: UIBarButtonItem!

  init(photos: [Photo]? = nil) {
    super.init(nibName: nil, bundle: nil)
    self.photos = photos
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white

    self.title = "Photos"

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2
    let itemWidth = (self.view.frame.width - layout.minimumInteritemSpacing * 3) / 4
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    layout.scrollDirection = .vertical

    self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
    self.collectionView.dataSource = self
    self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    self.collectionView.backgroundColor = UIColor.white
    self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
    self.view.addSubview(self.collectionView)


    let statusBarUnderlay = UIView()
    statusBarUnderlay.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
    statusBarUnderlay.backgroundColor = UIColor.white.withAlphaComponent(0.95)
    self.view.addSubview(statusBarUnderlay)

    self.filterItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterItemTapped))
    self.updateFilterItem()
    self.navigationItem.rightBarButtonItem = self.filterItem


    if self.photos == nil {
      // Only load new photos if we didn't provide any photos during init.
      // This means this is the initial view controller.
      let nc = NotificationCenter.default
      let queue = OperationQueue.main
      nc.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: queue) { (n: Notification) in
        self.loadNewPhotos {
          self.reload()
        }
      }

      self.loadNewPhotos {
        self.reload()
      }
    }
  }

  private func reload() {
    let realm = try! Realm()
    self.photos = Array(realm.objects(Photo.self).sorted(byProperty: "creationDate", ascending: false))
    self.collectionView.reloadData()
    self.updateFilterItem()
  }

  private func updateFilterItem() {
    self.filterItem.isEnabled = self.photos?.count ?? 0 > 10
  }

  func filterItemTapped() {
    let alert = UIAlertController(title: "Choose Filter Type", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "🕑 Time", style: .default, handler: { _ in
      self.openFilterViewController(.time)
    }))

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  private func openFilterViewController(_ type: ClusterType) {
    let vc = ClustersViewController(clusterType: type, photos: self.photos ?? [])
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: CollectionView
extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.photos?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
    let photo = self.photos![indexPath.row]
    var asset = self.assetCache[photo.assetId]
    if asset == nil {
      asset = PHAsset.fetchAssets(withLocalIdentifiers: [photo.assetId], options: nil).firstObject!
      self.assetCache[photo.assetId] = asset
    }
    cell.asset = asset
    cell.photo = photo
    return cell
  }
}


// MARK: Photos
extension ViewController {
  fileprivate func loadNewPhotos(_ completion:@escaping (Void)->(Void)) {
    self.checkAuthorisation { (success: Bool) -> (Void) in
      if (success) {
        var lastDate = UserDefaults.standard.object(forKey: "lastDate") as? NSDate
        if (lastDate == nil) {
          lastDate = NSDate(timeIntervalSince1970: 0)
        }
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotosOptions.fetchLimit = 1000
        allPhotosOptions.predicate = NSPredicate(format: "creationDate > %@ ", argumentArray: [lastDate!])
        let allPhotos = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        var ids = [String]()
        allPhotos.enumerateObjects({ (asset, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
          ids.append(asset.localIdentifier)
        })
        UserDefaults.standard.set(NSDate(), forKey: "lastDate")

        let ih = ImportHelper()
        ih.importAssets(ids) {
          completion()
        }
      } else {
        completion()
      }
    }
  }

  private func checkAuthorisation(completion: @escaping (_ success: Bool)->(Void)) {
    if PHPhotoLibrary.authorizationStatus() == .authorized {
      completion(true)
      return
    }
    PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
      DispatchQueue.main.async {
        completion(status == .authorized)
      }
    }
  }
}

