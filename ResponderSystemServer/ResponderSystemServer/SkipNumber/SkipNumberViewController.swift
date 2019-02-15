//
//  SkipNumberViewController.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/29.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class SkipNumberViewController: NSViewController {

    @IBOutlet var collectionView: NSCollectionView!
    @IBOutlet var pointerView: NSView!

    private var _timer: Timer?
    private var _countingNumber: Int32 = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        ClientManager.shared.delegate = self
        setupUI()

        var angle: Double = 0
        _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
            self.pointerView.layer?.setAffineTransform(CGAffineTransform.init(rotationAngle: CGFloat(-2*Double.pi*angle/360.0)))
            angle += 90

            if angle >= 360 {
                angle = 0
            }
        }
        _timer?.fire()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        _timer?.invalidate()
    }

    func setupUI() {
        collectionView.collectionViewLayout = CycleLayout()

        let viewLayer = CALayer()
        viewLayer.backgroundColor = NSColor(red: 0,
                                            green: 143.0/255.0,
                                            blue: 0,
                                            alpha: 1).cgColor
        viewLayer.cornerRadius = 5
        pointerView.wantsLayer = true
        pointerView.layer = viewLayer
    }
}

extension SkipNumberViewController {

    @IBAction func onStartButtonClicked(_ sender: NSButton) {

        guard ClientManager.shared.registerClients.count > 0 else {
            return
        }

        _countingNumber = _countingNumber + 1
        ClientManager.shared.markAllOnlineClientsAsUneliminated()
        var _ = ClientManager.shared.sendToAllOnlineClient("SkipNumber@\(_countingNumber)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {

        }
    }
}

extension SkipNumberViewController {

    func increseCountingNumber() {
        _countingNumber = _countingNumber + 1
    }

    func resetCountingNumber() {
        _countingNumber = 0
    }
}

extension SkipNumberViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return ClientManager.shared.registerClients.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PlayerCollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? PlayerCollectionViewItem else {return item}

        let client = ClientManager.shared.registerClients[indexPath.item]
        collectionViewItem.nameTextField.stringValue = client.name ?? ""
        collectionViewItem.state = PlayerCollectionViewItemState(rawValue: indexPath.item % 3)!
        collectionViewItem.updateBackgroundColor()
        
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

    }
}

// MARK: - ClientManagerClientUpdatedDelegate
extension SkipNumberViewController: ClientManagerClientUpdatedDelegate {

    func clientUpdated() {
        self.collectionView.reloadData()
    }
}
