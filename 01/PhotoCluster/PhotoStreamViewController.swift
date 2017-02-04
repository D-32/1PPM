//
//  PhotoStreamViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 01/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import UIKit
import Photos
import RealmSwift
import BubbleTransition

class PhotoStreamViewController: UIViewController {

  fileprivate var collectionView: UICollectionView!
  fileprivate var photos: [Photo]?
  fileprivate var assetCache = [String:PHAsset]()
  private var clusterItem: UIBarButtonItem!

  fileprivate let transition = BubbleTransition()
  fileprivate var transitionStartingPoint: CGPoint!

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
    self.collectionView.delegate = self
    self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    self.collectionView.backgroundColor = UIColor.white
    self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
    self.view.addSubview(self.collectionView)

    // Peek & Pop
    if traitCollection.forceTouchCapability == .available {
      self.registerForPreviewing(with: self, sourceView: self.collectionView)
    }

    self.clusterItem = UIBarButtonItem(title: "Cluster", style: .plain, target: self, action: #selector(clusterItemTapped))
    self.updateclusterItem()
    self.navigationItem.rightBarButtonItem = self.clusterItem


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
    self.updateclusterItem()
  }

  private func updateclusterItem() {
    self.clusterItem.isEnabled = self.photos?.count ?? 0 > 10
  }

  func clusterItemTapped() {
    let alert = UIAlertController(title: "Choose Cluster Type", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "🕑 Time", style: .default, handler: { _ in
      self.openClusterViewController(.time)
    }))
    alert.addAction(UIAlertAction(title: "📅 Day of Week", style: .default, handler: { _ in
      self.openClusterViewController(.dayOfWeek)
    }))
    alert.addAction(UIAlertAction(title: "🗺 Location", style: .default, handler: { _ in
      self.openClusterViewController(.location)
    }))
    alert.addAction(UIAlertAction(title: "🗻 Altitude", style: .default, handler: { _ in
      self.openClusterViewController(.altitude)
    }))
    alert.addAction(UIAlertAction(title: "🎨 Color", style: .default, handler: { _ in
      self.openClusterViewController(.color)
    }))
    alert.addAction(UIAlertAction(title: "💡 Brightness", style: .default, handler: { _ in
      self.openClusterViewController(.brightness)
    }))
    alert.addAction(UIAlertAction(title: "🤖 Type / Features", style: .default, handler: { _ in
      self.openClusterViewController(.feature)
    }))


    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  private func openClusterViewController(_ type: ClusterType) {
    let vc = ClustersViewController(clusterType: type, photos: self.photos ?? [])
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: CollectionView
extension PhotoStreamViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    let cell = collectionView.cellForItem(at: indexPath)!
    let convertedCenter = collectionView.convert(cell.center, to: self.view)
    self.transitionStartingPoint = convertedCenter
    let vc = GalleryViewController()
    vc.photos = self.photos!
    vc.currentIndex = indexPath.row
    vc.transitioningDelegate = self
    vc.modalPresentationStyle = .custom
    vc.modalPresentationCapturesStatusBarAppearance = true
    self.present(vc, animated: true, completion: nil)
  }
}


// MARK: Photos
extension PhotoStreamViewController {
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
          BackgroundProcessor.shared.start()
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

// MARK: Transition
extension PhotoStreamViewController: UIViewControllerTransitioningDelegate {
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .present
    transition.startingPoint = self.transitionStartingPoint
    transition.duration = 0.40
    transition.bubbleColor = UIColor.black
    return transition
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    // if current article cell is not anymore in sight, let's just use the original starting point
    var startingPoint = self.transitionStartingPoint
    let vc = dismissed as! GalleryViewController
    if let cell = self.collectionView.cellForItem(at: IndexPath(row: vc.currentIndex, section: 0)) {
      let convertedCenter = self.collectionView.convert(cell.center, to: self.view)
      startingPoint = convertedCenter
    }
    transition.transitionMode = .dismiss
    transition.startingPoint = startingPoint!
    transition.duration = 0.36
    transition.bubbleColor = UIColor.black
    return transition
  }
}

// MARK: Peek & Pop
extension PhotoStreamViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let indexPath = self.collectionView.indexPathForItem(at: location) else { return nil }
    guard let cell = self.collectionView.cellForItem(at: indexPath) else { return nil }
    let detailViewController = GalleryDetailViewController(photo: self.photos![indexPath.row])
    previewingContext.sourceRect = cell.frame
    return detailViewController
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    let dvc = viewControllerToCommit as! GalleryDetailViewController
    let index = self.photos!.index(of: dvc.photo)!
    if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
      let convertedCenter = self.collectionView.convert(cell.center, to: self.view)
      self.transitionStartingPoint = convertedCenter
    }

    let vc = GalleryViewController()
    vc.photos = self.photos!
    vc.currentIndex = index
    self.present(vc, animated: true, completion: nil)
  }
}

