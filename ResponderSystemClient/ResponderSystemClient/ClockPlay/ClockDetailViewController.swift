//
//  ClockDetailViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/25.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class ClockDetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!

    var clockPlayItem: CLockPlayItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = clockPlayItem?.time
        imageView.image = clockPlayItem?.image
    }
}
