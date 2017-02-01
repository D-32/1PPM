//
//  ClusterGenerator.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 21/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class ClusterGenerator {

  private var clusterType: ClusterType!

  func generateClusters(photos: [Photo], clusterType: ClusterType, completion: @escaping (_ clusters: [Cluster])->(Void)) {
    self.clusterType = clusterType
    if clusterType == .time {
      completion(self.clusterByTime(photos))
    } else if clusterType == .altitude {
      completion(self.clusterByAltitude(photos))
    } else if clusterType == .dayOfWeek {
      completion(self.clusterByDayOfWeek(photos))
    } else if clusterType == .location {
      self.clusterByLocation(photos) {
        completion($0)
      }
    } else if clusterType == .color {
      completion(self.clusterByColor(photos))
    } else if clusterType == .brightness {
      completion(self.clusterByBrightness(photos))
    } else {
      assert(false, "Cluster type not handled: \(clusterType)")
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

  private func clusterByLocation(_ photos: [Photo], completion:@escaping (_ clusters: [Cluster])->(Void)) {
    let clusters = self.kmm(photos: photos,
                            inputs: photos.map{ [$0.latitude, $0.longitude] },
                            sort:
      { (photo1: Photo, photo2: Photo) -> (Bool) in
        return photo1.id < photo2.id
      },
                            titleGenerator:
      { (photos: [Photo]) -> (String) in
        return ""
    })

    for cluster in clusters {
      let cl = CLLocation(latitude: cluster.center[0], longitude: cluster.center[1])
      var totalDistance: Double = 0
      for photo in cluster.photos {
        let cp = CLLocation(latitude: photo.latitude, longitude: photo.longitude)
        totalDistance += cl.distance(from: cp)
      }
      if totalDistance > 0 && !cluster.photos.isEmpty {
        cluster.avgSizeToCenter = totalDistance / Double(cluster.photos.count)
      }
      cluster.title = "Unknown"
    }

    var processed = 0
    let toProcess = clusters.filter { $0.center[0] != 0 && $0.center[1] != 0 }
    for cluster in toProcess {
      let location = CLLocation(latitude: cluster.center[0], longitude: cluster.center[1])
      let geocoder = CLGeocoder()
      geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let e = error {
          print(e.localizedDescription, location)
        }
        if let pm = placemarks?.first {
          if cluster.avgSizeToCenter < 5000 {
            cluster.title = pm.locality
          } else if cluster.avgSizeToCenter < 50000 {
            cluster.title = pm.administrativeArea
          } else {
            cluster.title = pm.country
          }
        }
        processed += 1
        if processed == toProcess.count {
          completion(clusters.sorted(by: { return $0.title! < $1.title! }))
        }
      }
    }
  }

  private func clusterByColor(_ photos: [Photo]) -> [Cluster] {
    let clusters = self.kmm(photos: photos,
                            inputs: photos.map{ [$0.metaData!.red, $0.metaData!.green, $0.metaData!.blue] },
                            sort:
      { (photo1: Photo, photo2: Photo) -> (Bool) in
        return photo1.id < photo2.id
    },
                            titleGenerator:
      { (photos: [Photo]) -> (String) in
        return ""
    })
    for cluster in clusters {
      let color = UIColor(red: CGFloat(cluster.center[0]), green: CGFloat(cluster.center[1]), blue: CGFloat(cluster.center[2]), alpha: 1.0)
      cluster.color = color
    }
    return clusters
  }

  private func clusterByBrightness(_ photos: [Photo]) -> [Cluster] {
    let clusters = self.kmm(photos: photos,
                            inputs: photos.map{ [$0.metaData!.brightness] },
                            sort:
      { (photo1: Photo, photo2: Photo) -> (Bool) in
        return photo1.id < photo2.id
    },
                            titleGenerator:
      { (photos: [Photo]) -> (String) in
        return ""
    })
    for cluster in clusters {
      let color = UIColor(hue: 0, saturation: 0, brightness: CGFloat(cluster.center[0]), alpha: 1.0)
      cluster.color = color
    }
    return clusters
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
    for (index, vectors) in kmm.__classifications.enumerated() {
      let photos = vectors.map({$0.obj as! Photo})
      if !photos.isEmpty {
        let cluster = Cluster(photos: photos.sorted(by: {$0.totalMinutesInDay() < $1.totalMinutesInDay()}))
        cluster.customSortedPhotos = photos.sorted(by: {sort($0,$1)})
        cluster.title = titleGenerator(cluster.customSortedPhotos)
        cluster.type = self.clusterType
        cluster.center = kmm.centroids[index].data
        newClusters.append(cluster)
      }
    }

    newClusters = newClusters.sorted(by: { (c1: Cluster, c2: Cluster) -> Bool in
      return sort(c1.customSortedPhotos.first!, c2.customSortedPhotos.first!)
    })

    return newClusters
  }
}
