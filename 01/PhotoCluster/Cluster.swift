//
//  Cluster.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 20/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation

class Cluster {
  var title: String!
  var photos: [Photo]
  var type: ClusterType!
  var center: [Double]!
  var avgSizeToCenter: Double = 0
  var customSortedPhotos = [Photo]()
  init(photos: [Photo]) {
    self.photos = photos
  }
}
