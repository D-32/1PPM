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
  fileprivate var cellModels = [ClusterCellModel]()
  fileprivate var collectionView: UICollectionView!
  fileprivate var dummyCell = ClusterCell(dummy: true)

  fileprivate var selectItem: UIBarButtonItem!
  fileprivate var cancelItem: UIBarButtonItem!
  fileprivate var openItem: UIBarButtonItem!

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

    selectItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectItemTapped))
    self.navigationItem.rightBarButtonItem = selectItem

    cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelItemTapped))
    openItem = UIBarButtonItem(title: "Open", style: .done, target: self, action: #selector(openItemTapped))

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
      let photosToCluster = self.photos.filter { $0.metaData != nil }
      if !photosToCluster.isEmpty {
        cg.generateClusters(photos: photosToCluster, clusterType: self.clusterType) { (clusters: [Cluster]) -> (Void) in
          print("Clustering:", start.timeIntervalSinceNow * -1)
          self.cellModels = clusters.map{ ClusterCellModel(cluster: $0) }
          self.collectionView.reloadData()
        }
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !self.cellModels.isEmpty {
      return
    }

  }

  func selectItemTapped() {
    for model in cellModels {
      model.selected = false
    }
    self.updateOpenItem()
    self.navigationItem.leftBarButtonItem = cancelItem
    self.navigationItem.rightBarButtonItem = openItem
  }

  func cancelItemTapped() {
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = selectItem
    for model in cellModels {
      model.selected = true
    }
  }

  func openItemTapped() {
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = selectItem
    let vc = ViewController(photos: self.selectedClusters().flatMap({$0.photos}))
    self.navigationController?.pushViewController(vc, animated: true)
    for model in cellModels {
      model.selected = true
    }
    self.updateOpenItem()
  }

  fileprivate func updateOpenItem() {
    self.openItem.isEnabled = self.selectedClusters().count > 0
  }

  private func selectedClusters() -> [Cluster] {
    return cellModels.filter({$0.selected}).map({$0.cluster})
  }
}

extension ClustersViewController: UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.cellModels.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClusterCell", for: indexPath) as! ClusterCell
    cell.model = self.cellModels[indexPath.row]
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = self.itemWidth()
    self.dummyCell.frame.size.width = width
    self.dummyCell.model = self.cellModels[indexPath.row]
    return self.dummyCell.sizeThatFits(CGSize(width: width, height: 0))
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    let model = self.cellModels[indexPath.row]
    if inSelectionMode() {
      model.selected = !model.selected
      self.updateOpenItem()
    } else {
      let vc = ViewController(photos: model.cluster.photos)
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func itemWidth() -> CGFloat {
    let layout = (collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout)
    return (collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - (layout.minimumInteritemSpacing * CGFloat(layout.columnCount - 1))) / CGFloat(layout.columnCount)
  }

  private func inSelectionMode() -> Bool {
    return self.navigationItem.rightBarButtonItem == self.openItem
  }
}
