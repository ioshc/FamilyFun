//
//  ViewController.swift
//  Sharking
//
//  Created by eden on 2018/1/15.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var startButton: UIButton!

    let motionManager = CMMotionManager()
    var userShakeCount = 0
    var shakeCount = 0
    var timeRemaining = 0
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.accelerometerUpdateInterval = 1/60.0
    }

    func isShake(_ newestAccel: CMAccelerometerData) -> Bool {

        var isShake = false;

        // 三个方向任何一个方向的加速度大于1.5就认为是处于摇晃状态，当都小于1.5时认为摇奖结束。
        if (abs(newestAccel.acceleration.x) > 2.5 ||
            abs(newestAccel.acceleration.y) > 2.5 ||
            abs(newestAccel.acceleration.z) > 2.5) {
            isShake = true;
        }

        return isShake;
    }

    func startShakeCounting() {

        if motionManager.isAccelerometerAvailable {
            let queue = OperationQueue.current
            motionManager.startAccelerometerUpdates(to: queue!, withHandler: {
                (accelerometerData, error) in

                guard let accelerometerData = accelerometerData else {
                    return;
                }

                if (self.isShake(accelerometerData)) {
                    self.userShakeCount = self.userShakeCount + 1;
                    print("shaking count: \(self.userShakeCount)")
                }
            })
        }
    }

    func stopShakeCounting() {
        motionManager.stopAccelerometerUpdates()
        DispatchQueue.main.async {
            self.startButton.isEnabled = true
            self.timeLabel.text = "\(self.userShakeCount)次"
        }
    }

    func startTimeCounting() {

        if timer != nil {
            stopTimeCounting()
        }

        timeRemaining = 100
        timer = Timer.init(timeInterval: 0.1, repeats: true, block: { (t) in
            self.timeRemaining = self.timeRemaining - 1

            if self.timeRemaining <= 0 {
                self.stopTimeCounting()
            }
            self.timeLabel.text = "\((self.timeRemaining/10))"
        })

        userShakeCount = 0
        shakeCount = 0
        startShakeCounting()

        RunLoop.current.add(timer!, forMode: .commonModes)
    }

    func stopTimeCounting() {
        timer?.invalidate()
        timer = nil;
        stopShakeCounting()
    }

    @IBAction func startShake(_ sender: UIButton) {

        startButton.isEnabled = false
        timeLabel.text = "10"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.startTimeCounting()
        }
    }
}

