//
//  ReactPoseViewController.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/22.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit
import AudioToolbox

struct PoseItem {
    var originalImage: UIImage?
    var actImage: UIImage?
}

class ReactPoseViewController: UIViewController {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var originalImageView: UIImageView!
    @IBOutlet var startButton: UIButton!

    private var _allImageList = Set<UIImage>()
    private var _usedImageList = Set<UIImage>()

    private var _poseItemList = [PoseItem]()

    private var _timer: Timer?
    private var _picker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "重复动作"

        timeLabel.layer.cornerRadius = 50
        timeLabel.clipsToBounds = true
        originalImageView.layer.borderColor = UIColor.lightGray.cgColor
        originalImageView.layer.borderWidth = 1.0

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .bookmarks,
                                                                 target: self,
                                                                 action: #selector(onShowListButtonClicked(_:)))

        loadImageList()
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
        originalImageView.image = nil
        startButton.isEnabled = true
    }
}

extension ReactPoseViewController {

    func loadImageList() {

        for i in 0...8 {
            guard let path = Bundle.main.path(forResource: "合照\(i+1)", ofType: "jpg") else {
                return
            }
            
            if let image =  UIImage.init(contentsOfFile: path) {
                _allImageList.insert(image)
            }
        }
    }

    func displayingNewImage() {
        let remaining = _allImageList.symmetricDifference(_usedImageList)

        let newImage = remaining.anyObject()
        _usedImageList.insert(newImage)
        originalImageView.image = newImage
    }
}

extension ReactPoseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var item = PoseItem()
            item.originalImage = originalImageView.image
            item.actImage = image
            _poseItemList.append(item)
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

extension ReactPoseViewController {

    @objc func onTakePhotoButtonClicked(_ sender: UIButton?) {
        _picker?.takePicture()
    }

    @objc func onShowListButtonClicked(_ sender: UIButton) {

        guard _poseItemList.count > 0  && (_timer?.isValid != false) else {
            return
        }

        if let vc = PoseListViewController.controllerInStoryboard(name: "ReactPose") as? PoseListViewController {
            vc.poseItemList = _poseItemList
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func onStartButtonClicked(_ sender: UIButton) {

        sender.isEnabled = false
        displayingNewImage()

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
