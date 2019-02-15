//
//  PlayerCollectionViewItem.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/29.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

enum PlayerCollectionViewItemState: Int {
    case offline
    case online
    case eliminate
}

class PlayerCollectionViewItem: NSCollectionViewItem {

    @IBOutlet var nameTextField: NSTextField!

    var state: PlayerCollectionViewItemState = .offline

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewLayer = CALayer()
        viewLayer.cornerRadius = self.view.bounds.width/2
        self.view.wantsLayer = true
        self.view.layer = viewLayer

        self.updateBackgroundColor()
    }

    func updateBackgroundColor() {
        switch state {
        case .eliminate://yellow
            self.view.layer?.backgroundColor = NSColor(red: 1,
                                                       green: 147.0/255.0,
                                                       blue: 0,
                                                       alpha: 1).cgColor
        case .offline://red
            self.view.layer?.backgroundColor = NSColor(red:1,
                                                       green: 38.0/255.0,
                                                       blue: 0,
                                                       alpha: 1).cgColor
        case .online://green
            self.view.layer?.backgroundColor = NSColor(red: 0,
                                                       green: 143.0/255.0,
                                                       blue: 0,
                                                       alpha: 1).cgColor
        }
    }
}
