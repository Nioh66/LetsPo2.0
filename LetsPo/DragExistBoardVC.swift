//
//  DragExistBoardVC.swift
//  LetsPo
//
//  Created by Pin Liao on 07/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class DragExistBoardVC: UIViewController {
    
    
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
    let resetNote = Notification.Name("resetNote")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publicBgImage.image = bgImage
        publicBgImage.isUserInteractionEnabled = true
        print(resizeNote)
        theDragNote.frame = CGRect(x: posterX, y: posterY, width: posterEdge, height: posterEdge)
        theDragNote.image = resizeNote
        theDragNote.isUserInteractionEnabled = true
        
        publicBgImage.addSubview(theDragNote)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        
        theDragNote.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
    }
    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: publicBgImage)
        print(theDragNote.frame.minX)
        print(theDragNote.frame.minY)
        
        theDragNote.center = point
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        self.saveNoteData()
        self.uploadBoardBg()
        NotificationCenter.default.post(name: resetNote, object: nil)
        
        tabBarController?.selectedIndex = 0
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
        
        guard let noteContent = allNoteData["noteContent"] as? String?,
            let noteBgColor = allNoteData["noteBgColor"] as? NSData,
            let noteFontColor = allNoteData["noteFontColor"] as? NSData,
            let noteFontSize = allNoteData["noteFontSize"] as? Double,
            let noteImage = allNoteData["noteImage"] as? [UIImage],
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
