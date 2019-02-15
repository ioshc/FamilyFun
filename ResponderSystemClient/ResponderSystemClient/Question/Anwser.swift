//
//  Anwser.swift
//  ResponderSystemClient
//
//  Created by eden on 2018/1/18.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class Anwser: NSObject {

    var question: Question?
    var userAnwser: String?
    var userAnwserIdx: Int = -1
    var isRight: Bool = false
    var anwsersCounts: Array<Int>?
}
