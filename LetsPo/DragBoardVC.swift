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
    var allNoteData = [String:Any]()

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
        
        
        print(NoteImageView.frame.minX)
    }
    
    
    func saveNoteData() {
        let noteItem = noteDataManager.createItem()

        let postX = NoteImageView.frame.minX
        let postY = NoteImageView.frame.minY
        let noteX = Double(postX)
        let noteY = Double(postY)

        guard let noteContent = allNoteData["noteContent"] as? String?,
             let noteBgColor = allNoteData["noteBgColor"] as? NSData,
             let noteFontColor = allNoteData["noteFontColor"] as? NSData,
             let noteFontSize = allNoteData["noteFontSize"] as? Double
            else {
                print("Case failure!!!!!!!!")
                return
            }
        
        
        
        
        
        noteItem.note_Content = noteContent
        noteItem.note_BgColor = noteBgColor
        noteItem.note_FontColor = noteFontColor
        noteItem.note_FontSize = noteFontSize
        noteItem.note_X = noteX
        noteItem.note_Y = noteY
        
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
    
    
    
  }

    




