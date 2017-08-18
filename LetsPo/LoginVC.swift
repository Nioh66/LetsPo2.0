//
//  LoginVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/10.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var registBtn: UIButton!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var accountLabel: UITextField!
    
    let alamoMachine = AlamoMachine()
    var boardIDCounter = Int()
    var reUpdate = NSLock()
    var shouldReUpdate = Bool()
    var boardIDs = Int16()
    var boardcount:Int16 = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
        if memberDataManager.count() > 0 {
            registBtn.isHidden = true
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tap)
        
    }
    func hideKeyboard(tapG:UITapGestureRecognizer){
        
        passwordLabel.resignFirstResponder()
        accountLabel.resignFirstResponder()
        
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        let verification = ["Account":accountLabel.text,
                            "Password":passwordLabel.text]
        alamoMachine.doPostJobWith(urlString: alamoMachine.LOGIN, parameter: verification) { (error, response) in
            if error != nil {
                print(error!)
            }
            else{
                guard let rsp = response else{
                    return
                }
                let result = rsp["result"] as! Bool
                if result {
                    self.saveToCoreData(data: rsp)
                }
                else{
                    let errorResult = rsp["errorCode"] as! String
                    self.vertificateAlert(errorCode: errorResult)
                    print(errorResult)
                }
            }
            
        }
        // 上資料庫去驗證
        navigationController?.popViewController(animated: true)
    }
    
    func saveToCoreData(data:[String:Any]) {
        //     print("\(data)")
        
        guard let memberID = data["Member_ID"] as?  String,
            let memberName = data["Member_Name"] as? String,
            let memberPassword = data["Member_Password"] as? String,
            let memberEmail = data["Member_Email"]  as? String,
            let memberIDInt64 = Int64(memberID)
            else{
                return
        }
        let memberItem = memberDataManager.createItem()
        
        
        let memberSelfieDataString = data["Member_Selfie"] as? String
        if memberSelfieDataString != nil{
            let memberSelfie = NSData(base64Encoded: memberSelfieDataString!, options: [])
            memberItem.member_Selfie = memberSelfie
        }
        memberItem.member_ID = memberIDInt64
        memberItem.member_Name = memberName
        memberItem.member_Password = memberPassword
        memberItem.member_Email = memberEmail
        UserDefaults.standard.set(memberIDInt64, forKey: "Member_ID")
        
        memberDataManager.saveContexWithCompletion { (success) in
            if(success){
                print("Save member data success!!!!!")
                self.downloadAllData(memberID: memberIDInt64)
            }else{
                print("Save member data failure!!!!!")
            }
        }
    }
    
    func downloadAllData(memberID:Int64) {
        
        
        let memberDic:[String:Any?] = ["Member_ID":memberID]
        
        alamoMachine.doPostJobWith(urlString: alamoMachine.DOWNLOAD_ALL, parameter: memberDic) { (error, rsp) in
            if error != nil{
                print(error!)
            }
            else{
                guard let response = rsp,
                    let resultBool = response["result"] as? Bool else{
                        return
                }
                if resultBool {
                    //  Search BoardID
                    guard let allData = response["AllData"] as? [String:Any] else{
                        print("Case from download JSON failure!!!!!")
                        return
                    }
                    let count = boardDataManager.count()
                    if count == 0{
                        self.boardIDs = 0
                    }else{
                        let lastID = boardDataManager.itemWithIndex(index: 0)
                        self.boardIDs = lastID.board_Id
                    }

                    
                    
                    for (_,values) in allData{
                        self.boardcount += 1
                        
                        guard let board = values as? [String:Any],
                            let boardData = board["BoardData"] as? [String:Any?] else{
                                print("Case from allData failure!!!!!")
                                return
                        }
                        
                        guard let boardTitle = boardData["Board_Title"] as? String,
                            let boardLatS = boardData["Board_Lat"] as? String,
                            let boardLonS = boardData["Board_Lon"] as? String,
                            let boardBgPicS = boardData["Board_BgPic"] as? String,
                            let boardAlertS = boardData["Board_Alert"] as? String,
                            let boardPrivacyS = boardData["Board_Privacy"] as? String,
                            let boardScreenShotS = boardData["Board_ScreenShot"] as? String,
                            let boardCreateTimeS = boardData["Board_CreateTime"] as? String else{
                                print("Case from boardData failure!!!!!")
                                return
                        }
                        //Adjust GMT0:00 time from server
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8:00")
                        let date = dateFormatter.date(from: boardCreateTimeS)
                        
                        guard let boardLat = Double(boardLatS),
                            let boardLon = Double(boardLonS),
                            let boardBgPic = NSData(base64Encoded: boardBgPicS, options: []),
                            let boardAlert = Int(boardAlertS),
                            let boardPrivacy = Int(boardPrivacyS),
                            let boardScreenShot = NSData(base64Encoded: boardScreenShotS, options: []),
                            let boardCreateTime = date as NSDate? else{
                                print("Case from String failure!!!!!")
                                return
                        }
                        
                        let boardItem = boardDataManager.createItem()
                        boardItem.board_Id = self.boardIDs + self.boardcount
                        boardItem.board_Title = boardTitle
                        boardItem.board_Lat = boardLat
                        boardItem.board_Lon = boardLon
                        boardItem.board_BgPic = boardBgPic
                        boardItem.board_Alert = Bool(boardAlert as NSNumber)
                        boardItem.board_Privacy = Bool(boardPrivacy as NSNumber)
                        boardItem.board_ScreenShot = boardScreenShot
                        boardItem.board_CreateTime = boardCreateTime
                        
                        
                        if let noteData = board["NoteData"] as? [String:Any]{
                            self.saveDownloadNoteData(boardID: boardItem.board_Id, noteDatas: noteData)
                        }
                        boardDataManager.saveContexWithCompletion(completion: { (success) in
                            if success {
                                print("Store boardData success!!!!!")
                            }
                            else{
                                print("Store boardData failure!!!!!")
                            }
                        })
                        
                        
                    }
                    
                }else{
                    print("No MemberID")
                }
            }
        }
        
    }
    func saveDownloadNoteData(boardID:Int16,noteDatas:[String:Any]) {
        
        var noteIDCount:Int16 = 0
        
        for i in 0..<noteDatas.count{

            guard let noteData = noteDatas["Note\(i)"] as? [String:Any?] else {
                return
            }
            
            guard let noteContent = noteData["Note_Content"] as? String,
                let noteFontColorS = noteData["Note_FontColor"] as? String,
                let noteFontSizeS = noteData["Note_FontSize"] as? String,
                let noteBgColorS = noteData["Note_BgColor"] as? String,
                let noteSelfieS = noteData["Note_Selfie"] as? String,
                let noteImageJSON = noteData["Note_Image"] as? String,
                let noteXS = noteData["Note_X"] as? String,
                let noteYS = noteData["Note_Y"] as? String else{
                    print("Case from noteData failure!!!!!")
                    return
            }
            
            guard let noteFontColor = NSData(base64Encoded: noteFontColorS, options: []),
                let noteFontSize = Double(noteFontSizeS),
                let noteBgColor = NSData(base64Encoded: noteBgColorS, options: []),
                let noteSelfie = NSData(base64Encoded: noteSelfieS, options: []),
                let noteX = Double(noteXS),
                let noteY = Double(noteYS) else{
                    print("Case from String failure!!!!!")
                    return
            }
            
           
           if noteImageJSON != ""{
            let noteImageJ = convertToDictionary(text: noteImageJSON)
            
            guard let noteImage = noteImageJ as? [String:String] else {
                return
            }
            
            alamoMachine.downloadImage(imageDic: noteImage, complete: { (error, rspImages) in
                if error != nil{
                    return
                }else{
                    guard let theImages = rspImages else{
                        return
                    }
                    
                    let noteItem = noteDataManager.createItem()
                    noteIDCount += 1

                    
                    let noteImageData = noteDataManager.transformImageTOJson(images: theImages)
                    
                    noteItem.note_Image = noteImageData
                    noteItem.note_ID = noteIDCount
                    noteItem.note_BoardID = boardID
                    noteItem.note_Content = noteContent
                    noteItem.note_FontColor = noteFontColor
                    noteItem.note_FontSize = noteFontSize
                    noteItem.note_BgColor = noteBgColor
                    noteItem.note_Selfie = noteSelfie
                    noteItem.note_X = noteX
                    noteItem.note_Y = noteY
                    
                    
                    noteDataManager.saveContexWithCompletion { (success) in
                        if success {
                            print("==================Note save success!!!!!!======================")
                            
                        }else{
                            print("Note save failure!!!!!!")
                        }
                    }
                    }})
                
            }else{
            let noteItem = noteDataManager.createItem()
            
            noteIDCount += 1

            noteItem.note_BoardID = boardID
            noteItem.note_ID = noteIDCount
            noteItem.note_Content = noteContent
            noteItem.note_FontColor = noteFontColor
            noteItem.note_FontSize = noteFontSize
            noteItem.note_BgColor = noteBgColor
            noteItem.note_Selfie = noteSelfie
            noteItem.note_X = noteX
            noteItem.note_Y = noteY
            
            
            noteDataManager.saveContexWithCompletion { (success) in
                if success {
                    print("=================Note save success!!!!!!======================")
                    
                }else{
                    print("Note save failure!!!!!!")
                }
            }

            }
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func vertificateAlert(errorCode:String) {
        let alert = UIAlertController.init(title: errorCode, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
}
