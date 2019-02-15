//
//  ClockListViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/25.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class ClockListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var clockPlayItemList: Array<CLockPlayItem>?

    override func viewDidLoad() {

        title = "历史记录"
        super.viewDidLoad()
    }
}

extension ClockListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockPlayItemList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 25)
            cell?.selectionStyle = .none
        }

        cell?.textLabel?.text = clockPlayItemList?[indexPath.row].time

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let vc = ClockDetailViewController.controllerInStoryboard(name: "ClockPlay") as? ClockDetailViewController {
            vc.clockPlayItem = clockPlayItemList?[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
