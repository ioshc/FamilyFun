//
//  PoseListViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/26.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class PoseListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var poseItemList: Array<PoseItem>?

    override func viewDidLoad() {

        title = "历史记录"
        super.viewDidLoad()
    }
}

extension PoseListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poseItemList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.selectionStyle = .none
        }

        cell?.imageView?.image = poseItemList?[indexPath.row].originalImage

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let vc = PoseDetailViewController.controllerInStoryboard(name: "ReactPose") as? PoseDetailViewController {
            vc.poseItem = poseItemList?[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
