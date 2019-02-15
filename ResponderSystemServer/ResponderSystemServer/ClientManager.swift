//
//  ClientManager.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/17.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

protocol ClientManagerClientUpdatedDelegate {
    func clientUpdated()
}

class ClientManager: NSObject {

    static private var _sharedManager: ClientManager?
    private(set) var registerClients: Array = [SocketClient]()

    static private(set) var shared: ClientManager = {
        if _sharedManager == nil {
            _sharedManager = ClientManager()
        }
        return _sharedManager!
    }()

    override init() {
        super.init()
        registerNotifications()
    }

    var delegate: ClientManagerClientUpdatedDelegate?

    //通过socket找到客户端
    func findClient(by sock: GCDAsyncSocket) -> SocketClient? {

        var client: SocketClient?
        for item in registerClients {
            if item.socket == sock {
                client = item
                break
            }
        }
        return client
    }

    //通过名字找到客户端
    func findClient(by name: String) -> SocketClient? {

        var client: SocketClient?
        for item in registerClients {
            if item.name == name {
                client = item
                break
            }
        }
        return client
    }

    //获取所有在线客户端
    func getAllOnlineClients() -> Array<SocketClient> {

        return registerClients.filter { (client) -> Bool in
            return client.isOnline
        }
    }

    //获取所有未淘汰的客户端
    func getAllUneliminatedClients() -> Array<SocketClient> {

        return registerClients.filter { (client) -> Bool in
            return client.isOnline && !client.isEliminated
        }
    }

    //将所有在线客户端标记为未被淘汰
    func markAllOnlineClientsAsUneliminated() {
        for client in registerClients {
            client.removeAllAnwsers()
            if client.isOnline {
                client.isEliminated = false
            }
        }
    }

    //将所有在线客户端标记为已淘汰
    func markAllOnlineClientsAsEliminated() {
        for client in registerClients {
            client.isEliminated = true
            if client.isOnline {
                client.removeAllAnwsers()
            }
        }
    }

    //移除所有离线客户端
    func removeAllOfflineClients() {
        registerClients = registerClients.filter({ (client) -> Bool in
            return client.isOnline
        })
    }

}

extension ClientManager {

    //向所有客户端发送消息
    func sendToAllOnlineClient(_ text: String) -> Bool {

        var anySucceed = false
        for client in registerClients {

            let fixedText = text + ":\(client.isEliminated ? 0 : 1)"
            if client.isOnline {
                if sendToClient(client, fixedText) {
                    anySucceed = true
                }
            }
        }
        return anySucceed
    }

    //向所有未被淘汰的客户端发送消息
    func sendToAllUneliminatedClient(_ text: String) -> Bool {

        var anySucceed = false
        for client in registerClients {
            if !client.isEliminated {
                if sendToClient(client, text) {
                    anySucceed = true
                }
            }
        }
        return anySucceed
    }

    //向指定客户端发送消息
    func sendToClient(_ client: SocketClient, _ text: String) -> Bool {
        return SocketConnector.shared.sendToSocket(client.socket!, text)
    }
}

// MARK: - Notification
extension ClientManager {
    func registerNotifications() {

        let notificationCenter = NotificationCenter.default
        //新用户上线通知
        let onlineNotificationName = SocketConnectorNotification.didReceiveClientOnlineNotification.rawValue
        notificationCenter.addObserver(forName: NSNotification.Name(onlineNotificationName),
                                       object: SocketConnector.shared,
                                       queue: OperationQueue.main)
        { (notification) in

            guard let userInfo = notification.userInfo else {
                return
            }

            let socket = userInfo[SocketNotificationUserInfoKey.socketObjectKey.rawValue] as? GCDAsyncSocket
            let name = userInfo[SocketNotificationUserInfoKey.userNameKey.rawValue] as? String

            var client = self.findClient(by: name!)
            if client == nil {
                client = self.findClient(by: socket!)
            }
            if client == nil {
                client = SocketClient()
                self.registerClients.append(client!)
            }

            client?.socket = socket
            client?.name = name
            client?.isOnline = true
            self.delegate?.clientUpdated()
        }

        //用户下线通知
        let offlineNotificationName = SocketConnectorNotification.didReceiveClientOfflineNotification.rawValue
        notificationCenter.addObserver(forName: NSNotification.Name(offlineNotificationName),
                                       object: SocketConnector.shared,
                                       queue: OperationQueue.main)
        { (notification) in

            guard let userInfo = notification.userInfo else {
                return
            }

            let socket = userInfo[SocketNotificationUserInfoKey.socketObjectKey.rawValue] as? GCDAsyncSocket

            if let client = self.findClient(by: socket!) {
                client.isOnline = false
            }

            self.delegate?.clientUpdated()
        }
    }
}
