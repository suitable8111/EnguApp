//
//  EditViewController.swift
//  Engu
//
//  Created by Daeho on 2017. 2. 21..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit
import AVFoundation

class EditViewController : UIViewController, UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate , UIGestureRecognizerDelegate{
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var koreanTF: UITextField!
    @IBOutlet weak var englishTF: UITextField!
    
    //TTS
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var isUpdate : Bool = false
    var updateRow : Int = 0
    @IBOutlet weak var addBtn: UIButton!
    var onEditing: Bool = false
    //var dataModel:                  NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.koreanTF.returnKeyType = UIReturnKeyType.done
        self.englishTF.returnKeyType = UIReturnKeyType.done
        koreanTF.delegate = self
        englishTF.delegate = self
        mTableView.delegate = self
        mTableView.dataSource = self
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.mTableView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func handleLongPress(longPressGesture:UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.mTableView)
        let indexPath = self.mTableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on table view, not row.")
        }
        else if (longPressGesture.state == UIGestureRecognizer.State.began) {
            print("Long press on row, at \(indexPath!.row)")
            let alertController = UIAlertController (title: "열 선택", message: "해당 열을 삭제하시겠습니까?", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive, handler: { (action) in
                print("delete complete")
                ViewController.dataModel.removeObject(at: (indexPath?.row)!)
                let path = self.getFileName(fileName: "/DataModel.plist")
                ViewController.dataModel.write(toFile: path, atomically: true)
                self.mTableView.deleteRows(at: [indexPath!], with: .fade)
            })
            
            let updateAction = UIAlertAction(title: "수정하기", style: .default, handler: { (action) in
                print("수정")
                self.isUpdate = true
                self.updateRow = (indexPath?.row)!
                self.koreanTF.text = ((ViewController.dataModel.object(at: self.updateRow) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "korean") as? String
                self.englishTF.text = ((ViewController.dataModel.object(at: self.updateRow) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String
            })
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                print("Cancel")
            })
            alertController.addAction(deleteAction)
            alertController.addAction(updateAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
    
        }
    }
//    func loadEditView() {
//        if ViewController.dataModel.count == 0 {
//            print("어라 데이터가 없군요!")
//        }else {
//            //START GAME EnguTest
//            self.mTableView.reloadData()
//        }
//    }
    //Plist 경로 들고오기
    private func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending(fileName)
        return fullName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ViewController.dataModel.count);
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        
        cell.englishLb.text = ((ViewController.dataModel.object(at: indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String
        cell.koreanLb.text = ((ViewController.dataModel.object(at:  indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "korean") as? String
        cell.knowCountLb.text = String.init(format: "안다고 넘긴 수 : %d", (((ViewController.dataModel.object(at:  indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "knowcount") as? Int)!)
        //print((ViewController.dataModel.object(at: indexPath.row) as! NSDictionary).value(forKey: "isDone") as? Bool)
//        if (((ViewController.dataModel.object(at:  indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "isDone") as? Bool)! {
//            cell.isDoneView.backgroundColor = UIColor.blue
//        }        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myUtterance = AVSpeechUtterance(string: (((ViewController.dataModel.object(at: indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String)!)
        myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
        myUtterance.rate = 0.5
        synth.speak(myUtterance)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.englishTF.text != "" && self.koreanTF.text != "" {
            actAdd(self)
        }else {
            inputText()
        }
        return true
    }
    @IBAction func actReset(_ sender: Any) {
        resetAll()
    }
    @IBAction func actAdd(_ sender: Any) {
        if isUpdate {
            isUpdate = false
            
            let dic = NSMutableDictionary()
            let listDic = NSMutableDictionary()
            
            listDic.setValue(englishTF.text, forKey: "english")
            listDic.setValue(koreanTF.text, forKey: "korean")
            listDic.setValue(0, forKey: "knowcount")
            listDic.setValue("2", forKey: "level")
            listDic.setValue(DatetoString(date: Date()), forKey: "updatetime")
            
            dic.setValue("321321", forKey: "id")
            dic.setValue(listDic, forKey: "list")
            
            ViewController.dataModel.removeObject(at: self.updateRow)
            
            ViewController.dataModel.insert(dic, at: 0)
            let path = getFileName(fileName: "/DataModel.plist")
            ViewController.dataModel.write(toFile: path, atomically: true)
            mTableView.reloadData()
            self.koreanTF.text = ""
            self.englishTF.text = ""
            UIView.animate(withDuration: 0.5, animations: {
                self.addBtn.transform = CGAffineTransform(translationX: 0.0 , y: 0.0);
            }, completion: nil)
            
        }else {
            if koreanTF.text != "" || englishTF.text != "" {
                
                let dic = NSMutableDictionary()
                let listDic = NSMutableDictionary()
                
                listDic.setValue(englishTF.text, forKey: "english")
                listDic.setValue(koreanTF.text, forKey: "korean")
                listDic.setValue(0, forKey: "knowcount")
                listDic.setValue("2", forKey: "level")
                listDic.setValue(DatetoString(date: Date()), forKey: "updatetime")
                listDic.setValue(false, forKey: "isDone")
                
                dic.setValue("123123", forKey: "id")
                dic.setValue(listDic, forKey: "list")
                
                ViewController.dataModel.insert(dic, at: 0)
                let path = getFileName(fileName: "/DataModel.plist")
                ViewController.dataModel.write(toFile: path, atomically: true)
                mTableView.reloadData()
                koreanTF.text = ""
                englishTF.text = ""
                UIView.animate(withDuration: 0.5, animations: {
                    self.addBtn.transform = CGAffineTransform(translationX: 0.0 , y: 0.0);
                }, completion: nil)
                
            }else {
                addSelect()
            }
        }
    }
    func addSelect() {
        let alertController = UIAlertController (title: "추가하기", message: "서버로 부터 랜덤의 문장들을 받아올까요??", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "네", style: .default, handler: { (action) in
            print("downLoad complete")
            let dataModel = DataModel()
            dataModel.getJsonData(completionHandler: {(json) -> Void in
                if json != nil {
                    if let json = json,
                        let list = json["list"] as? NSArray {
                        print(json["list"] as? NSArray)
                    }
                    
                    if json != nil {
                        if let json = json,
                            let list = json["list"] as? NSArray {
                            for data in list {
                                print((data as! NSDictionary))
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
                            self.mTableView.reloadData()
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
    func resetAll() {
        let alertController = UIAlertController (title: "리셋", message: "데이터를 초기화 할까요? 모든 데이터는 지워집니다.", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "네", style: .default, handler: { (action) in
            print("delete complete")
            ViewController.dataModel.removeAllObjects()
            let path = self.getFileName(fileName: "/DataModel.plist")
            ViewController.dataModel.write(toFile: path, atomically: true)
            self.mTableView.reloadData()
        })
        let deleteAction = UIAlertAction(title: "아니요", style: .cancel, handler: { (action) in
            print("Cancel")
        })
        alertController.addAction(uploadAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    func inputText() {
        let alertController = UIAlertController (title: "데이터를 넣어주세요", message: "텍스트를 비우시면 아니되옵니다.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: { (action) in
            print("Cancel")
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    //MARK : TEXTVIEW DELEGAGTE
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.addBtn.transform = CGAffineTransform(translationX: 0.0 , y: -self.view.frame.height * 0.3);
        }, completion: nil)
        onEditing = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if onEditing {
            UIView.animate(withDuration: 0.5, animations: {
                self.addBtn.transform = CGAffineTransform(translationX: 0.0 , y: 0.0);
            }, completion: nil)
            onEditing = false
            self.view.endEditing(true)
        }
    }
    
    func DatetoString(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
