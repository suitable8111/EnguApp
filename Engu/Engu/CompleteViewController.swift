//
//  CompleteViewController.swift
//  Engu
//
//  Created by Daeho on 2017. 2. 28..
//  Copyright © 2017년 Daeho. All rights reserved.
//

import UIKit
import AVFoundation

class CompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var mTableView: UITableView!
    //TTS
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mTableView.delegate = self
        mTableView.dataSource = self
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(completehandleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.mTableView.addGestureRecognizer(longPressGesture)
    }
    @objc func completehandleLongPress(longPressGesture:UILongPressGestureRecognizer) {
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
                ViewController.completeModel.removeObject(at: (indexPath?.row)!)
                let path = self.getFileName(fileName: "/CompleteModel.plist")
                ViewController.completeModel.write(toFile: path, atomically: true)
                self.mTableView.deleteRows(at: [indexPath!], with: .fade)
            })
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                print("Cancel")
            })
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ViewController.completeModel.count);
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        
        cell.completeEnglishLb.text = ((ViewController.completeModel.object(at: indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String
        cell.completeKoreanLb.text = ((ViewController.completeModel.object(at:  indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "korean") as? String
        cell.completeKnowCountLb.text = String.init(format: "안다고 넘긴 수 : %d", (((ViewController.completeModel.object(at:  indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "knowcount") as? Int)!)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(ViewController.completeModel.object(at: indexPath.row) as! NSDictionary)
        myUtterance = AVSpeechUtterance(string: (((ViewController.completeModel.object(at: indexPath.row) as! NSDictionary).value(forKey: "list") as! NSDictionary).value(forKey: "english") as? String)!)
        myUtterance.voice = AVSpeechSynthesisVoice.init(language: "en-us")
        myUtterance.rate = 0.5
        synth.speak(myUtterance)
    }
    private func getFileName(fileName:String) -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docPath = docsDir[0]
        let fullName = docPath.appending(fileName)
        return fullName
    }
}
