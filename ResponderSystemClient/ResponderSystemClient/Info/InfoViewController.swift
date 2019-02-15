//
//  InfoViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import UIKit

class InfoViewLogCell: UITableViewCell {
    @IBOutlet var label: UILabel?
}

class InfoViewController: UIViewController {

    @IBOutlet var teamTF: UITextField!
    @IBOutlet var hostTF: UITextField!
    @IBOutlet var portTF: UITextField!
    @IBOutlet var tableView: UITableView!

    private var logList: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "设置"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange(_:)),
                                               name: .UITextFieldTextDidChange,
                                               object: teamTF)

        self.teamTF.text = SocketConnector.shared?.team
        self.hostTF.text = SocketConnector.shared?.host
        self.portTF.text = SocketConnector.shared?.port

        self.tableView.register(UINib(nibName: "InfoViewLogCell", bundle: nil),
                                forCellReuseIdentifier: "InfoViewLogCell")
        self.logList = Loger.getLogs()
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in

                self?.logList = Loger.getLogs()
                self?.tableView.reloadData()
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if !(touches.first?.view is UITextField) {
            view.endEditing(true)
        }
    }

    @IBAction func onCleanLogButtonClicked(_sender: UIButton) {
        Loger.cleanLogs()
        tableView.reloadData()
    }

    @IBAction func onReconnectButtonClicked(_sender: UIButton) {

        guard let host = hostTF.text else {
            return
        }

        guard let port = portTF.text else {
            return
        }

        SocketConnector.shared?.host = host
        SocketConnector.shared?.port = port
        SocketConnector.shared?.reconnect()
    }
}

extension InfoViewController: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoViewLogCell", for: indexPath)

        if let cell = cell as? InfoViewLogCell {
            cell.label?.text = logList?[indexPath.row]
        }
        return cell
    }
}

extension InfoViewController: UITextFieldDelegate {

    @objc func textDidChange(_ notify: Notification) {
        let textField: UITextField = notify.object as! UITextField;
        if textField == teamTF {
            SocketConnector.shared?.team = textField.text
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}
