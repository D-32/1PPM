//
//  Cluster.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 20/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation

class Cluster {
  var title: String
  var photos: [Photo]
  init(title: String, photos: [Photo]) {
    self.title = title
    self.photos = photos
  }
}
