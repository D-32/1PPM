//
//  Utils.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 13/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
  func delay(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      completion()
    }
  }
}

extension UIImage {
  func areaAverage() -> UIColor {

    var bitmap = [UInt8](repeating: 0, count: 4)

    let context = CIContext(options: nil)
    let inputImage = CIImage(image: self)!
    let extent = inputImage.extent
    let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
    let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
    let outputImage = filter.outputImage!
    let outputExtent = outputImage.extent
    assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)

    // Render to bitmap.
    context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

    // Compute result.
    let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    return result
  }
}

extension UIImageView {
  func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
    contentMode = mode
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard
        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
        let data = data, error == nil,
        let image = UIImage(data: data)
        else { return }
      DispatchQueue.main.async() { () -> Void in
        self.image = image
      }
      }.resume()
  }
  func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
    guard let url = URL(string: link) else { return }
    downloadedFrom(url: url, contentMode: mode)
  }
}
