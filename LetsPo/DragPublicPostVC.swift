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
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    var posterX:CGFloat = 150
    var posterY:CGFloat = 150
    let posterEdge:CGFloat = 100
    var bgImage = UIImage()
    var resizeNote:UIImage? = nil
    var theDragNote = UIImageView()
    var allNoteData = [String:Any]()
    var boardID = Int16()
    var noteCount:Int16 = 0
    let newNoteComingNN = Notification.Name("newPublicNoteComing")
    //for upload
    let uploadMachine = AlamoMachine()
    var member_ID:Int? = nil
    var boardLat = Double()
    var boardLon = Double()
    var noteX = Double()
    var noteY = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //    theDragNote.backgroundColor = UIColor.blue
        
        theDragNote.backgroundColor = UIColor.clear
        
        
        theDragNote.frame = CGRect(x: posterX, y: posterY, width: posterEdge, height: posterEdge)
        theDragNote.image = resizeNote
        theDragNote.isUserInteractionEnabled = true
        
        publicBgImage.addSubview(theDragNote)
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        
        theDragNote.addGestureRecognizer(panGesture)
        
        publicBgImage.image = bgImage
        publicBgImage.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        saveBtn.isHidden = true
        backBtn.isHidden = true
        
        self.saveNoteData()
        self.updateBoardBg()
        
        member_ID = UserDefaults.standard.integer(forKey: "Member_ID")

        if(member_ID != 0){
            self.updateServerBoard()
            // self.uploadNote()
        }
        
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
        navigationController?.setNavigationBarHidden(true, animated: false)
            tabBarController?.tabBar.isHidden = true
        
    }
    
    
    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: publicBgImage)
        print(theDragNote.frame.minX)
        print(theDragNote.frame.minY)
        
        theDragNote.center = point
    }
    
    
    func updateServerBoard() {
        guard let screenShotImage = self.view.boardScreenShot(),
            let boardScreenShotData = UIImageJPEGRepresentation(screenShotImage, 0.8)
            else{
                return
        }
        let boardScreenShot = boardScreenShotData.base64EncodedString()
        
        let registDic:[String:Any] = ["Board_Lat":boardLat,
                                      "Board_Lon":boardLon,
                                      "Board_ScreenShot":boardScreenShot,
                                      "Board_CreateMemberID":member_ID!]
        
        uploadMachine.doPostJobWith(urlString: uploadMachine.UPDATE_BOARDSCREENSHOT, parameter: registDic) { (error, response) in
            if error != nil{
                print(error!)
            }
            print("Upload board complete!")
            self.saveNewNote()
        }

    }
    
    func saveNewNote() {
        guard let noteContent = allNoteData["publicNoteContent"] as? String?,
            let noteBgColor = allNoteData["publicNoteBgColor"] as? Data,
            let noteFontColor = allNoteData["publicNoteFontColor"] as? Data,
            let noteFontSize = allNoteData["publicNoteFontSize"] as? Double,
            let noteImage = allNoteData["publicNoteImage"] as? [UIImage],
            let noteSelfie = UIImagePNGRepresentation(resizeNote!)
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
                print(error!)
            }
            print("Upload note complete!")
            
        }
    

    }
    
    
    
    
    func updateBoardBg() {
        guard let newBoardPic = self.view.boardScreenShot(),
            let newBoardBg = UIImageJPEGRepresentation(newBoardPic, 1.0) as NSData? else{
                return
        }
        
        
        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(boardID)") as! [BoardData]
        
        for data:BoardData in oldBoardData{
            if data.board_Id == boardID{
                data.board_CreateTime = NSDate()
                data.board_ScreenShot = newBoardBg
                //for server
                boardLat = data.board_Lat
                boardLon = data.board_Lon
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
        if noteImage.count>=1{
            
            guard let imageJson = noteDataManager.transformImageTOJson(images: noteImage) else{
                print("imageJson transform failure!!!!")
                return
            }
            item.note_Image = imageJson
            print("---------\(imageJson)-------------")
        }
        

        let postX = theDragNote.frame.minX
        let postY = theDragNote.frame.minY
        noteX = Double(postX)
        noteY = Double(postY)

        
        item.note_BoardID = boardID
        item.note_ID = noteCount + 1
        item.note_BgColor = noteBgColor
        item.note_Content = noteContent
        item.note_FontColor = noteFontColor
        item.note_FontSize = noteFontSize
        item.note_X = noteX
        item.note_Y = noteY
        item.note_Selfie = noteSelfie
//        item.note_Image = imageJson
        
        
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
