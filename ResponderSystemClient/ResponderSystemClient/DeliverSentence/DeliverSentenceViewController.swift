//
//  DeliverSentenceViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/26.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import AudioToolbox

class DeliverSentenceViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var sentenceLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    private var _timer: Timer?
    
    private var _fullSentenceSet = Set<String>()
    private var _usedSentenceSet = Set<String>()
    private var _usedSentenceList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "传声筒"

        timeLabel.layer.cornerRadius = 60
        timeLabel.clipsToBounds = true
        showButton.isHidden = true
        nextButton.isHidden = true

        loadSentenceList()
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

    func showSentenceLabel() {
        sentenceLabel.text = _usedSentenceList.last
        startButton.isHidden = true
        showButton.isHidden = false
        nextButton.isHidden = false
    }

    func resetUI() {
        sentenceLabel.text = "神秘句子"
        startButton.isHidden = false
        showButton.isHidden = true
        nextButton.isHidden = true
        timeLabel.text = "30"
    }
}

extension DeliverSentenceViewController {

    func loadSentenceList() {

        guard let path = Bundle.main.path(forResource: "sentenceList", ofType: nil) else {
            return
        }

        guard var string = try? String.init(contentsOfFile: path) else {
            return
        }

        //替换中文
        string = string.replacingOccurrences(of: "\n", with: "")
        string = string.replacingOccurrences(of: "；", with: ";")
        string = string.replacingOccurrences(of: "：", with: ":")

        let array = string.components(separatedBy: "————")
        for item in array {
            _fullSentenceSet.insert(item)
        }
    }

    func displayingNewSentence() {
        let remaining = _fullSentenceSet.symmetricDifference(_usedSentenceSet)

        let newSentence = remaining.anyObject()
        _usedSentenceSet.insert(newSentence)
        _usedSentenceList.append(newSentence)
        showSentenceLabel()
    }
}

extension DeliverSentenceViewController {

    @IBAction func onStartButtonClicked(_ sender: UIButton) {

        displayingNewSentence()
        showButton.isEnabled = false
        nextButton.isEnabled = false

        var timeRemainning = 30
        timeLabel.text = "\(timeRemainning)"
        _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (t) in

            timeRemainning = timeRemainning - 1
            self?.timeLabel.text = "\(timeRemainning)"

            if timeRemainning == 3 {
                self?.alertTimeIsUp()
            }

            if timeRemainning <= 0 {
                t.invalidate()
                self?._timer = nil
                self?.sentenceLabel.text = "神秘句子"
                self?.showButton.isEnabled = true
                self?.nextButton.isEnabled = true
            }
        }
        _timer?.fire()
    }

    @IBAction func onShowSentenceButtonClicked(_ sender: UIButton) {
        sentenceLabel.text = _usedSentenceList.last
    }

    @IBAction func onNextButtonClicked(_ sender: UIButton) {
        resetUI()
    }

}
