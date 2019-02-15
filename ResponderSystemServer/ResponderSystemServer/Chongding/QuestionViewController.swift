//
//  QuestionViewController.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/18.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class QuestionViewController: NSViewController {

    @IBOutlet var timeTextfiled: NSTextField?
    @IBOutlet var titleTextfiled: NSTextField?
    @IBOutlet var anwser1Button: NSButton?
    @IBOutlet var anwser2Button: NSButton?
    @IBOutlet var anwser3Button: NSButton?

    var question: Question?

    override func viewDidLoad() {
        titleTextfiled?.stringValue = question?.title ?? ""
        anwser1Button?.title = (question?.solutions![0])!
        anwser2Button?.title = (question?.solutions![1])!
        anwser3Button?.title = (question?.solutions![2])!
    }

    override func viewDidAppear() {

        var timeRemaining = 15
        self.timeTextfiled?.stringValue = "15"
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in

            timeRemaining = timeRemaining - 1

            if timeRemaining >= 0 {
                self.timeTextfiled?.stringValue = "\(timeRemaining)"
            } else {
                timer.invalidate()
                self.dismiss(self)
            }
        }
    }
}
