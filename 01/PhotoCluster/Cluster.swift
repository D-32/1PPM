//
//  Cluster.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 20/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Cluster {
  var title: String?
  var color: UIColor?
  var zoomLevel: Int?
  var photos: [Photo]
  var type: ClusterType!
  var center: [Double]!
  var sortValue: Double = 0 // temporarely used to custom sort
  var customSortedPhotos = [Photo]()
  init(photos: [Photo]) {
    self.photos = photos
  }
}
