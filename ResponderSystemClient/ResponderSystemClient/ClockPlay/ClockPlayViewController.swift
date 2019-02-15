//
//  ClockPlayViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/22.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import AudioToolbox

struct CLockPlayItem {
    var time: String?
    var image: UIImage?
}

class ClockPlayViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var sentenceLabel: UILabel!
    @IBOutlet var startButton: UIButton!

    private var _clockPlayItemList = [CLockPlayItem]()

    private var _timer: Timer?
    private var _picker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "时钟扮演"
        
        timeLabel.layer.cornerRadius = 50
        timeLabel.clipsToBounds = true

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .bookmarks,
                                                                 target: self,
                                                                 action: #selector(onShowListButtonClicked(_:)))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _timer?.invalidate()
    }

    func alertTimeIsUp() {
        //建立的SystemSoundID对象
        var soundID:SystemSoundID = 0
        //获取声音地址
        let path = Bundle.main.path(forResource: "当当当", ofType: "wav")
        //地址转换
        let baseURL = NSURL(fileURLWithPath: path!)
        //赋值
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        //播放声音
        AudioServicesPlaySystemSound(soundID)
    }

    func startTakePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.showsCameraControls = false

        let button = UIButton(type: .system)
        button.frame = CGRect(x: ((self.view.bounds.width - 100) / 2),
                              y: self.view.bounds.height - 160,
                              width: 100,
                              height: 100)
        button.backgroundColor = UIColor.white
        button.setTitle("照相", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.addTarget(self,
                         action: #selector(onTakePhotoButtonClicked(_:)),
                         for: .touchUpInside)
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        picker.cameraOverlayView = button

        present(picker, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.onTakePhotoButtonClicked(nil)
            })
        }
        _picker = picker
    }

    func resetUI() {
        timeLabel.text = "20"
        sentenceLabel.text = "神秘时间"
        startButton.isEnabled = true
    }
}

extension ClockPlayViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var item = CLockPlayItem()
            item.time = sentenceLabel.text
            item.image = image
            _clockPlayItemList.append(item)
        }
        resetUI()
        _picker = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        resetUI()
        _picker = nil
    }
}

extension ClockPlayViewController {

    @objc func onTakePhotoButtonClicked(_ sender: UIButton?) {
        _picker?.takePicture()
    }

    @objc func onShowListButtonClicked(_ sender: UIButton) {

        guard _clockPlayItemList.count > 0  && (_timer?.isValid != false) else {
            return
        }

        if let vc = ClockListViewController.controllerInStoryboard(name: "ClockPlay") as? ClockListViewController {
            vc.clockPlayItemList = _clockPlayItemList
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func onStartButtonClicked(_ sender: UIButton) {

        sender.isEnabled = false

        let hour = Int.random(lower: 1, 12)
        let munite = Int.random(lower: 0, 60, 5)
        var second = Int.random(lower: 0, 60, 5)
        while second == munite {
            second = Int.random(lower: 0, 60, 5)
        }
        sentenceLabel.text = ("\(hour)时\(munite)分\(second)秒")

        var timeRemainning = 20
        timeLabel.text = "\(timeRemainning)"
        _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (t) in

            timeRemainning = timeRemainning - 1
            self?.timeLabel.text = "\(timeRemainning)"

            if timeRemainning == 3 {
                self?.alertTimeIsUp()
            }
            if timeRemainning <= 0 {
                t.invalidate()
                self?.startTakePhoto()
                self?._timer = nil
            }
        }
        _timer?.fire()
    }
}


public extension Int {
    public static func random(lower: Int = 0, _ upper: Int = Int.max, _ multiple: Int) -> Int {

        var value = lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
        value = value - (value % multiple)
        return value
    }
}
