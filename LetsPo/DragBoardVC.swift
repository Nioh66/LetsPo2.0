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
    //Board data
    var boardScreenShot = UIImage()
                                        // var boardID = Int()
    var boardAlert = Bool()
    var boardPrivacy = Bool()
    var boardLat = Double()
    var boardLon = Double()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        topImage.image = topBgImages
        
       
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
    @IBAction func finishBtn(_ sender: UIButton) {
        self.saveNoteData()
        self.saveBoardData()
        NotificationCenter.default.post(name: resetNote, object: nil, userInfo: nil)
            tabBarController?.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)

    }
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false

        navigationController?.popViewController(animated: true)

    }
    
    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: topImage)
        
        
        NoteImageView.center = point
        
    }
    
    // Save Data
    
    func saveNoteData() {
        let noteItem = noteDataManager.createItem()

        let postX = NoteImageView.frame.minX
        let postY = NoteImageView.frame.minY
        let noteX = Double(postX)
        let noteY = Double(postY)

        guard let noteContent = allNoteData["noteContent"] as? String?,
             let noteBgColor = allNoteData["noteBgColor"] as? NSData,
             let noteFontColor = allNoteData["noteFontColor"] as? NSData,
             let noteFontSize = allNoteData["noteFontSize"] as? Double,
             let noteImage = allNoteData["noteImage"] as? [UIImage]
            else {
                print("Case failure!!!!!!!!")
                return
        }
        let imageJson = noteDataManager.transformImageTOJson(images: noteImage)

        print("---------\(imageJson)")
        
        
        noteItem.note_Content = noteContent
        noteItem.note_BgColor = noteBgColor
        noteItem.note_FontColor = noteFontColor
        noteItem.note_FontSize = noteFontSize
        noteItem.note_X = noteX
        noteItem.note_Y = noteY
        noteItem.note_Image = imageJson
//        for image in imageForCell{
//            
//            let imageData = UIImagePNGRepresentation(image) as! NSData
//            noteItem.note_Image = imageData
//        }
//        
        
        noteDataManager.saveContexWithCompletion { (success) in
            if(success){
                print("Save note data success!!!!!")
            }else{
                print("Save note data failure!!!!!")
            }
        }
    }
    
    func saveBoardData() {
        let boardItem = boardDataManager.createItem()
        //BoardID set
        let itemCount = boardDataManager.count()
     
        let lastBoardItem = boardDataManager.itemWithIndex(index: itemCount - 1)
        if itemCount == 0{
            boardItem.board_Id = 1
        }else{
            boardItem.board_Id = lastBoardItem.board_Id + 1
        }
        
    //  boardItem.board_Creater = nil
   //     boardItem.board_Lat =
   //     boardItem.board_Lon =
        guard let screenshotimage = self.view.boardScreenShot(),
            let bgPic = topImage.image
        else {
            return
        }

        guard let boardBgPic = UIImageJPEGRepresentation(bgPic, 1.0) as NSData? ,
            let boardScreenShot = UIImageJPEGRepresentation(screenshotimage, 1.0) as NSData?
            else{
                return
        }
        
        boardItem.board_Alert = boardAlert
        boardItem.board_Privacy = boardPrivacy
        boardItem.board_ScreenShot = boardScreenShot
        boardItem.board_BgPic = boardBgPic
        boardItem.board_CreateTime = Date.init(timeIntervalSinceNow: 1) as NSDate
        boardDataManager.saveContexWithCompletion { (success) in
            if success {
                print("BoardData save succeed!!!")
            }else{
                print("BoardData save failure!!!")
            }
        }
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

    




