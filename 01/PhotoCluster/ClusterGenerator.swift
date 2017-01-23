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

  func generateClusters(photos: [Photo], clusterType: ClusterType, completion: (_ clusters: [Cluster])->(Void)) {
    if clusterType == .time {
      completion(self.clusterByTime(photos))
    } else if clusterType == .altitude {
      completion(self.clusterByAltitude(photos))
    } else if clusterType == .dayOfWeek {
      completion(self.clusterByDayOfWeek(photos))
    } else {
      completion([])
    }
  }

  private func clusterByTime(_ photos: [Photo]) -> [Cluster] {
    let clusters = self.kmm(photos: photos,
                            inputs: photos.map{ [Double($0.hour)] },
                            sort:
      { (photo1: Photo, photo2: Photo) -> (Bool) in
        return photo1.totalMinutesInDay() < photo2.totalMinutesInDay()
    },
                            titleGenerator:
      { (photos: [Photo]) -> (String) in
        let s = photos.first!.hour
        let e = photos.last!.hour + 1
        let start = s < 10 ? "0\(s)" : "\(s)"
        let end = e < 10 ? "0\(e)" : "\(e)"
        return "\(start):00 - \(end):00"
    })
    return clusters
  }

  private func clusterByAltitude(_ photos: [Photo]) -> [Cluster] {
    let clusters = self.kmm(photos: photos,
                            inputs: photos.map{ [$0.altitude] },
                            sort:
      { (photo1: Photo, photo2: Photo) -> (Bool) in
        return photo1.altitude < photo2.altitude
    },
                            titleGenerator:
      { (photos: [Photo]) -> (String) in
        let s = photos.first!.altitude
        let e = photos.last!.altitude
        if s == e {
          return "\(Int(s)) Meters"
        } else {
          return "\(Int(s)) - \(Int(e)) Meters"
        }
    })
    return clusters
  }

  private func clusterByDayOfWeek(_ photos: [Photo]) -> [Cluster] {
    var titles = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var clusters = [Cluster]()
    for i in 0...6 {
      let c = Cluster(photos: [])
      c.title = titles[i]
      clusters.append(c)
    }
    for photo in photos {
      clusters[photo.dayOfWeek - 1].photos.append(photo)
    }
    return clusters.filter({!$0.photos.isEmpty})
  }

  private func kmm(photos: [Photo], inputs: [[Double]], sort: ((_ photo1: Photo, _ photo2: Photo)->(Bool)), titleGenerator:(_ photos: [Photo])->(String)) -> [Cluster] {
    assert(photos.count == inputs.count)

    var vectors = [Vector]()

    for (i, photo) in photos.enumerated() {
      var v = Vector(inputs[i])
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
      let photos = vectors.map({$0.obj as! Photo})
      if !photos.isEmpty {
        let cluster = Cluster(photos: photos.sorted(by: {$0.totalMinutesInDay() < $1.totalMinutesInDay()}))
        cluster.customSortedPhotos = photos.sorted(by: {sort($0,$1)})
        cluster.title = titleGenerator(cluster.customSortedPhotos)
        newClusters.append(cluster)
      }
    }

    newClusters = newClusters.sorted(by: { (c1: Cluster, c2: Cluster) -> Bool in
      return sort(c1.customSortedPhotos.first!, c2.customSortedPhotos.first!)
    })

    return newClusters
  }
}
