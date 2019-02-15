//
//  AppDelegate.swift
//  ResponderSystemClient
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let titleAttr = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 25)]
        UINavigationBar.appearance().titleTextAttributes = titleAttr
        UINavigationBar.appearance().tintColor = UIColor(red: 114.0 / 255.0,
                                                         green: 103.0 / 255.0,
                                                         blue: 69.0 / 255.0,
                                                         alpha: 1)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-200, 0), for: .`default`)
        UIBarButtonItem.appearance().setTitleTextAttributes(titleAttr, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(titleAttr, for: .highlighted)
        return true
    }
}
