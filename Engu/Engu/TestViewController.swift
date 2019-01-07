//
//  TestViewController.swift
//  Engu
//
//  Created by Daeho on 27/11/2018.
//  Copyright © 2018 Daeho. All rights reserved.
//
import UIKit
import AVFoundation
//객관식을 랜덤으로 가져와서 문제를 푸는 방식
class TestViewController: UIViewController {
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var checkOneButton: UIButton!
    @IBOutlet weak var checkTwoButton: UIButton!
    @IBOutlet weak var checkThreeButton: UIButton!
    @IBOutlet weak var checkFourButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var correctLabel: UILabel!
    
    var initState : Bool!
    var correctCount : Int = 0
    var stageCount : Int = 0
    var quizStack = NSMutableArray()
    var suffleAry = NSArray()
    var currentQuizEnglish : String = ""
    //TTS
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        createQuizList()
        startInit()
    }
    func createQuizList() {
//        print(ViewController.dataModel.count)
        for elements in ViewController.dataModel {
            let stk = (((elements as! NSDictionary).value(forKey:"list") as! NSDictionary).value(forKey: "id") as? Int)!
            print(stk)
            quizStack.add(stk)
            suffleAry = (quizStack as NSArray?)!.shuffled() as NSArray
        }
    }
    func checkForTest(isCorrect: Int) {
        var titleString = ""
        var messageString = ""
        if isCorrect == 0 {
            titleString = "정답~!"
            messageString = "잘하셨어요 짝짝짝"
            self.correctCount = self.correctCount + 1
        }else {
            titleString = "오답~!"
            messageString = "다음에는 맞출수 있죠?"
        }
        let alertController = UIAlertController (title: titleString, message: messageString, preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "확인", style: .default, handler: { (action) in
            print(self.correctCount)
            self.actStart((Any).self)
        })
        alertController.addAction(uploadAction)
        present(alertController, animated: true, completion: nil)
    }
    func startInit() {
        checkOneButton.setTitle("", for: UIControl.State.normal)
        checkTwoButton.setTitle("", for: UIControl.State.normal)
        checkThreeButton.setTitle("", for: UIControl.State.normal)
        checkFourButton.setTitle("", for: UIControl.State.normal)
        correctLabel.text = "";
        nextButton.setTitle("시~~작!", for: UIControl.State.normal)
        initState = false
    }
    func speakEnglish(quizEnglish : String) {
        myUtterance = AVSpeechUtterance(string: quizEnglish)
        myUtterance.rate = 0.5
        myUtterance.preUtteranceDelay = 0.6
        myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
        synth.speak(myUtterance)
    }
    func setQuizRandomly(quizString: String, isCorrect : String, sequence: Int) {
        DispatchQueue.main.async {
            switch sequence {
            case 0:
                self.checkOneButton.setTitle(quizString, for: UIControl.State.normal)
                self.checkOneButton.tag = (isCorrect as NSString).integerValue
                //print((isCorrect as NSString).integerValue)
                break
            case 1:
                self.checkTwoButton.setTitle(quizString, for: UIControl.State.normal)
                self.checkTwoButton.tag = (isCorrect as NSString).integerValue
                //print((isCorrect as NSString).integerValue)
                break
            case 2:
                self.checkThreeButton.setTitle(quizString, for: UIControl.State.normal)
                self.checkThreeButton.tag = (isCorrect as NSString).integerValue
                //print((isCorrect as NSString).integerValue)
                break
            case 3:
                self.checkFourButton.setTitle(quizString, for: UIControl.State.normal)
                self.checkFourButton.tag = (isCorrect as NSString).integerValue
                //print((isCorrect as NSString).integerValue)
                break
            default:
                break
            }
        }
    }
    @IBAction func actStart(_ sender: Any) {
        
        //1.Plist에 저장된 id를 랜덤으로 돌려 문제 리스트를 구성한다.
        //2.구성된 문제리스트중 가장 앞의 문제를 서버와 통신하여 오답을 가져온다.
        //3.오답 정답 정보를 문제에 뿌린다.
        if (!initState){
            initState = true
            stageCount = 0
        }else {
            stageCount = stageCount + 1
        }
        DispatchQueue.main.async {
            self.nextButton.setTitle("다음문제", for: UIControl.State.normal)
            self.questionLabel.text = String.init(format: "STAGE : %d", self.stageCount)
            self.correctLabel.text = String.init(format: "( %d / %d )", self.correctCount, ViewController.dataModel.count)
        }
        if initState && (ViewController.dataModel.count > stageCount) {
            
            let TDataModel = TestDataModel()
            let sequenceAry : Array = [0, 1, 2, 3].shuffled()
            var sequence : Int = 0;
            TDataModel.getJsonData(stagecount: String(suffleAry[self.stageCount] as! Int) , completionHandler: {(json) -> Void in
                if json != nil {
                    if let json = json,
                        let _ = json["list"] as? NSArray {
                        print(json["list"] as? NSArray)
                    }
                    if json != nil {
                        if let json = json,
                            let list = json["list"] as? NSArray {
                            for data in list {
                                self.setQuizRandomly(quizString: (data as! NSDictionary).value(forKey: "korean") as! String, isCorrect: (data as! NSDictionary).value(forKey: "isCorrect") as! String, sequence: sequenceAry[sequence])
                                if ((data as! NSDictionary).value(forKey: "isCorrect") as! String == "0"){
                                    self.speakEnglish(quizEnglish: (data as! NSDictionary).value(forKey: "english") as! String)
                                    self.currentQuizEnglish = (data as! NSDictionary).value(forKey: "english") as! String
                                }
                                sequence = sequence + 1
                            }
                        }
                    }
                }
            })
        }else {
            print("더이상 진행 못함")
            initState = false
        }
       
    }
    
    @IBAction func actBackBtn(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actQuizOneBtn(_ sender: Any) {
        print((sender as AnyObject).tag!)
        checkForTest(isCorrect: (sender as AnyObject).tag!)
    }
    @IBAction func actQuizTwoBtn(_ sender: Any) {
        print((sender as! AnyObject).tag)
        checkForTest(isCorrect: (sender as AnyObject).tag!)
    }
    @IBAction func actQuizThreeBtn(_ sender: Any) {
        print((sender as! AnyObject).tag)
        checkForTest(isCorrect: (sender as AnyObject).tag!)
    }
    @IBAction func actQuizFourBtn(_ sender: Any) {
        print((sender as! AnyObject).tag)
        checkForTest(isCorrect: (sender as AnyObject).tag!)
    }
    
    
}
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
