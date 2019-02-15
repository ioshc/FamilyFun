//
//  CongratulationViewController.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/18.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class CongratulationViewController: NSViewController {

    @IBOutlet var titleTextField: NSTextField?
    @IBOutlet var messageTextField: NSTextField?

    var name: String = "很遗憾，居然没有人答对最后一题！"
    var count: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if count > 0 {

            titleTextField?.textColor = NSColor(red: 0, green: 143.0/255.0, blue: 0, alpha: 1)
            messageTextField?.textColor = NSColor(red: 0, green: 143.0/255.0, blue: 0, alpha: 1)

            titleTextField?.stringValue = "Congratulation!"
            messageTextField?.stringValue = String.init(format: "%@总共答对%d道题", name, count)
        }
    }
    
}
