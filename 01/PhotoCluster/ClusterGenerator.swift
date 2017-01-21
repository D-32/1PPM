//
//  ClusterGenerator.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 21/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import RealmSwift

class ClusterGenerator {

  func generateClusters(filterType: FilterType, completion: (_ clusters: [Cluster])->(Void)) {
    if filterType == .time {
      var vectors = [Vector]()

      let realm = try! Realm()
      let photos = realm.objects(Photo.self).sorted(byProperty: "creationDate", ascending: false)
      for photo in photos {
        var v = Vector([Double(photo.hour)])
        v.obj = photo
        vectors.append(v)
      }

      let numberOfClusters = 6
      let convergeDistance = 20.0
      let labels = Array(1...numberOfClusters).map({"Cluster #\($0)"})
      let kmm = KMeans<String>(labels: labels)
      kmm.trainCenters(vectors, convergeDistance: convergeDistance)
      var newClusters = [Cluster]()
      for vectors in kmm.__classifications {
        let photos = vectors.map({$0.obj as! Photo}).sorted(by: { (p1: Photo, p2: Photo) -> Bool in
          return p1.totalMinutesInDay() < p2.totalMinutesInDay()
        })
        if !photos.isEmpty {
          let b = photos.first!
          let e = photos.last!
          let cluster = Cluster(title: "\(b.hour):00 - \(e.hour):00", photos: photos)
          newClusters.append(cluster)
        }
      }
      newClusters = newClusters.sorted(by: { (c1: Cluster, c2: Cluster) -> Bool in
        return c1.photos.first!.hour < c2.photos.first!.hour
      })

      completion(newClusters)
    } else {
      completion([])
    }
  }
}
