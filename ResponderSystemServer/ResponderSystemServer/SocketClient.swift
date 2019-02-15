//
//  SocketClient.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/29.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class SocketClient: NSObject {

    var name: String?
    var isOnline: Bool = false
    var isEliminated: Bool = true
    var socket: GCDAsyncSocket?

    private var answers = [String]() //Chongding Player
}

// MARK: - Chongding Player
extension SocketClient {

    func appendAnwser(_ anwser: String) {
        answers.append(anwser)
    }

    func removeAllAnwsers() {
        answers.removeAll()
    }

    func anwserString() -> String {
        return answers.joined(separator: "  |  ")
    }

}
