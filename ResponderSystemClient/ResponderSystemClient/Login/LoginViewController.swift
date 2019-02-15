//
//  LoginViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/18.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onLoginButtonClicked(_ sender: UIButton) {

        if let team = textField.text, team.count == 0 {
            self.shakeView(textField)
            return
        }

        SocketConnector.shared?.team = textField.text
        SocketConnector.shared?.reconnect()
        self.dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first!.view != textField {
            self.view.endEditing(true)
        }
    }
}
