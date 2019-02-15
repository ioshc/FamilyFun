//
//  MyNavigationController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/26.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let vc = self.visibleViewController else {
            return .all
        }
        return vc.supportedInterfaceOrientations
    }
}
