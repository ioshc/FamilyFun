//
//  MainViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/16.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let cellItems = ["一起冲顶",
                     "击鼓传花",
                     "你做我猜",
                     "你说我猜",
                     "你答我猜",
                     "时钟扮演",
                     "重复动作",
                     "传声筒",
                     "跳过7",
//                     "抢答"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "乐翻天";
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
    }

    @IBAction func onSettingButtonClicked(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(InfoViewController.controllerFromXib()!,
                                                 animated: true)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return cellItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "UITableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .`default`, reuseIdentifier: cellIdentifier)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 30)
        }

        cell?.textLabel?.text = cellItems[indexPath.section]

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            navigationController?.pushViewController(QuestionViewController.controllerInStoryboard(name: "Question")!,
                                                     animated: true)
        case 1:
            navigationController?.pushViewController(DeliverFlowerViewController.controllerFromXib()!,
                                                     animated: true)
        case 2:
            let guessVC = GuessViewController.controllerInStoryboard(name: "Guess") as! GuessViewController
            guessVC.guessType = .youDoIGuess
            navigationController?.pushViewController(guessVC, animated: true)
        case 3:
            let guessVC = GuessViewController.controllerInStoryboard(name: "Guess") as! GuessViewController
            guessVC.guessType = .youSpeakIGuess
            navigationController?.pushViewController(guessVC, animated: true)
        case 4:
            let guessVC = GuessViewController.controllerInStoryboard(name: "Guess") as! GuessViewController
            guessVC.guessType = .youAnwserIGuess
            navigationController?.pushViewController(guessVC, animated: true)
        case 5:
            navigationController?.pushViewController(ClockPlayViewController.controllerInStoryboard(name: "ClockPlay")!,
                                                     animated: true)
        case 6:
            navigationController?.pushViewController(ReactPoseViewController.controllerInStoryboard(name: "ReactPose")!,
                                                     animated: true)
        case 7:
            navigationController?.pushViewController(DeliverSentenceViewController.controllerFromXib()!,
                                                     animated: true)
        case 8:
            navigationController?.pushViewController(SkipNumberViewController.controllerFromXib()!,
                                                     animated: true)
        case 9:
            navigationController?.pushViewController(ResponderViewController.controllerFromXib()!,
                                                     animated: true)
        default:
            break
        }
    }
}
