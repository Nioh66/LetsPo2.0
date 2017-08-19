//
//  PublicBoardSettingVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/2.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class PublicBoardSettingVC: UIViewController {
    
    
    @IBOutlet weak var boardPrivacyValue: UISwitch!
    @IBOutlet weak var boardAlertValue: UISwitch!
    @IBOutlet weak var deleteAllBtn: UIButton!
    
    var publicPostID = Int16()
    var boardID = Int16()
    var boardAlert = Bool()
    var boardPrivacy = Bool()
    var dataManagerCount = Int()
    
    let dismissSelf = Notification.Name("dismissSelf")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManagerCount = boardDataManager.count()
        
        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(boardID)") as! [BoardData]
        
        
        for data in oldBoardData{
            if data.board_Id == boardID{
                if (data.board_Alert) {
                    boardAlertValue.isOn = true
                }else{
                    boardAlertValue.isOn = false
                }
                if (data.board_Privacy) {
                    boardPrivacyValue.isOn = true
                }else{
                    boardPrivacyValue.isOn = false
                    
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func publicSwitchChangeValue(_ sender: UISwitch) {
        
        if sender.isOn {
            boardPrivacy = true
        }else{
            boardPrivacy = false
        }
        self.updateBoardData()
        print("ssssss")
    }
    
    @IBAction func noticeSwitchChangeValue(_ sender: UISwitch) {
        
        if sender.isOn {
            boardAlert = true
        }else{
            boardAlert = false
        }
        self.updateBoardData()
        print("ssssss")
    }
    @IBAction func deleteAllButtonPressed(_ sender: UIButton) {
        alertMakeSure()
    }
    
    func alertMakeSure(){
        let alert = UIAlertController(title: "資料將全部刪除", message: "如果不刪除請按取消按鈕", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let ok = UIAlertAction(title: "刪除", style: .default) { (action) in
            NotificationCenter.default.post(name: self.dismissSelf, object: nil)
            self.coreDataDeleteAndSaveMethod(board_id: "\(self.boardID)")
            self.dismiss(animated: false, completion: nil)
            
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    func updateBoardData() {
        
        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(boardID)") as! [BoardData]
        
        
        for data:BoardData in oldBoardData{
            if data.board_Id == boardID{
                data.board_Alert = boardAlert
                data.board_Privacy = boardPrivacy
                data.board_CreateTime = NSDate()
                
                boardDataManager.saveContexWithCompletion { (success) in
                    if (success) {
                        print("BoardData save succeed!!!")
                    }else{
                        print("BoardData save failure!!!")
                    }
                }
            }
        }
    }
    
    func coreDataDeleteAndSaveMethod(board_id:String){
        let searchField = "board_Id"
        let keyword = "\(board_id)"
        guard let result = boardDataManager.searchField(field: searchField, forKeyword: keyword) as? [BoardData] else{
            print("Result case to [NoteData] failure!!!!")
            return
        }
        for boardData:BoardData in result {
            let boardID = boardData.board_Id
            print("boardID \(boardID)")
            boardDataManager.deleteItem(item: boardData)
            boardDataManager.saveContexWithCompletion(completion: { (success) in
                let searchField = "note_BoardID"
                guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
                    print("Result case to [NoteData] failure!!!!")
                    return
                }
                for noteAttribute:NoteData in result{
                    let noteID = noteAttribute.note_ID
                    let boardID = noteAttribute.note_BoardID
                    var imageData:NSData? = nil
                    if let image = noteAttribute.note_Image {
                        imageData = image
                    }
                    
                    print("noteID \(noteID),boardID \(boardID)")
                    noteDataManager.deleteItem(item: noteAttribute)
                    noteDataManager.saveContexWithCompletion(completion: { (success) in
                        print("delete note with all image success")
                    })
                    if imageData != nil {
                        self.removeImageformDocument(items:imageData!)
                    }
                }
                self.dataManagerCount = boardDataManager.count()
                print("delete success")
            })
        }
    }
    
    func removeImageformDocument(items:NSData) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: items as Data),
            let myAlbum = json as? [String: Any] else{
                print("imageJSONData transform to result failure!!!!!")
                return
        }
        for index in 0 ..< myAlbum.count {
            guard let stringPath = myAlbum["Image\(index)"] as? String
                else {
                    print("------String transform to URL failure------")
                    return
            }
            let filePath = "\(dirPath)/\(stringPath)"
            do {
                try fileManager.removeItem(atPath: filePath)
                print("delete image OK")
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }
    
}
