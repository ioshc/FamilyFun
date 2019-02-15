//
//  ResponderViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import UIKit

class ResponderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "第\(SocketConnector.shared?.team ?? "X")组"

        DispatchQueue.main.async {
            if SocketConnector.shared?.team == "" {
                self.present(LoginViewController.controllerFromXib()!, animated: true, completion: nil)
            }
        }

        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    @IBAction func onABCDButtonClicked(_ sender: UIButton) {
        SocketConnector.shared?.send((sender.titleLabel?.text!)!)
    }

    @IBAction func onInfoButtonClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "InfoViewController", sender: self)
    }
}

