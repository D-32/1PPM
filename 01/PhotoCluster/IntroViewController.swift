//
//  IntroViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 04/02/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class IntroViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white

    let titleLabel = UILabel()
    titleLabel.frame = CGRect(x: 40, y: 80, width: self.view.frame.width - 80, height: 30)
    titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
    titleLabel.textColor = UIColor(white: 0.1, alpha: 1.0)
    titleLabel.textAlignment = .left
    titleLabel.text = "Welcome!"
    self.view.addSubview(titleLabel)

    let descLabel = UILabel()
    descLabel.frame = CGRect(x: 40, y: 160, width: self.view.frame.width - 80, height: 0)
    descLabel.font = UIFont.systemFont(ofSize: 16)
    descLabel.textColor = UIColor(white: 0.1, alpha: 1.0)
    descLabel.textAlignment = .left
    descLabel.numberOfLines = 0
    descLabel.text = "For 2017 I decided to create and 🚢 one project every month.\nThis is my January project.\n\nWith this time frame and my limited free time, I couldn't make this app a perfect product (yet).\nI appologize for any 🐛 you might encounter.\n\nCheers,\nDylan"
    descLabel.sizeToFit()
    descLabel.frame.size.width = self.view.frame.width - 80
    self.view.addSubview(descLabel)

    let startButton = UIButton()
    startButton.frame = CGRect(x: 40, y: self.view.frame.height - 84, width: self.view.frame.width - 80, height: 44)
    startButton.layer.cornerRadius = 6
    startButton.backgroundColor = UIColor(red:0.169, green:0.580, blue:0.839, alpha:1)
    startButton.setTitleColor(UIColor.white, for: .normal)
    startButton.setTitle("Sounds Good!", for: .normal)
    startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    self.view.addSubview(startButton)
  }

  func startButtonTapped() {
    UserDefaults.standard.set(true, forKey: "fle_shown")
    let ad = UIApplication.shared.delegate as! AppDelegate
    ad.showMainApp()
  }
}
