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
  var customSortedPhotos = [Photo]()
  init(photos: [Photo]) {
    self.photos = photos
  }
}
