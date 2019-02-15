//
//  PoseDetailViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/26.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class PoseDetailViewController: UIViewController {

    @IBOutlet var originalImageView: UIImageView!
    @IBOutlet var actImageView: UIImageView!

    var poseItem: PoseItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "成果展示"

        originalImageView.layer.borderColor = UIColor.lightGray.cgColor
        originalImageView.layer.borderWidth = 1.0
        actImageView.layer.borderColor = UIColor.lightGray.cgColor
        actImageView.layer.borderWidth = 1.0

        originalImageView.image = poseItem?.originalImage
        actImageView.image = poseItem?.actImage
    }
}
