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
    var boardID = Int16()

    //Board data
    var boardScreenShot = UIImage()
    var boardAlert = Bool()
    var boardPrivacy = Bool()
    var boardLat = Double()
    var boardLon = Double()
    var boardCreatetime = NSDate()
    var boardTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndPop))
   //     self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
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
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
        
    }
    // MARK: Btn method
    
    func saveAndPop() {
        self.saveBoardData()
        self.saveNoteData()
        NotificationCenter.default.post(name: resetNote, object: nil, userInfo: nil)
        tabBarController?.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
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
             let noteImage = allNoteData["noteImage"] as? [UIImage],
            let noteSelfie = UIImagePNGRepresentation(resizeNote) as NSData?
            else {
                print("Case failure!!!!!!!!")
                return
        }
        guard let imageJson = noteDataManager.transformImageTOJson(images: noteImage) else{
            print("imageJson transform failure!!!!")
            return
        }

        print("---------\(imageJson)-------------")
        
        
        guard let album = noteDataManager.transformDataToImage(imageJSONData: imageJson) else{
            print("Get image failure!")
            return
        }
        
        
        
        
        for (index,image) in album.enumerated(){
            
            let x = (self.view.frame.size.width)*CGFloat(index)/CGFloat(album.count)
            let y = (self.view.frame.size.height)*CGFloat(index)/CGFloat(album.count)
            let w = self.view.frame.size.width/CGFloat(album.count)
            let h = self.view.frame.size.height/CGFloat(album.count)
            
            let imgView = UIImageView(image: image)
            imgView.frame = CGRect(x: x, y: y, width: w, height: h)
            self.view.addSubview(imgView)
            
        }
        
        noteItem.note_Content = noteContent
        noteItem.note_BgColor = noteBgColor
        noteItem.note_FontColor = noteFontColor
        noteItem.note_FontSize = noteFontSize
        noteItem.note_ID = 1
        noteItem.note_X = noteX
        noteItem.note_Y = noteY
        noteItem.note_Image = imageJson
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
            
            guard let boardBgPic = UIImageJPEGRepresentation(bgPic, 1.0) as NSData? ,
                let boardScreenShot = UIImageJPEGRepresentation(screenShotImage, 1.0) as NSData?
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
            let lastBoardItem = boardDataManager.itemWithIndex(index: 0)
            let boardItem = boardDataManager.createItem()

            boardItem.board_Id = lastBoardItem.board_Id + 1
            boardID = boardItem.board_Id
            
            guard let screenShotImage = self.view.boardScreenShot(),
                let bgPic = topImage.image
                else {
                    return
            }
            
            guard let boardBgPic = UIImageJPEGRepresentation(bgPic, 1.0) as NSData? ,
                let boardScreenShot = UIImageJPEGRepresentation(screenShotImage, 1.0) as NSData?
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
