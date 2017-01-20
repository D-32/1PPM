//
//  FilterViewController.swift
//  PhotoCluster
//
//  Created by Dylan Marriott on 20/01/17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController {

  var filterType: FilterType

  init(filterType: FilterType) {
    self.filterType = filterType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Clusters"
    self.view.backgroundColor = UIColor.white
  }
}
