//
//  Loger.swift
//  ResponderSystemClient
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import Cocoa

class Loger: NSObject {

    static func addLog(_ log: String) {

        print(log)

        var logs = getLogs()
        if logs == nil {
            logs = [String]()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "[yyyy-MM-dd HH:mm:ss] "
        let timedLog = formatter.string(from: Date()) + log

        logs!.insert(timedLog, at: 0)
        storeLogs(logs!)
    }

    static func readLog(_ separator: String = "\r\n") -> String? {

        var string: String?
        guard let logs = getLogs() else {
            return string
        }

        string = ""
        for(idx, log) in logs.enumerated() {
            string! += log
            if idx < (logs.count - 1) {string! += separator}
        }

        return string
    }
}

extension Loger {

    static let keyLogsStore = "LogerLogsStorekey"

    fileprivate static func storeLogs(_ logs: Array<String>) {
        UserDefaults.standard.set(logs, forKey: keyLogsStore)
    }

    fileprivate static func getLogs() -> Array<String>? {
        return UserDefaults.standard.object(forKey: keyLogsStore) as? Array<String>
    }
}
