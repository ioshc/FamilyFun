//
//  QuestionAnwserView.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/16.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import AudioToolbox

class QuestionAnwserView: UIView {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var anwser1Button: UIButton!
    @IBOutlet var anwser2Button: UIButton!
    @IBOutlet var anwser3Button: UIButton!

    var question: Question?
    var anwser: Anwser?
    var selectionClosure: ((String) -> Void)?
    var _buttons = [UIButton]()

    override func awakeFromNib() {
        super.awakeFromNib()

        timeLabel.layer.cornerRadius = 30
        timeLabel.clipsToBounds = true

        _buttons.append(anwser1Button)
        _buttons.append(anwser2Button)
        _buttons.append(anwser3Button)

        for button in _buttons {
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 25
            button.clipsToBounds = true
        }
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

    func alertVictory() {
        //建立的SystemSoundID对象
        var soundID:SystemSoundID = 0
        //获取声音地址
        let path = Bundle.main.path(forResource: "胜利", ofType: "wav")
        //地址转换
        let baseURL = NSURL(fileURLWithPath: path!)
        //赋值
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        //播放声音
        AudioServicesPlaySystemSound(soundID)
    }

    func systemVibration() {
        //建立的SystemSoundID对象
        let soundID = SystemSoundID(kSystemSoundID_Vibrate)
        //振动
        AudioServicesPlaySystemSound(soundID)
    }
}

extension QuestionAnwserView {

    func show(inView view: UIView, selection: ((String) -> Void)?) {

        selectionClosure = selection

        view.addSubview(self)
        bounds = CGRect(x: 0, y: 0, width: 300, height: 500)
        center = view.center
        layer.shadowColor = UIColor(white: 0.95, alpha: 1).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 1

        if let question = question {//如果是答题界面

            if question.isAnwserable == false {
                timeLabel.text = "观"
                timeLabel.backgroundColor = UIColor.gray
            }
            titleLabel.text = question.title! + "？"

            for i in 0..._buttons.count-1 {
                let button = _buttons[i]
                button.isExclusiveTouch = true
                button.isEnabled = question.isAnwserable
                button.setTitle(question.solutions![i], for: .normal)
            }
        } else if let anwser = anwser {//如果是显示答案界面

            if anwser.question?.isAnwserable == false {//已淘汰则显示 “观” 表示观战
                timeLabel.text = "观"
                timeLabel.backgroundColor = UIColor.lightGray
            } else {//未淘汰则显示答题结果
                timeLabel.text = anwser.isRight ? " ✔︎ " : " ✘ "
                if !anwser.isRight {
                    timeLabel.backgroundColor = UIColor.red
                } else {
                    alertVictory()
                }
            }
            titleLabel.text = (anwser.question?.title)! + "？"


            var total = 0
            for count in anwser.anwsersCounts! {
                total = total + count
            }

            for i in 0..._buttons.count-1 {
                let button = _buttons[i]
                button.isEnabled = false
                button.setTitle(anwser.question?.solutions![i], for: .normal)

                if total > 0 {
                    let percent = CGFloat(anwser.anwsersCounts![i]) / CGFloat(total)
                    let buttonBounds = button.bounds
                    let width = max(percent * buttonBounds.width, 20)
                    let colorLayer = CALayer()
                    colorLayer.opacity = 0.2
                    colorLayer.frame = CGRect(x: 0,
                                              y: 0,
                                              width: width,
                                              height: buttonBounds.height)

                    if i == anwser.question?.solutions?.index(of: (anwser.question?.answer)!) {
                        colorLayer.backgroundColor = UIColor.green.cgColor
                    } else {
                        colorLayer.backgroundColor = UIColor.red.cgColor
                    }
                    button.layer.addSublayer(colorLayer)

                    let label = UILabel()
                    label.backgroundColor = UIColor.clear
                    label.textColor = UIColor.white
                    label.font = UIFont.systemFont(ofSize: 20)
                    label.text = String(format: "%.0f%%", percent * 100.0)
                    label.sizeToFit()
                    button.addSubview(label)
                    label.center = CGPoint(x: buttonBounds.size.width - label.bounds.size.width / 2 - 10,
                                           y: buttonBounds.height / 2)
                }
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if self.superview == nil {
            return
        }

        if question != nil {
            var remainingTime = 15
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
                remainingTime = remainingTime - 1;

                if (self?.question?.isAnwserable)! {
                    self?.timeLabel.text = "\(remainingTime)";

                    if (remainingTime == 3) {
                        self?.alertTimeIsUp()
                    }
                }
                if remainingTime <= 0 {
                    timer.invalidate()
                    self?.removeFromSuperview()
                }
            }
        } else if anwser != nil {

            //5秒钟之后移除当前界面
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.removeFromSuperview()
            })
        }
    }
}

extension QuestionAnwserView {

    @IBAction func onAnwserButtonClicked(_ sender: UIButton) {

        if sender.isSelected {
            return
        }

        for button in _buttons {
            button.isEnabled = false
        }

        sender.isSelected = true
        sender.isEnabled = true

        if let closure = selectionClosure {
            let anwser = question?.solutions![sender.tag]
            closure(anwser!)
        }
    }
}
