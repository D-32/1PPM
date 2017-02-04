//
//  GalleryViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 02/02/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit
import Photos

class GalleryViewController: UIViewController {

  var photos: [Photo]!
  var currentIndex: Int = 0

  fileprivate var nextPageIndex: Int!
  private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.black
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    self.nextPageIndex = self.currentIndex

    let startVC = self.detailViewController(photo: self.photos[self.currentIndex])

    self.addChildViewController(self.pageController)
    self.view.addSubview(self.pageController.view)
    self.pageController.dataSource = self
    self.pageController.delegate = self
    self.pageController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 0)
    self.pageController.setViewControllers([startVC], direction: .forward, animated: false, completion: nil)

    let buttonBg = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
    buttonBg.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    self.view.addSubview(buttonBg)

    let backButton = self.buttonWithImage("back", width: 66)
    backButton.frame.origin.y = 20
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    self.view.addSubview(backButton)

    /*
    let shareButton = self.buttonWithImage("share", width: 50)
    shareButton.frame.origin.y = 8
    shareButton.frame.origin.x = self.view.frame.width - 50
    shareButton.addTarget(self, action: #selector(shareButtonTapped(button:)), for: .touchUpInside)
    self.view.addSubview(shareButton)
     */
  }

  private func buttonWithImage(_ imageName: String, width: CGFloat) -> UIButton {
    let button = UIButton(type: .custom)
    button.frame.size = CGSize(width: width, height: 44)

    let buttonImage = UIImageView(image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))
    buttonImage.frame.origin = CGPoint(x: width / 2 - 11, y: 11)
    buttonImage.tintColor = UIColor.white
    button.addSubview(buttonImage)

    return button
  }

  func backButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func detailViewController(photo: Photo) -> GalleryDetailViewController {
    let vc = GalleryDetailViewController(photo: photo)
    return vc
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
/*
  override var prefersStatusBarHidden: Bool {
    return true
  }
 */
}

extension GalleryViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let photo = (viewController as! GalleryDetailViewController).photo
    var index = self.photos.index(of: photo)!
    index += 1
    if (index >= self.photos.count) {
      return nil
    }
    return self.detailViewController(photo: self.photos[index])
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let photo = (viewController as! GalleryDetailViewController).photo
    let index = self.photos.index(of: photo)!
    if (index == 0) {
      return nil
    }
    return self.detailViewController(photo: self.photos[index - 1])
  }

  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    let photo = (pendingViewControllers.first! as! GalleryDetailViewController).photo
    self.nextPageIndex = self.photos.index(of: photo)!
  }

  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if !completed {
      let photo = (previousViewControllers.first! as! GalleryDetailViewController).photo
      self.nextPageIndex = self.photos.index(of: photo)!
    }
    self.currentIndex = self.nextPageIndex
  }
}

