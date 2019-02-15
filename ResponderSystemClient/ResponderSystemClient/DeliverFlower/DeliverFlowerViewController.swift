//
//  DeliverFlowerViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/23.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class DeliverFlowerViewController: UIViewController {

    @IBOutlet var textField: UITextField!

    var audioPlayer: AVAudioPlayer?
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "击鼓传花"
        createBGM()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        stopBGM()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if !(touches.first?.view is UITextField) {
            self.view.endEditing(true)
        }
    }

    @IBAction func onStartButtonClicked(_ sender: UIButton) {

        //禁用控件
        self.view.endEditing(true)
        sender.isEnabled = false
        textField.isEnabled = false

        //获取设置的游戏次数
        let loop = Int(textField.text ?? "") ?? 1
        startGame(loop) { (finished) in
            sender.isEnabled = true
            self.textField.isEnabled = true
        }
    }

    func startGame(_ loop: Int, _ completion: ((Bool) -> Void)? ) {

        guard loop > 0 else {
            completion?(true)
            return
        }
        Loger.addLog("remainning loop count: \(loop)")

        var seconds = Int.random(lower: 10, 120)
        Loger.addLog("start counting with \(seconds)")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in

            seconds = seconds - 1

            //此轮计时结束
            if seconds <= 0 {
                timer.invalidate()
                self?.stopBGM()

                //20秒后递归调用
                DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: {
                    self?.startGame(loop - 1, completion)
                })
            }
        }
        timer?.fire()
        startBGM()
    }
}


// MARK: - BGM
extension DeliverFlowerViewController {
    func createBGM() {

        let path = Bundle.main.path(forResource: "击鼓传花2", ofType: "wav")
        let pathURL = URL(fileURLWithPath: path!)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pathURL)
            audioPlayer?.numberOfLoops = -1
        } catch {
            audioPlayer = nil
        }

        audioPlayer?.prepareToPlay()
    }

    func startBGM() {

        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }

    func pauseBGM() {
        audioPlayer?.pause()
    }

    func stopBGM() {
        audioPlayer?.stop()
    }
}

public extension Int {
    public static func random(lower: Int = 0, _ upper: Int = Int.max) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}
