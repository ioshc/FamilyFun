//
//  MainViewController.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/29.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func onChongdingButtonClicked(_ sender: NSButton) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("ChongdingViewController"),
                          sender: self)
    }

    @IBAction func onSkipNumberButtonClicked(_ sender: NSButton) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("SkipNumberViewController"),
                          sender: self)
    }

}
