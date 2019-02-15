//
//  SkipNumberViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/22.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class SkipNumberViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!

    private var _timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "跳过7"

        timeLabel.layer.cornerRadius = 50
        timeLabel.clipsToBounds = true
        
        DispatchQueue.main.async {
            if SocketConnector.shared?.host == "0" {
                self.present(LoginViewController.controllerFromXib()!, animated: true, completion: nil)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _timer?.invalidate()
    }
}

extension SkipNumberViewController {

    @IBAction func onContinueButtonClicked(_ sender: UIButton) {

    }

    @IBAction func onSkipButtonClicked(_ sender: UIButton) {

    }
}
