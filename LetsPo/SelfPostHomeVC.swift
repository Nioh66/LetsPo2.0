//
//  SelfPostHomeVC.swift
//  LetsPo
//
//  Created by Pin Liao on 24/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

enum ViewMode {
    case Mode_Home
    case Mode_Adding
    case Mode_Deleting
}



class SelfPostHomeVC: UIViewController {
    
    let sendBgImageNN = Notification.Name("sendSelfBgImage")
    let newNoteComingNN = Notification.Name("newNoteComing")

    deinit {
        NotificationCenter.default.removeObserver(self,name: sendBgImageNN,object: nil)
    }

    @IBOutlet weak var selfBgImage: UIImageView!
    
    var resizeNote:UIImage? = nil
    var theDragNote:UIImageView? = nil
    var posterX:CGFloat = 150
    var posterY:CGFloat = 150
    let posterEdge:CGFloat = 100
    
    var allNoteData = [String:Any]()
    
      override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        selfBgImage.isUserInteractionEnabled = true

        
        
        if resizeNote != nil{
            
            let SCREEN_WIDTH = self.view.frame.size.width
            let SCREEN_HEIGHT = self.view.frame.size.height
    
            
            
        theDragNote = UIImageView(frame: CGRect(x: posterX, y: posterY, width: posterEdge, height: posterEdge))
        theDragNote?.image = resizeNote
        theDragNote?.isUserInteractionEnabled = true
        
        selfBgImage.addSubview(theDragNote!)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        
        theDragNote?.addGestureRecognizer(panGesture)
            
        let saveBtn = UIButton(frame: CGRect(x: (SCREEN_WIDTH/2) - 10, y: (SCREEN_HEIGHT/2) - 10, width: 20, height: 20))
            saveBtn.setTitle("Save", for: .normal)
            saveBtn.addTarget(self, action: #selector(dragFinish), for: .touchUpInside)
            
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: sendBgImageNN,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newNoteComing), name: newNoteComingNN, object: nil)
    }
    //MARK: New post coming noti method
    func newNoteComing(notification:Notification) {
        
        //..
    }
    
    func dragFinish() {
        self.saveDrag()
    }
    
    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: selfBgImage)
        
        
        theDragNote?.center = point
    }

    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    
    
    
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectBgImage"){
            _ = segue.destination as! SelfPostBgSelectVC
            
        }else if(segue.identifier == "newSelfNote"){
            let newPostSegue = segue.destination as! SelfNewPostVC
            newPostSegue.bgImage = selfBgImage.image!
        }else{
            
        }
    }
    
    func theChooseOne(notification:Notification) {
        
        let  BgImage:UIImage = notification.userInfo!["selfBg"] as! UIImage
        
        selfBgImage.image = BgImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveDrag() {
        let item = selfNoteDataManager.createItem()
        
        
        let itemCount = selfNoteDataManager.count()
        
        if itemCount == 0{
            item.selfNote_ID = 1
        }else{
            let lastSelfNoteItem = selfNoteDataManager.itemWithIndex(index: itemCount - 1)
            item.selfNote_ID = lastSelfNoteItem.selfNote_ID + 1
        }

        
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
        guard let imageJson = selfNoteDataManager.transformImageTOJson(images: noteImage) else{
            print("imageJson transform failure!!!!")
            return
        }
        
        print("---------\(imageJson)-------------")
        
        item.selfNote_BoardID = 1
        item.selfNote_BgColor = noteBgColor
        item.selfNote_Content = noteContent
        item.selfNote_FontColor = noteFontColor
        item.selfNote_FontSize = noteFontSize
        item.selfNote_X = Double(posterX)
        item.selfNote_Y = Double(posterY)
        item.selfNote_ScreenShot = noteSelfie
        item.selfNote_Image = imageJson
        

        
               selfNoteDataManager.saveContexWithCompletion { (success) in
            if(success){
                print("Save note data success!!!!!")
            }else{
                print("Save note data failure!!!!!")
            }
        }
    }
}
