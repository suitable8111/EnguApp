//
//  PracticeViewController.swift
//  Engu
//
//  Created by Daeho on 2017. 3. 3..
//  Copyright © 2017년 Daeho. All rights reserved.
//

//PracticeView : 자신이 얼마나 외웠는지 시험을 치는 뷰
import UIKit
import AVFoundation

class PracticeViewController: UIViewController {
    
    @IBOutlet weak var englishLb: UILabel!  
    @IBOutlet weak var koreanLb: UILabel!
    
    @IBOutlet weak var totalLb: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var reloadBtn: UIButton!
    var startTrigger = true
    //TTS
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    var indexNum = -1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadBtn.setTitle("", for: UIControl.State.normal)
    }
    @IBAction func actReload(_ sender: Any) {
        myUtterance = AVSpeechUtterance(string: (((ViewController.dataModel.object(at: indexNum) as! NSDictionary).value(forKey:"list") as! NSDictionary).value(forKey: "english") as? String)!)
        myUtterance.rate = 0.5
        myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
        synth.speak(myUtterance)
    }
    @IBAction func actNext(_ sender: Any) {
        if startTrigger {
            self.nextBtn.setTitle("다음", for: UIControl.State.normal)
            self.reloadBtn.setTitle("다시듣기", for: UIControl.State.normal)
            startTrigger = false
        }
        if indexNum == ViewController.dataModel.count-1 {
            indexNum = 0
        }else {
            indexNum = indexNum + 1
        }
        totalLb.text = String.init(format: "( %d / %d )", indexNum+1, ViewController.dataModel.count)
        myUtterance = AVSpeechUtterance(string: (((ViewController.dataModel.object(at: indexNum) as! NSDictionary).value(forKey:"list") as! NSDictionary).value(forKey: "english") as? String)!)
        myUtterance.rate = 0.5
        myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
        synth.speak(myUtterance)
        self.englishLb.text = ((ViewController.dataModel.object(at: indexNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String
        self.koreanLb.text = ((ViewController.dataModel.object(at: self.indexNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "korean") as? String
    }
    @IBAction func actBack(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
