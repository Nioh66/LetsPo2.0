//
//  DragBoardVC.swift
//  LetsPo
//
//  Created by Pin Liao on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit

class DragBoardVC: UIViewController ,UINavigationControllerDelegate{
    
    //  @IBOutlet weak var boardBackgroundImage: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    //  let sendBgImageNN = Notification.Name("sendBgImage")
    var topBgImages:UIImage?
    
    @IBOutlet weak var topImage: UIImageView!
    var thePost:Note!
    var postIt = Note()
    var resizeNote:UIImage!
    var NoteImageView = UIImageView()
    var posterX:CGFloat = 150
    var posterY:CGFloat = 150
    let posterEdge:CGFloat = 100
    let resetNote = Notification.Name("resetNote")
    //Note data
    var allNoteData = [String:Any]()
    var boardID = Int16()
    var noteX = Double()
    var noteY = Double()
    
    //Board data
    var boardScreenShot = UIImage()
    var boardAlert = Bool()
    var boardPrivacy = Bool()
    var boardLat = Double()
    var boardLon = Double()
    var boardCreatetime = NSDate()
    var boardTitle = ""
    var guideView = UIImageView()
    
    //upload
    let uploadMachine = AlamoMachine()
    var uploadBoardScreenShot = UIImage()
    var member_ID:Int? = nil
    let advanceImageView = AdvanceImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let guide = #imageLiteral(resourceName: "guide")
        guideView = UIImageView(image: guide)
        guideView.frame = CGRect(x: 50,
                                 y: 60,
                                 width: 50,
                                 height: 50)
        
        NoteImageView.addSubview(guideView)
        
        topImage.image = topBgImages
        topImage.isUserInteractionEnabled = true
        
        NoteImageView.frame = CGRect(x: posterX,
                                     y: posterY,
                                     width: posterEdge,
                                     height: posterEdge)
        NoteImageView.image = resizeNote
        print(resizeNote)
        print(NoteImageView.frame)
        topImage.addSubview(NoteImageView)
        
        NoteImageView.isUserInteractionEnabled = true
        NoteImageView.isMultipleTouchEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        NoteImageView.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tabBarController?.tabBar.isHidden = true
        
    }
    // MARK: Btn method
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        backBtn.isHidden = true
        saveBtn.isHidden = true
        guideView.removeFromSuperview()
        self.saveBoardData()
        self.saveNoteData()
        member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
        
        if(member_ID != 0){
        self.uploadBoard()
       // self.uploadNote()
        }
        
        NotificationCenter.default.post(name: resetNote, object: nil, userInfo: nil)
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: topImage)
        
        
        NoteImageView.center = point
        
    }
    // MARK: Upload to server
    
    func uploadBoard() {
        advanceImageView.prepareIndicatorView(view: self.view)
        let boardBg = topImage.image
        

        guard let screenShotImage = self.view.boardScreenShot(),
            let boardScreenShotData = UIImageJPEGRepresentation(screenShotImage, 0.8),
            let boardBgPicData = UIImageJPEGRepresentation(boardBg!, 0.8)
            else{
                return
        }
        let boardBgPic = boardBgPicData.base64EncodedString()
        let boardScreenShot = boardScreenShotData.base64EncodedString()
        
        let registDic:[String:Any] = ["Board_Title":boardTitle,
                                      "Board_Lat":boardLat,
                                      "Board_Lon":boardLon,
                                      "Board_Alert":boardAlert,
                                      "Board_BgPic":boardBgPic,
                                      "Board_ScreenShot":boardScreenShot,
                                      "Board_CreateMemberID":member_ID!,
                                      "Board_Privacy":boardPrivacy]
        uploadMachine.doPostJobWith(urlString: uploadMachine.SAVE_BOARD, parameter: registDic) { (error, response) in
            if error != nil{
                self.advanceImageView.advanceStop(view: self.view)
                print(error!)
            }
            print("Upload board complete!")
            self.uploadNote()
        }
    }
    
    
    
    func uploadNote() {
        
        
        
        guard let noteContent = allNoteData["noteContent"] as? String?,
            let noteBgColor = allNoteData["noteBgColor"] as? Data,
            let noteFontColor = allNoteData["noteFontColor"] as? Data,
            let noteFontSize = allNoteData["noteFontSize"] as? Double,
            let noteImage = allNoteData["noteImage"] as? [UIImage],
            let noteSelfie = UIImagePNGRepresentation(resizeNote)
            else {
                print("Case failure!!!!!!!!")
                return
        }
        var imageArray:[String]?
        
        if noteImage.count>=1{
            imageArray = [String]()
            for image in noteImage{
                
                let imageData = UIImageJPEGRepresentation(image,0.8)
                if let imageStr = imageData?.base64EncodedString(options:.lineLength64Characters){
                    imageArray?.append(imageStr)
                    
                }
            }
            
        }
        let noteSelfie64 = noteSelfie.base64EncodedString()
        let noteBgColor64 = noteBgColor.base64EncodedString()
        let noteFontColor64 = noteFontColor.base64EncodedString()
        
        
        
        
        
        let registDic:[String:Any?] = ["Note_Content":noteContent,
                                       "Note_FontColor":noteFontColor64,
                                       "Note_FontSize":noteFontSize,
                                       "Note_BgColor":noteBgColor64,
                                       "Note_Selfie":noteSelfie64,
                                       "Note_X":noteX,
                                       "Note_Y":noteY,
                                       "Board_CreateMemberID":member_ID!,
                                       "Board_Lat":boardLat,
                                       "Board_Lon":boardLon,
                                       "Note_Image":imageArray]
        
        uploadMachine.doPostJobWith(urlString: uploadMachine.SAVE_NOTE, parameter: registDic) { (error, response) in
            if error != nil{
                self.advanceImageView.advanceStop(view: self.view)
                print(error!)
            }
            self.advanceImageView.advanceStop(view: self.view)
            print("Upload note complete!")

        }
    }
    
    
    // MARK: Save Data
    
    func saveNoteData() {
        let noteItem = noteDataManager.createItem()
        
        let postX = NoteImageView.frame.minX
        let postY = NoteImageView.frame.minY
        noteX = Double(postX)
        noteY = Double(postY)
        
        guard let noteContent = allNoteData["noteContent"] as? String?,
            let noteBgColor = allNoteData["noteBgColor"] as? NSData,
            let noteFontColor = allNoteData["noteFontColor"] as? NSData,
            let noteFontSize = allNoteData["noteFontSize"] as? Double,
            let noteImage = allNoteData["noteImage"] as? [UIImage],
            let noteSelfie = UIImagePNGRepresentation(resizeNote) as NSData?
            else {
                print("Case failure!!!!!!!!")
                return
        }
        if noteImage.count>=1{
            
            guard let imageJson = noteDataManager.transformImageTOJson(images: noteImage) else{
                print("imageJson transform failure!!!!")
                return
            }
            noteItem.note_Image = imageJson
        }
        
        noteItem.note_Content = noteContent
        noteItem.note_BgColor = noteBgColor
        noteItem.note_FontColor = noteFontColor
        noteItem.note_FontSize = noteFontSize
        noteItem.note_ID = 1
        noteItem.note_X = noteX
        noteItem.note_Y = noteY
        noteItem.note_Selfie = noteSelfie
        noteItem.note_BoardID = boardID
        
        noteDataManager.saveContexWithCompletion { (success) in
            if(success){
                print("Save note data success!!!!!")
            }else{
                print("Save note data failure!!!!!")
            }
        }
    }
    
    func saveBoardData() {
        //BoardID set
        let itemCount = boardDataManager.count()
        
        if itemCount == 0{
            let boardItem = boardDataManager.createItem()
            
            boardItem.board_Id = 1
            boardID = 1
            
            guard let screenShotImage = self.view.boardScreenShot(),
                let bgPic = topImage.image
                else {
                    return
            }
            //For board upload
            uploadBoardScreenShot = screenShotImage
            
            guard let boardBgPic = UIImageJPEGRepresentation(bgPic, 0.8) as NSData? ,
                let boardScreenShot = UIImageJPEGRepresentation(screenShotImage, 0.8) as NSData?
                else{
                    return
            }
            
            boardItem.board_Lat = boardLat
            boardItem.board_Lon = boardLon
            boardItem.board_Alert = boardAlert
            boardItem.board_Privacy = boardPrivacy
            boardItem.board_ScreenShot = boardScreenShot
            boardItem.board_BgPic = boardBgPic
            boardItem.board_CreateTime = boardCreatetime
            boardItem.board_Title = boardTitle
            boardDataManager.saveContexWithCompletion { (success) in
                if (success) {
                    print("BoardData save succeed!!!")
                }else{
                    print("BoardData save failure!!!")
                }
            }
            
        }else{
            var idArray = [Int16]()
            for i in 0 ..< boardDataManager.count() {
                let lastBoardItem = boardDataManager.itemWithIndex(index: i)
                let id = lastBoardItem.board_Id
                idArray.append(id)
                
            }
            idArray.sort { $0 > $1 }
            
            let boardItem = boardDataManager.createItem()
            let lastID = idArray[0]
            
            boardItem.board_Id = lastID + 1
            print("boardItem.board_Id \(boardItem.board_Id)")
            boardID = boardItem.board_Id
            
            guard let screenShotImage = self.view.boardScreenShot(),
                let bgPic = topImage.image
                else {
                    return
            }
            
            guard let boardBgPic = UIImageJPEGRepresentation(bgPic, 0.8) as NSData? ,
                let boardScreenShot = UIImageJPEGRepresentation(screenShotImage, 0.8) as NSData?
                else{
                    return
            }
            
            boardItem.board_Lat = boardLat
            boardItem.board_Lon = boardLon
            boardItem.board_Alert = boardAlert
            boardItem.board_Privacy = boardPrivacy
            boardItem.board_ScreenShot = boardScreenShot
            boardItem.board_BgPic = boardBgPic
            boardItem.board_CreateTime = NSDate()
            boardItem.board_Title = boardTitle
            boardDataManager.saveContexWithCompletion { (success) in
                if (success) {
                    print("BoardData save succeed!!!")
                }else{
                    print("BoardData save failure!!!")
                }
            }
            
        }
        
        //  boardItem.board_Creater = nil
        
    }
    func transformDateTimeZone() -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = NSDate()
        let stringOfDate = dateFormate.string(from: date as Date)
        
        print("stringOfDate \(stringOfDate)")
        return stringOfDate
    }
    
}
