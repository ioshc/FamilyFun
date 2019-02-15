//
//  GuessViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/24.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import AudioToolbox

public enum GuessType : Int {

    case youDoIGuess        //你做我猜
    case youSpeakIGuess     //你说我猜
    case youAnwserIGuess    //我问你回到对或错，然后我猜
}

class Sentence: NSObject {
    var word: String?
    var desc: String?
}

class Player: NSObject {
    var name: String?
    private(set) var score: Int32 = 0
    var isPlaying: Bool = false

    func desc() -> String {

        if name != nil {
            return name! + "：" + "\(score)"
        }
        return ""
    }

    func reset() {
        score = 0
    }

    func increaseScroe() {
        score = score + 1
    }
}

class GuessViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var wrongButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    var guessType: GuessType = .youDoIGuess
    private var _timer: Timer?

    private var _fullSentenceSet = Set<Sentence>()
    private var _usedSentenceSet = Set<Sentence>()
    private var _playerList = [Player]()
    private var _currentPlayingPlayer: Player?

    override func viewDidLoad() {
        super.viewDidLoad()

        timeLabel.layer.cornerRadius = 50
        timeLabel.clipsToBounds = true

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .play,
                                                                 target: self,
                                                                 action: #selector(onStartButtonClicked(_:)))

        switch guessType {
        case .youDoIGuess:
            title = "你做我猜"
            loadSentenceList("youDoIGuessList")
        case .youSpeakIGuess:
            title = "你说我猜"
            loadSentenceList("youSpeakIGuessList")
        case .youAnwserIGuess:
            title = "你答我猜"
            loadSentenceList("youAnwserIGuessList")
        }

        UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _timer?.invalidate()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
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
}


extension GuessViewController {

    func removeDuplicate(_ name: String) {

        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            return
        }

        //杀鸡取卵:;摩拳擦掌:;
        guard var string = try? String.init(contentsOfFile: path) else {
            return
        }

        //替换中文
        string = string.replacingOccurrences(of: "\n", with: "")
        string = string.replacingOccurrences(of: "；", with: ";")
        string = string.replacingOccurrences(of: "：", with: ":")

        let array = string.components(separatedBy: ":;")

        var newArray = [String]()
        for item in array {
            if newArray.contains(item) == false && item.count > 1 {

                if item.count > 4 {
                    newArray.insert(item, at: 0)
                } else {
                    newArray.append(item)
                }
            }
        }

        let newStr = newArray.joined(separator: ":;\n")

        do {
            try newStr.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }

    func loadSentenceList(_ name: String) {

        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            return
        }

        //杀鸡取卵:;摩拳擦掌:;
        guard var string = try? String.init(contentsOfFile: path) else {
            return
        }

        //替换中文
        string = string.replacingOccurrences(of: "\n", with: "")
        string = string.replacingOccurrences(of: "；", with: ";")
        string = string.replacingOccurrences(of: "：", with: ":")

        let array = string.components(separatedBy: ";")
        for item in array {
            let components = item.components(separatedBy: ":")
            let sentence = Sentence()
            sentence.word = components.first
            sentence.desc = components.last
            _fullSentenceSet.insert(sentence)
        }
    }

    func displayingNewSentence() {
        let remaining = _fullSentenceSet.symmetricDifference(_usedSentenceSet)

        let newSentence = remaining.anyObject()
        _usedSentenceSet.insert(newSentence)
        wordLabel.text = newSentence.word
        descriptionLabel.text = newSentence.desc
    }
}

// MARK: - Button Action
extension GuessViewController {

    @objc func onStartButtonClicked(_ sender: UIButton) {

        guard _currentPlayingPlayer != nil else {
            return
        }

        rightButton.isEnabled = true
        wrongButton.isEnabled = true
        nextButton.isEnabled = true

        _currentPlayingPlayer?.reset()
        sender.isEnabled = false
        displayingNewSentence()
        var timingCount = 60 * 5
        timeLabel.text = "\(timingCount)"
        _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (t) in
            timingCount = timingCount - 1
            self?.timeLabel.text = "\(timingCount)"

            if timingCount == 3 {
                self?.alertTimeIsUp()
            }

            //游戏结束
            if timingCount <= 0 {
                t.invalidate()
                sender.isEnabled = true
                self?.rightButton.isEnabled = false
                self?.wrongButton.isEnabled = false
                self?.nextButton.isEnabled = false
                self?._currentPlayingPlayer = nil
                self?.tableView.reloadData()
            }
        }
        _timer?.fire()
    }

    @IBAction func onAddButtonClicked(_ sender: UIButton) {
        let player = Player()
        player.name = "T\(_playerList.count + 1)"
        _playerList.append(player)
        tableView.reloadData()
    }

    @IBAction func onRightButtonClicked(_ sender: UIButton) {

        guard _currentPlayingPlayer != nil else {
            return
        }

        _currentPlayingPlayer?.increaseScroe()
        displayingNewSentence()
        tableView.reloadData()
    }

    @IBAction func onWrongButtonClicked(_ sender: UIButton) {

        guard _currentPlayingPlayer != nil else {
            return
        }

        displayingNewSentence()
        tableView.reloadData()
    }

    @IBAction func onNextButtonClicked(_ sender: UIButton) {

        guard _currentPlayingPlayer != nil else {
            return
        }

        displayingNewSentence()
        tableView.reloadData()
    }
}

// MARK: - Button Action
extension GuessViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _playerList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 25)
            cell?.selectionStyle = .none
        }

        let player = _playerList[indexPath.row]
        cell?.textLabel?.text = player.desc()

        if player == _currentPlayingPlayer {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        //取消选择旧的
        if _currentPlayingPlayer != nil {
            _currentPlayingPlayer?.isPlaying = false
            let idx = _playerList.index(of: _currentPlayingPlayer!)!
            tableView.cellForRow(at: IndexPath(row: idx, section: 0))?.accessoryType = .none
        }

        //选择已选中的就取消选择
        let newPlayer = _playerList[indexPath.row]
        if newPlayer == _currentPlayingPlayer {
            _currentPlayingPlayer = nil
            return
        }

        //选择新的
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        _currentPlayingPlayer = newPlayer
        _currentPlayingPlayer?.isPlaying = true
    }
}
