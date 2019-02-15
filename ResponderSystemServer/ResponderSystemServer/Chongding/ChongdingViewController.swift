//
//  MainViewController.swift
//  ResponderSystemServer
//
//  Created by eden on 2017/12/18.
//  Copyright © 2017年 com.shenma. All rights reserved.
//

import Cocoa



/// TableView Cell
class MainTableCellView: NSTableCellView {

    @IBOutlet var lightImageView: NSImageView!
    @IBOutlet var teamTextFiled: NSTextField!
    @IBOutlet var anwserTextFiled: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

}

/// ClientAnwser
class ClientAnwser {
    var name: String?
    var anwser: String = "−"
    var answerIdx: Int = -1
    var isRight = false
}



/// MainViewController
class ChongdingViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var totalTextFiled: NSTextField!
    @IBOutlet var usedTextFiled: NSTextField!
    @IBOutlet var remainingTextFiled: NSTextField!
    @IBOutlet var currentTextFiled: NSTextField!
    @IBOutlet var playerTextFiled: NSTextField!
    @IBOutlet var onlineTextFiled: NSTextField!
    @IBOutlet var startButton: NSButton!

    private var _timer: Timer?

    private var _fullQuestionSet = Set<Question>()
    private var _usedQuestionSet = Set<Question>()
    private var _usedQuestionList = Array<Question>()
    private var _clientAnwserList = Array<[ClientAnwser]>()

    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()

        loadQuestions()
        reisterNotification()

        ClientManager.shared.delegate = self
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destinationController = segue.destinationController

        if let destinationController = destinationController as? QuestionViewController {
            destinationController.question = sender as? Question
        } else if let destinationController = destinationController as? CongratulationViewController {

            if let winer = sender as? SocketClient {
                destinationController.name = winer.name!
                destinationController.count = _clientAnwserList.count
            }
        }
    }
}


// MARK: - Function
extension ChongdingViewController {

    /// 向所有客户端推送新问题
    func sendNewQuestionsToAllClient() {

        guard let newQuestion = getNewQuestion() else {
            return
        }

        //Question@1.我国唯一的两个皇帝合葬在一起的是唐高宗跟?唐高祖,唐太宗,武则天
        let string = "Question@" + "\(_usedQuestionList.count + 1).  " + newQuestion.stringValue()
        if ClientManager.shared.sendToAllOnlineClient(string) {
            _usedQuestionSet.insert(newQuestion)
            _usedQuestionList.append(newQuestion)
            refreshQuestionCountingLabel()
            showQuestionView(newQuestion)
            prepareAnwserAndWaitingAnwser()
        }
    }

    /// 向所有客户端推送答案
    func sendQuestionAnwserToAllClient() {

        let question = _usedQuestionList.last!
        let anwsers = _clientAnwserList.last!

        //统计答对人数
        var rightAnwserCount = 0
        var anwser0Count = 0
        var anwser1Count = 0
        var anwser2Count = 0

        for anwser in anwsers {
            switch anwser.answerIdx {
            case 0: anwser0Count = anwser0Count + 1
            case 1: anwser1Count = anwser1Count + 1
            case 2: anwser2Count = anwser2Count + 1
            default: break
            }

            if anwser.isRight == true {
                rightAnwserCount = rightAnwserCount + 1
            }
        }

        var winer: SocketClient?
        for anwser in anwsers {

            //更新客户端答案
            let client = ClientManager.shared.findClient(by: anwser.name!)
            let clientIsEliminatedNow = (client?.isEliminated)!

            if anwser.answerIdx >= 0 {
                client?.appendAnwser("\(anwser.answerIdx)")
            } else {
                client?.appendAnwser("−")
            }

            if anwser.isRight == true {
                winer = client
            } else {
                client?.isEliminated = true
            }

            if let client = client {
                //Anwser@1.我国唯一的两个皇帝合葬在一起的是唐高宗跟?唐高祖,唐太宗,武则天:武则天,客户端答案|2,1,3:0
                let string = String(format:"Anwser@%d.  %@,%@|%d,%d,%d:%d" ,
                                    _usedQuestionList.count,
                                    question.orginalString!,
                                    anwser.anwser,
                                    anwser0Count,
                                    anwser1Count,
                                    anwser2Count,
                                    clientIsEliminatedNow ? 0 : 1)//未淘汰则传1，淘汰传0
                let _ = ClientManager.shared.sendToClient(client, string)
            }
        }

        //小于等于一个玩家答对时结束
        if rightAnwserCount < anwsers.count && rightAnwserCount <= 1 {
            startButton?.title = "开始"
            stopSendingQuestionLoop()
            showCongratulationView(winer)
        }

        question.canShowAnwser = true
        clientUpdated()
    }

    /// 开始向客户端循环推送问题
    func startSendingQuestionLoop() {

        _timer?.invalidate()

        _clientAnwserList.removeAll()
        _usedQuestionList.removeAll()

        ClientManager.shared.markAllOnlineClientsAsUneliminated()
        clientUpdated()
        _timer = Timer(timeInterval: 30, repeats: true, block: { (timer) in
            self.sendNewQuestionsToAllClient()
        })
        RunLoop.current.add(_timer!, forMode: .commonModes)
        _timer?.fireDate = Date(timeIntervalSinceNow: 2)
        isPlaying = true
    }

    /// 停止向客户端循环推送问题
    func stopSendingQuestionLoop() {
        _timer?.invalidate()
        _timer = nil
        isPlaying = false
    }

    /// 准备答案和开始等待答案
    func prepareAnwserAndWaitingAnwser() {
        var anwsers = [ClientAnwser]()
        for client in ClientManager.shared.getAllOnlineClients() {
            let anwser = ClientAnwser()
            anwser.name = client.name

            anwsers.append(anwser)
        }
        _clientAnwserList.append(anwsers)

        //20秒钟时间等待客户端作答
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { (timer) in
            if self.isPlaying {
                self.sendQuestionAnwserToAllClient()
            }
        }
    }
}

// MARK: - Button Action
extension ChongdingViewController {

    @IBAction func onStartButtonClicked(_ sender: NSButton) {

        if sender.title == "开始" {
            //开始游戏
            sender.title = "暂停";
            startSendingQuestionLoop()
        } else {
            //暂停游戏
            sender.title = "开始";
            stopSendingQuestionLoop()
            ClientManager.shared.markAllOnlineClientsAsEliminated()
            clientUpdated()
        }
    }

    @IBAction func onClearOfflineClientsButtonClicked(_ sender: NSButton) {
        ClientManager.shared.removeAllOfflineClients()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.clientUpdated()
        }
    }
}

// MARK: - Data
extension ChongdingViewController {


    /// 加载问题
    func loadQuestions() {

        guard let path = Bundle.main.path(forResource: "questionList", ofType: nil) else {
            return
        }

        //黄聪-中国首都在哪里?北京,上海,深圳:北京;四川省会在哪里?成都,绵阳,资阳:成都;
        guard var string = try? String.init(contentsOfFile: path) else {
            return
        }

        //替换中文
        string = string.replacingOccurrences(of: "\n", with: "")
        string = string.replacingOccurrences(of: "——", with: "-")
        string = string.replacingOccurrences(of: "；", with: ";")
        string = string.replacingOccurrences(of: "？", with: "?")

        let authorAndQuestion = string.components(separatedBy: "-")

        //作者:黄聪
        let author = authorAndQuestion.first
        guard let _fullQuestionSetContent = authorAndQuestion.last else {
            return
        }

        //中国首都在哪里?北京,上海,深圳:北京;四川省会在哪里?成都,绵阳,资阳:成都;
        let questions = _fullQuestionSetContent.components(separatedBy: ";")
        for item in questions {

            if item.count > 1 {
                let question = Question(item)
                question.author = author
                _fullQuestionSet.insert(question)
            }
        }
        refreshQuestionCountingLabel()
    }

    /// 找到一个新的问题
    func getNewQuestion() -> Question? {
        let remaining = _fullQuestionSet.symmetricDifference(_usedQuestionSet)
        return remaining.first
    }
}

// MARK: - Refresh UI
extension ChongdingViewController {


    /// 刷新问题统计相关label
    func refreshQuestionCountingLabel() {
        totalTextFiled?.stringValue = "\(_fullQuestionSet.count)"
        usedTextFiled?.stringValue = "\(_usedQuestionSet.count)"
        remainingTextFiled?.stringValue = "\(_fullQuestionSet.count - _usedQuestionSet.count)"
        currentTextFiled?.stringValue = "\(_usedQuestionList.count)"
    }

    /// 刷新人数统计相关label
    func refreshPlayerCountingLabel() {
        playerTextFiled?.stringValue = "\(ClientManager.shared.registerClients.count)"
        onlineTextFiled?.stringValue = "\(ClientManager.shared.getAllOnlineClients().count)"
    }

    /// 显示问题预览界面
    func showQuestionView(_ question: Question) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("QuestionViewController"),
                          sender: question)
    }

    /// 显示恭喜界面
    func showCongratulationView(_ winer: SocketClient?) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("CongratulationViewController"),
                          sender: winer)
    }
}

// MARK: - TableView
extension ChongdingViewController: NSTableViewDataSource,NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        var count = ClientManager.shared.registerClients.count
        if count > 0 {
            count = count + 1
        }
        return count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let cell: MainTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier,
                                                         owner: self) as! MainTableCellView
        cell.lightImageView?.image = nil
        cell.teamTextFiled?.stringValue = ""

        let clientCount = ClientManager.shared.registerClients.count
        if row == clientCount {
            cell.lightImageView?.image = nil
            cell.teamTextFiled?.stringValue = "正确答案"

            let answers = _usedQuestionList.map({ (question) -> String in

                if !question.canShowAnwser {
                    return ""
                }
                return "\(question.solutions!.index(of: question.answer!)!)"
            })
            cell.anwserTextFiled?.stringValue = answers.joined(separator: "  |  ")
        } else if row < clientCount {

            let client = ClientManager.shared.registerClients[row]
            if client.isOnline {

                if client.isEliminated {
                    cell.lightImageView?.image = NSImage(named: NSImage.Name("icon_light_yellow"))
                } else {
                    cell.lightImageView?.image = NSImage(named: NSImage.Name("icon_light_green"))
                }
            } else {
                cell.lightImageView?.image = NSImage(named: NSImage.Name("icon_light_red"))
            }
            cell.teamTextFiled?.stringValue = client.name ?? ""
            cell.anwserTextFiled?.stringValue = client.anwserString()
        }

        return cell;
    }
}


// MARK: - ClientManagerClientUpdatedDelegate
extension ChongdingViewController: ClientManagerClientUpdatedDelegate {

    func clientUpdated() {
        self.tableView?.reloadData()
        self.refreshPlayerCountingLabel()
    }
}

// MARK: - Notification
extension ChongdingViewController {

    func reisterNotification() {
        //接收到客户端发送的数据
        let dataNotificationName = SocketConnectorNotification.didReceiveDataStringNotification.rawValue
        NotificationCenter.default.addObserver(forName: NSNotification.Name(dataNotificationName),
                                       object: SocketConnector.shared,
                                       queue: OperationQueue.main)
        { (notification) in
            
            guard let userInfo = notification.userInfo as? [String: Any] else {
                return
            }

            guard let question = self._usedQuestionList.last else {
                return
            }

            let name = userInfo[SocketNotificationUserInfoKey.userNameKey.rawValue] as! String
            let dataStr = userInfo[SocketNotificationUserInfoKey.dataStringKey.rawValue] as! String

            if let client = ClientManager.shared.findClient(by: name) {
                if client.isEliminated == false {
                    //只有未淘汰的用户才能更新答案列表
                    for item in self._clientAnwserList.last! {
                        if item.name == name {
                            item.isRight = (question.answer == dataStr)
                            item.anwser = dataStr
                            item.answerIdx = (question.solutions?.index(of: dataStr))!
                        }
                    }
                }
            }
        }
    }
}
