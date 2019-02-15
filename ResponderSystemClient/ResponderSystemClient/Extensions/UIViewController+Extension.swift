//
//  UIViewController+Extension.swift
//  PartyMemberEHome
//
//  Created by eden on 2017/6/30.
//  Copyright © 2017年 com.PartyMemberEHome. All rights reserved.
//

import UIKit

extension UIViewController {

    static func controllerFromXib() -> UIViewController? {
        return self.init(nibName: selfClassName(), bundle: nil)
    }

    static func controllerInStoryboard(name:String!) -> UIViewController? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: selfClassName())
    }

    static func selfClassName()-> String {
        var className = NSStringFromClass(self)
        className = className.components(separatedBy: ".").last!

        return className
    }

    func shakeView(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07;
        animation.repeatCount = 4;
        animation.autoreverses = true;
        animation.fromValue = CGPoint(x: view.center.x - 10,
                                      y: view.center.y)
        animation.toValue = CGPoint(x: view.center.x + 10,
                                    y: view.center.y)
        view.layer.add(animation, forKey: "position")
    }
}

extension Set {
    func anyObject() -> Element {
        let array = self.sorted { (obj1, obj2) -> Bool in
            return true
        }
        return array[Int.random(lower: 0, array.count - 1)]
    }
}
