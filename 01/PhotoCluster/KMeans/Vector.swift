
// https://github.com/raywenderlich/swift-algorithm-club/tree/master/K-Means

import Foundation

struct Vector: CustomStringConvertible, Equatable {
  fileprivate(set) var length = 0
  fileprivate(set) var data: [Double]
  var obj: Any?

  init(_ data: [Double]) {
    self.data = data
    self.length = data.count
  }

  var description: String {
    return "Vector (\(data)"
  }

  func distanceTo(_ other: Vector) -> Double {
    var result = 0.0
    for idx in 0..<length {
      result += pow(data[idx] - other.data[idx], 2.0)
    }
    return sqrt(result)
    /*
    let dotProduct = self.dotProduct(a: self.data, b: other.data)
    let magA = self.magnitude(v: self.data)
    let magB = self.magnitude(v: other.data)
    let result = dotProduct / (magA * magB)
    if result.isNaN {
      print("")
    }
    return result.isNaN ? 0.0 : result
 */
  }

  private func dotProduct(a: [Double], b: [Double]) -> Double {
    return zip(a, b).map(*).reduce(0, +)
  }

  private func magnitude(v: [Double]) -> Double {
    return sqrt(self.dotProduct(a: v, b: v))
  }
}

func == (left: Vector, right: Vector) -> Bool {
  for idx in 0..<left.length {
    if left.data[idx] != right.data[idx] {
      return false
    }
  }
  return true
}

func + (left: Vector, right: Vector) -> Vector {
  var results = [Double]()
  for idx in 0..<left.length {
    results.append(left.data[idx] + right.data[idx])
  }
  return Vector(results)
}

func += (left: inout Vector, right: Vector) {
  left = left + right
}

func - (left: Vector, right: Vector) -> Vector {
  var results = [Double]()
  for idx in 0..<left.length {
    results.append(left.data[idx] - right.data[idx])
  }
  return Vector(results)
}

func -= (left: inout Vector, right: Vector) {
  left = left - right
}

func / (left: Vector, right: Double) -> Vector {
  var results = [Double](repeating: 0, count: left.length)
  for (idx, value) in left.data.enumerated() {
    let z = value / right
    results[idx] = z.isNaN ? 0.0 : z
  }
  return Vector(results)
}

func /= (left: inout Vector, right: Double) {
  left = left / right
}
