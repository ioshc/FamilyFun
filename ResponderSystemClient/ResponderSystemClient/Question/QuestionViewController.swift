//
//  QuestionViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/16.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "第\(SocketConnector.shared?.team ?? "X")组"

        registerNotifications()

        DispatchQueue.main.async {
            if SocketConnector.shared?.team == "" {
                self.present(LoginViewController.controllerFromXib()!, animated: true, completion: nil)
            }
        }

        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension QuestionViewController {

    func showQuestionAnwserView(question: Question) {

        let view = Bundle.main.loadNibNamed("QuestionAnwserView", owner: self, options: nil)![0]
        guard let questionAnwserView = view as? QuestionAnwserView else {
            return
        }

        questionAnwserView.question = question
        questionAnwserView.show(inView: self.view) { (anwser) in
            SocketConnector.shared?.send(anwser)
        }
    }

    func showQuestionAnwserView(anwser: Anwser) {

        let view = Bundle.main.loadNibNamed("QuestionAnwserView", owner: self, options: nil)![0]
        guard let questionAnwserView = view as? QuestionAnwserView else {
            return
        }

        questionAnwserView.anwser = anwser
        questionAnwserView.show(inView: self.view, selection: nil)
    }

    func registerNotifications() {

        let notificationCenter = NotificationCenter.default

        //Question
        let questionNotificationName = SocketConnectorNotification.didReceiveQuestionNotification.rawValue
        notificationCenter.addObserver(forName: NSNotification.Name(questionNotificationName),
                                       object: SocketConnector.shared,
                                       queue: OperationQueue.main)
        { (notification) in

            guard let question = notification.userInfo!["Question"] as? Question else {
                return
            }

            self.showQuestionAnwserView(question: question)
        }

        //Anwser
        let anwserNotificationName = SocketConnectorNotification.didReceiveAnwserNotification.rawValue
        notificationCenter.addObserver(forName: NSNotification.Name(anwserNotificationName),
                                       object: SocketConnector.shared,
                                       queue: OperationQueue.main)
        { (notification) in

            guard let anwser = notification.userInfo!["Anwser"] as? Anwser else {
                return
            }

            self.showQuestionAnwserView(anwser: anwser)
        }
    }
}
