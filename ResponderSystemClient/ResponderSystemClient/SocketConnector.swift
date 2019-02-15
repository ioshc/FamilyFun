//
//  SocketConnector.swift
//  ResponderSystemClient
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import UIKit

enum SocketConnectorNotification: String {
    case didReceiveQuestionNotification
    case didReceiveAnwserNotification
}

class SocketConnector: NSObject {

    static private var _sharedConnector: SocketConnector?

    var team: String! = ""
    var host: String! = "192.168.2.1"
    var port: String! = "2018"
    private(set) var isConnected: Bool = false
    private var _socket: GCDAsyncSocket?

    static var shared: SocketConnector? = {
        if _sharedConnector == nil {
            _sharedConnector = SocketConnector()
        }
        return _sharedConnector
    }()

    override init() {
        super.init()
        _socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }

    func connect(_ host: String!, _ port:String!) {
        disconnect()

        guard let connectPort = UInt16(port) else {
            return
        }

        do {
            try _socket?.connect(toHost: host, onPort: connectPort)
        } catch {
            Loger.addLog("Failed Connect To Host:\(host) on port: \(connectPort)")
        }
    }

    func disconnect() {
        _socket?.disconnect()
    }

    func reconnect() {
        connect(host, port)
        send("Login")
    }
}

//MARK: - send/receive data
extension SocketConnector {

    func send(_ text: String) {
        guard let data = ("第\(team!)组" + "@" + text).data(using: .utf8) else {
            return
        }

        Loger.addLog("writting text to server with tag: 10 with text: " + text)
        _socket?.write(data, withTimeout: -1, tag: 10)
    }

    fileprivate func received(_ data: Data) {

        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        if string.contains("@") {

            let tmpArray = string.components(separatedBy: "@")
            if tmpArray.first! == "Question" {

                //我国唯一的两个皇帝合葬在一起的是唐高宗跟?唐高祖,唐太宗,武则天:1
                let tmpArray2 = tmpArray.last!.components(separatedBy: ":")

                let question = Question(tmpArray2.first!)
                question.isAnwserable = (tmpArray2.last! == "1")
                let notificationName = SocketConnectorNotification.didReceiveQuestionNotification.rawValue
                NotificationCenter.default.post(name: NSNotification.Name(notificationName),
                                                object: self,
                                                userInfo: ["Question" : question])
            } else if tmpArray.first! == "Anwser" {

                //我国唯一的两个皇帝合葬在一起的是唐高宗跟?唐高祖,唐太宗,武则天:武则天,客户端答案|2,1,3:1
                let questionAndAnwser: Array = tmpArray.last!.components(separatedBy: ":")

                //武则天,客户端答案|2,1,3
                let anwserInfos: Array = questionAndAnwser[1].components(separatedBy: "|")

                //武则天,客户端答案
                let anwsers: Array = anwserInfos.first!.components(separatedBy: ",")

                //2,1,3
                let players: Array = anwserInfos.last!.components(separatedBy: ",")

                let question = Question(questionAndAnwser.first!)
                question.answer = anwsers.first!
                question.isAnwserable = (questionAndAnwser.last! == "1")

                let anwser = Anwser()
                anwser.question = question
                anwser.userAnwser = anwsers.last!
                anwser.userAnwserIdx = question.solutions?.index(of: anwsers.last!) ?? -1
                anwser.isRight = (question.answer == anwsers.last!)
                anwser.anwsersCounts = players.map({ (str) -> Int in
                    return Int(str)!
                })

                let notificationName = SocketConnectorNotification.didReceiveAnwserNotification.rawValue
                NotificationCenter.default.post(name: NSNotification.Name(notificationName),
                                                object: self,
                                                userInfo: ["Anwser" : anwser])
            }

        }
    }
}

extension SocketConnector: GCDAsyncSocketDelegate {

    //创建链接
    func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        Loger.addLog("didConnectToHost: \(host!) on port: \(port)")
        isConnected = true
    }

    //断开连接
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: Error!) {
        Loger.addLog("socketDidDisconnect: \(sock!) with error: \(err)")
        isConnected = false
    }

    //收到服务器发送的数据
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        Loger.addLog("received data from server with tag:\(tag) with text: " + String(data: data, encoding: .utf8)!)
        received(data)
        sock.readData(withTimeout: -1, tag: tag)
    }

    //向服务器发送数据成功
    func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        Loger.addLog("didWriteDataWithTag: \(tag)")
        sock.readData(withTimeout: -1, tag: tag)
    }
}
