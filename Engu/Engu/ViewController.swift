//
//  ViewController.swift
//  Engu
//
//  Created by Daeho on 2017. 2. 21..
//  Copyright © 2017년 Daeho. All rights reserved.
//
// 이 프로젝트는 제가 영어공부를 하기위해 만든 앱입니다..

import UIKit
import AVFoundation
class ViewController: UIViewController {

    
    //TTS
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var editViewController: EditViewController!
    private var completeViewController : CompleteViewController!
    
    static var dataModel = NSMutableArray()
    static var completeModel = NSMutableArray()
    
    var startTrigger = true
    var randomNum = 0
    var unknowTrigger = true
    var onSideView = false
    var onDelay = true
    
    @IBOutlet weak var EnguLabel: UILabel!
    @IBOutlet weak var construeLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var construeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var sideView: UIView!
    
    @IBOutlet weak var practiceBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentOffset = CGPoint(x: self.view.frame.width, y: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        self.EnguLabel.text = "잉구"
        self.construeLabel.text = ""
        self.nextBtn.setTitle("시작!", for: UIControl.State.normal)
        self.construeBtn.setTitle("", for: UIControl.State.normal)
        self.confirmBtn.setTitle("", for: UIControl.State.normal)
        self.practiceBtn.setTitle("연습하기!", for: UIControl.State.normal)
        
        randomNum = 0
        startTrigger = true
        unknowTrigger = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let path = getFileName(fileName: "/DataModel.plist")
        let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: path)){
            let orgPath = Bundle.main.path(forResource: "DataModel", ofType: "plist")
            do {
                try fileManager.copyItem(atPath: orgPath!, toPath: path)
            } catch _ {
                
            }
        }
        ViewController.dataModel = NSMutableArray(contentsOfFile: path)!
        
        let completepath = getFileName(fileName: "/CompleteModel.plist")
        let completefileManager = FileManager.default
        if(!completefileManager.fileExists(atPath: completepath)){
            let orgPath = Bundle.main.path(forResource: "CompleteModel", ofType: "plist")
            do {
                try completefileManager.copyItem(atPath: orgPath!, toPath: completepath)
            } catch _ {
                
            }
        }
        ViewController.completeModel = NSMutableArray(contentsOfFile: completepath)!
        
        if (ViewController.dataModel.count) < 5 {
            print("어라 데이터가 없군요!")
            addSelect()
        }else {
            //START GAME EnguTest
            editViewController.loadEditView()
            
        }
        if (ViewController.completeModel.count) != 0  {
            //START GAME EnguTest
            self.completeViewController.mTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditViewController, segue.identifier == "editVC" {
            self.editViewController = vc
        }else if let vc = segue.destination as? CompleteViewController, segue.identifier == "completeVC" {
            self.completeViewController = vc
        }
    }

    //Plist 경로 들고오기
    private func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending(fileName)
        return fullName
    }
        @IBAction func addContext(_ sender: Any) {
        
    }
    @IBAction func actConfirm(_ sender: Any) {
        //진짜 외웠음!
        if startTrigger == false {
            successAlert()
        }
    }
    @IBAction func actConstrue(_ sender: Any) {
        //몰라요..
        unknowTrigger = true
        
        if startTrigger == false {
            myUtterance = AVSpeechUtterance(string: (((ViewController.dataModel.object(at: randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String)!)
            myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
            myUtterance.rate = 0.5
            synth.speak(myUtterance)
            self.construeLabel.text = ((ViewController.dataModel.object(at: randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String
            self.construeBtn.setTitle("다시듣기", for: UIControl.State.normal)
            self.nextBtn.setTitle("에휴.. 그거였구나", for: UIControl.State.normal)
        }
        
    }
    @IBAction func actNext(_ sender: Any) {
        if onDelay {
            onDelay = false
            if (ViewController.dataModel.count) > 5 {
                //다음!
                if unknowTrigger == false && startTrigger == false {
                    //알때! 카운트 증가
                    
                    myUtterance = AVSpeechUtterance(string: (((ViewController.dataModel.object(at: randomNum) as! NSDictionary).value(forKey:"list") as! NSDictionary).value(forKey: "english") as? String)!)
                    myUtterance.rate = 0.5
                    myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
                    synth.speak(myUtterance)
                    
                    print((((ViewController.dataModel.object(at: randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "knowcount") as? Int)!)
                    ((ViewController.dataModel.object(at: randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).setValue((((ViewController.dataModel.object(at: randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "knowcount") as? Int)! + 1, forKey: "knowcount")
                    let path = getFileName(fileName: "/DataModel.plist")
                    ViewController.dataModel.write(toFile: path, atomically: true)
                    self.construeLabel.text = String.init(format: "잘했어요!! +1 (%d)", (((ViewController.dataModel.object(at: self.randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "knowcount") as? Int)!)
                    self.construeLabel.font.withSize(25)
                    
                }
                self.nextBtn.setTitle("알아요", for: UIControl.State.normal)
                if startTrigger == true {
                    startTrigger = false
                }
                if unknowTrigger == true {
                    unknowTrigger = false
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    
                    self.generateRandomNum()
                    self.nextBtn.setTitle("알아요", for: UIControl.State.normal)
                    self.EnguLabel.text = ((ViewController.dataModel.object(at: self.randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "korean") as? String
                    self.construeLabel.text = String.init(format: "안다고 넘긴 수 : %d", (((ViewController.dataModel.object(at: self.randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "knowcount") as? Int)!)
                    self.construeLabel.font.withSize(19)
                    self.construeBtn.setTitle("모르겠어요", for: UIControl.State.normal)
                    self.confirmBtn.setTitle("이건 완벽하게 외웠어요", for: UIControl.State.normal)
                    self.editViewController.loadEditView()
                    self.onDelay = true
                })
                }
            }else {
                addSelect()
            }
        }
    }
    func generateRandomNum() {
        let num = Int(arc4random_uniform(UInt32(UInt(((ViewController.dataModel.count)-1)))) + 1)
        
        if (((ViewController.dataModel.object(at: num) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "isDone") as? Bool)! {
            print(num,"발견")
            generateRandomNum()
        }else {
            self.randomNum = num
        }
    }
    func successAlert() {
        let alertController = UIAlertController (title: "와우!", message: "이 문장을 명예의 문장으로 옮길까요? 아님 삭제할까요?", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "올림", style: .default, handler: { (action) in
            print("upload complete")
            
            (((ViewController.dataModel.object(at: self.randomNum) as! NSDictionary).value(forKey: "list") as! NSDictionary).setValue(true, forKey: "isDone"))
            var path = self.getFileName(fileName: "/DataModel.plist")
            ViewController.dataModel.write(toFile: path, atomically: true)
            
            ViewController.completeModel.insert((ViewController.dataModel.object(at: self.randomNum) as! NSDictionary), at: 0)
            path = self.getFileName(fileName: "/CompleteModel.plist")
            ViewController.completeModel.write(toFile: path, atomically: true)
            self.completeViewController.mTableView.reloadData()
            
            self.actNext(self)
        })
        let deleteAction = UIAlertAction(title: "삭제", style: .cancel, handler: { (action) in
            print("delete complete")
            self.actNext(self)
        })
        alertController.addAction(uploadAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func actPratice(_ sender: Any) {
        self.EnguLabel.text = "잉구"
        self.construeLabel.text = ""
        self.nextBtn.setTitle("시작!", for: UIControl.State.normal)
        self.construeBtn.setTitle("", for: UIControl.State.normal)
        self.confirmBtn.setTitle("", for: UIControl.State.normal)
        self.practiceBtn.setTitle("연습하기!", for: UIControl.State.normal)
        
        randomNum = 0
        startTrigger = true
        unknowTrigger = false
    }
    func addSelect() {
        let alertController = UIAlertController (title: "에러", message: "문장이 부족해요... 서버로 부터 랜덤의 문장들을 받아올까요??", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "네", style: .default, handler: { (action) in
            print("downLoad complete")
            
            DataModel().getJsonData(completionHandler: {(json) -> Void in
                if json != nil {
                    if json != nil {
                        if let json = json,
                            let list = json["list"] as? NSArray {
                            for data in list {
                                    //print((data as! NSDictionary).value(forKey: "korean") as! String)
                                let primedic = NSMutableDictionary()
                                let dataDic = NSMutableDictionary()


                                dataDic.setValue(((data as! NSDictionary).value(forKey: "english") as! String).replacingOccurrences(of: "´", with: "'"), forKey: "english")
                                dataDic.setValue((data as! NSDictionary).value(forKey: "korean") as! String, forKey: "korean")
                                dataDic.setValue(0, forKey: "knowcount")
                                dataDic.setValue((data as! NSDictionary).value(forKey: "level") as! String, forKey: "level")
                                dataDic.setValue((data as! NSDictionary).value(forKey: "updatetime") as! String, forKey: "updatetime")
                                dataDic.setValue((data as! NSDictionary).value(forKey: "id") as! Int, forKey: "id")
                                dataDic.setValue(false, forKey: "isDone")

                                primedic.setValue((data as! NSDictionary).value(forKey: "id") as! Int, forKey: "id")
                                primedic.setValue(dataDic, forKey: "list")
                                //
                                ViewController.dataModel.insert(primedic, at: 0)
                            }
                            //중복처리....
                            let set = NSSet(array: ViewController.dataModel.copy() as! [NSMutableDictionary])

                            print(ViewController.dataModel.count)
                            ViewController.dataModel.removeAllObjects()
                            ViewController.dataModel.addObjects(from: set.allObjects)

                            print(ViewController.dataModel.count)
                            print(set.allObjects.count)
                            let path = self.getFileName(fileName: "/DataModel.plist")
                            ViewController.dataModel.write(toFile: path, atomically: true)
                            self.editViewController.loadEditView()
                        }
                    }
                }
            })
        })
        let deleteAction = UIAlertAction(title: "아니요", style: .cancel, handler: { (action) in
            print("Cancel")
        })
        alertController.addAction(uploadAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

