//
//  ClustersViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 20/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CHTCollectionViewWaterfallLayout

class ClustersViewController: UIViewController {

  let clusterType: ClusterType
  let photos: [Photo]
  fileprivate var clusters = [Cluster]()
  fileprivate var collectionView: UICollectionView!
  fileprivate var dummyCell = ClusterCell(dummy: true)

  init(clusterType: ClusterType, photos: [Photo]) {
    self.clusterType = clusterType
    self.photos = photos
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Clusters"
    self.view.backgroundColor = UIColor(white: 0.91, alpha: 1.0)

    let layout = CHTCollectionViewWaterfallLayout()
    layout.minimumInteritemSpacing = 15
    layout.minimumColumnSpacing = 15
    layout.sectionInset = UIEdgeInsets(top: 18, left: 26, bottom: 18, right: 26)
    layout.columnCount = 2

    self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(ClusterCell.self, forCellWithReuseIdentifier: "ClusterCell")
    self.collectionView.backgroundColor = self.view.backgroundColor
    self.collectionView.alwaysBounceVertical = true
    self.view.addSubview(self.collectionView)

    self.delay(0.001) {
      let cg = ClusterGenerator()
      let start = Date()
      cg.generateClusters(photos: self.photos, clusterType: self.clusterType) { (clusters: [Cluster]) -> (Void) in
        print("Clustering:", start.timeIntervalSinceNow * -1)
        self.clusters = clusters
        self.collectionView.reloadData()
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !self.clusters.isEmpty {
      return
    }

  }
}

extension ClustersViewController: UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.clusters.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClusterCell", for: indexPath) as! ClusterCell
    cell.cluster = self.clusters[indexPath.row]
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = self.itemWidth()
    self.dummyCell.frame.size.width = width
    self.dummyCell.cluster = self.clusters[indexPath.row]
    return self.dummyCell.sizeThatFits(CGSize(width: width, height: 0))
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    let cluster = self.clusters[indexPath.row]
    let vc = ViewController(photos: cluster.photos)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func itemWidth() -> CGFloat {
    let layout = (collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout)
    return (collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - (layout.minimumInteritemSpacing * CGFloat(layout.columnCount - 1))) / CGFloat(layout.columnCount)
  }
}
