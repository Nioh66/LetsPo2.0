//
//  DragPublicPostVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/2.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class DragPublicPostVC: UIViewController {

    @IBOutlet weak var publicBgImage: UIImageView!
    
        var posterX:CGFloat = 150
        var posterY:CGFloat = 150
        let posterEdge:CGFloat = 100
        var bgImage = UIImage()
        var resizeNote:UIImage!
        var theDragNote = UIImageView()
        var allNoteData = [String:Any]()
        var boardID = Int16()
        var noteCount:Int16 = 0
        let newNoteComingNN = Notification.Name("newPublicNoteComing")
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            publicBgImage.image = bgImage
            
            theDragNote.frame = CGRect(x: posterX, y: posterY, width: posterEdge, height: posterEdge)
            theDragNote.image = resizeNote
            theDragNote.isUserInteractionEnabled = true
            
            publicBgImage.addSubview(theDragNote)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
            
            panGesture.maximumNumberOfTouches = 1
            panGesture.minimumNumberOfTouches = 1
            
            theDragNote.addGestureRecognizer(panGesture)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndPop))
            // Do any additional setup after loading the view.
        }
        
        func saveAndPop() {
            self.saveNoteData()
            self.uploadBoardBg()
            NotificationCenter.default.post(name: newNoteComingNN, object: nil)
            
            
        //    self.navigationController?.popToRootViewController(animated: true)
            for controller in (self.navigationController?.viewControllers)!
            {
                if controller.isKind(of: ManageDetailViewController.self) == true{
                    
                    self.dismiss(animated: false) {
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                    
                    break
                }
            }
    }
        
        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(false, animated: false)
            tabBarController?.tabBar.isHidden = true
            
        }
        
        
        func panTheNote(sender:UIPanGestureRecognizer) {
            
            let point = sender.location(in: publicBgImage)
            print(theDragNote.frame.minX)
            print(theDragNote.frame.minY)
            
            theDragNote.center = point
        }
    
    
    func uploadBoardBg() {
       guard let newBoardPic = self.view.boardScreenShot(),
        let newBoardBg = UIImageJPEGRepresentation(newBoardPic, 1.0) as NSData? else{
            return
        }
        
        
        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(boardID)") as! [BoardData]
        
        for data:BoardData in oldBoardData{
            if data.board_Id == boardID{
                data.board_CreateTime = NSDate()
                data.board_ScreenShot = newBoardBg
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
    
        
        func saveNoteData() {
            
            
            
            guard let allBoardsID = noteDataManager.searchField(field: "note_BoardID", forKeyword: "\(boardID)") as? [NoteData] else{
                return
            }
            
            for boardsID:NoteData in allBoardsID{
                if boardsID.note_BoardID == boardID {
                    noteCount += 1
                }
            }
            
            let item = noteDataManager.createItem()
            
            guard let noteContent = allNoteData["publicNoteContent"] as? String?,
                let noteBgColor = allNoteData["publicNoteBgColor"] as? NSData,
                let noteFontColor = allNoteData["publicNoteFontColor"] as? NSData,
                let noteFontSize = allNoteData["publicNoteFontSize"] as? Double,
                let noteImage = allNoteData["publicNoteImage"] as? [UIImage],
                let noteSelfie = UIImagePNGRepresentation(resizeNote!) as NSData?
                else {
                    print("Case failure!!!!!!!!")
                    return
            }
            guard let imageJson = noteDataManager.transformImageTOJson(images: noteImage) else{
                print("imageJson transform failure!!!!")
                return
            }
            
            print("---------\(imageJson)-------------")
            
            item.note_BoardID = boardID
            item.note_ID = noteCount + 1
            item.note_BgColor = noteBgColor
            item.note_Content = noteContent
            item.note_FontColor = noteFontColor
            item.note_FontSize = noteFontSize
            item.note_X = Double(theDragNote.frame.minX)
            item.note_Y = Double(theDragNote.frame.minY)
            item.note_Selfie = noteSelfie
            item.note_Image = imageJson
            
            print("noteID:-------\(item.note_ID)")
            
            noteDataManager.saveContexWithCompletion { (success) in
                if(success){
                    print("Save note data success!!!!!")
                }else{
                    print("Save note data failure!!!!!")
                }
            }
        }
        
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
        
}