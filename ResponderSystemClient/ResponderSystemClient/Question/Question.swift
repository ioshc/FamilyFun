//
//  Question.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/16.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import UIKit

class Question: NSObject {

    var index: Int = 0
    var title: String?
    var solutions: [String]?
    var answer: String?
    var author: String?
    var orginalString: String?
    var isAnwserable: Bool = true

    init(_ string: String) {

        //中国首都在哪里?北京,上海,深圳:北京
        let titleAndSolution: Array = string.components(separatedBy: "?")
        //北京,上海,深圳:北京
        let solution: String = titleAndSolution.last!
        //北京,上海,深圳:北京
        let solutionAndAnwser: Array = solution.components(separatedBy: ":")

        index = Int((titleAndSolution.first?.components(separatedBy: ".").first)!)!
        title = titleAndSolution.first
        solutions = solutionAndAnwser.first?.components(separatedBy: ",")
        answer = solutionAndAnwser.last
        orginalString = string
    }

    func stringValue() -> String {
        return (self.title?.appendingFormat("?%@", (self.solutions?.joined(separator: ","))!))!
    }
}
