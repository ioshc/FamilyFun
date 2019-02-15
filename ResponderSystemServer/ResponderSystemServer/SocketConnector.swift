//
//  SocketConnector.swift
//  ResponderSystemClient
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import Cocoa

enum SocketNotificationUserInfoKey: String {
    case socketObjectKey
    case dataStringKey
    case userNameKey
}

enum SocketConnectorNotification: String {
    case didReceiveDataStringNotification
    case didReceiveClientOnlineNotification
    case didReceiveClientOfflineNotification
}

class SocketConnector: NSObject {

    static private var _sharedConnector: SocketConnector?
    private let _timeoutSeconds: Double = 60 * 20   //20分钟
    private var _serverSocket: GCDAsyncSocket?
    private var _clientSockets: Array = [GCDAsyncSocket]()

    static var shared: SocketConnector = {
        if _sharedConnector == nil {
            _sharedConnector = SocketConnector()
        }
        return _sharedConnector!
    }()

    override init() {
        super.init()
        _serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
}


// MARK: - Server
extension SocketConnector {

    func start() {
        stop()

        _serverSocket = GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.main);
        do {
            try _serverSocket?.accept(onPort: 2018)
        } catch {
            Loger.addLog("Failed Start Server")
        }
    }

    func stop() {
        _serverSocket?.disconnect()
    }

    func restart() {
        start()
    }
}

//MARK: - send/receive data
extension SocketConnector {

    func sendToSocket(_ socket: GCDAsyncSocket, _ text: String) -> Bool {

        guard let data = text.data(using: .utf8) else {
            return false
        }

        Loger.addLog("writting data to client with tag: 10 with text: " + text)
        socket.write(data, withTimeout: -1, tag: 10)

        return true
    }

    fileprivate func received(_ sock: GCDAsyncSocket, _ str: String) {

        let tmpArray = str.components(separatedBy: "@")
        let name = tmpArray.first!//姓名
        let dataStr = tmpArray.last!//数据

        var notificationName: String?
        if dataStr.contains("Login") {
            //用户登录
            notificationName = SocketConnectorNotification.didReceiveClientOnlineNotification.rawValue
        } else {
            //客户端发送消息
            notificationName = SocketConnectorNotification.didReceiveDataStringNotification.rawValue
        }

        NotificationCenter.default.post(name: NSNotification.Name(notificationName!),
                                        object: self,
                                        userInfo: [SocketNotificationUserInfoKey.socketObjectKey.rawValue : sock,
                                                   SocketNotificationUserInfoKey.dataStringKey.rawValue: dataStr,
                                                   SocketNotificationUserInfoKey.userNameKey.rawValue: name])
    }
}

// MARK: - GCDAsyncSocketDelegate
extension SocketConnector: GCDAsyncSocketDelegate {

    //新的客户端接入，保存客户端socket避免其被释放而无法正常通信
    func socket(_ sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        Loger.addLog("new client connected: \(newSocket!)" + newSocket.connectedHost())

        //保存客户端socket
        _clientSockets.append(newSocket)

        //让新接入的客户端socket进入读取数据状态
        newSocket?.readData(withTimeout: _timeoutSeconds, tag: 0)
    }

    //接收到客户端发送的数据时
    func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        let readString = String(data: data, encoding: .utf8)!
        Loger.addLog("received client data with tag: \(tag) with text: " + readString)

        //接收到客户端数据，并给客户端回执
        sock.write(("收到: " + readString).data(using: .utf8), withTimeout: -1, tag: 0)
        received(sock, readString)
    }

    //向客户端发送数据
    func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        Loger.addLog("written data to client with tag:\(tag)")

        //发送数据后继续让客户端socket进入读取数据状态
        sock.readData(withTimeout: _timeoutSeconds, tag: tag)
    }

    //断开链接时移除保存的客户端socket
    func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: Error!) {
        Loger.addLog("client disconnected: \(sock!) with error: \(err)")

        //移除该客户端
        if let idx = _clientSockets.index(of: sock) {
            _clientSockets.remove(at: idx)

            //发送客户端下线通知
            let notificationName = SocketConnectorNotification.didReceiveClientOfflineNotification.rawValue
            NotificationCenter.default.post(name: NSNotification.Name(notificationName),
                                            object: self,
                                            userInfo: [SocketNotificationUserInfoKey.socketObjectKey.rawValue : sock])
        }
    }
}
