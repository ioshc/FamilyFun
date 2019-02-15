//
//  Question.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/16.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class Question: NSObject {

    var title: String?
    var solutions: [String]?
    var answer: String?
    var author: String?
    var orginalString: String?
    var canShowAnwser: Bool = false

    init(_ string: String) {

        //中国首都在哪里?北京,上海,深圳:北京
        let titleAndSolution: Array = string.components(separatedBy: "?")

        //北京,上海,深圳:北京
        var solution: String = titleAndSolution.last!
        solution = solution.replacingOccurrences(of: "，", with: ",")
        solution = solution.replacingOccurrences(of: "：", with: ":")

        //北京,上海,深圳:北京
        let solutionAndAnwser: Array = solution.components(separatedBy: ":")

        self.title = titleAndSolution.first
        self.solutions = solutionAndAnwser.first?.components(separatedBy: ",")
        self.answer = solutionAndAnwser.last
        self.orginalString = string
    }

    func stringValue() -> String {
        let str = (self.title?.appendingFormat("?%@", (self.solutions?.joined(separator: ","))!))!

        if str == "?" {
            print("dddd")
        }
        return str
    }
}
