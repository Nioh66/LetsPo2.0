//
//  SelfDragVC.swift
//  LetsPo
//
//  Created by Pin Liao on 24/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfDragVC: UIViewController {

    
    var posterX:CGFloat = 150
    var posterY:CGFloat = 150
    let posterEdge:CGFloat = 100
    var bgImage = UIImage()
    var resizeNote:UIImage!
    var theDragNote = UIImageView()
    var allNoteData = [String:Any]()
    let newNoteComingNN = Notification.Name("newNoteComing")

    @IBOutlet weak var selfBgImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        selfBgImage.image = bgImage
        
        theDragNote.frame = CGRect(x: posterX, y: posterY, width: posterEdge, height: posterEdge)
        theDragNote.image = resizeNote
        theDragNote.isUserInteractionEnabled = true
        
        selfBgImage.addSubview(theDragNote)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        
        theDragNote.addGestureRecognizer(panGesture)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndPop))
        // Do any additional setup after loading the view.
    }
    
    func saveAndPop() {
        self.saveNoteData()
        NotificationCenter.default.post(name: newNoteComingNN, object: nil)
        navigationController?.popToRootViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true

    }
    

    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: selfBgImage)
        print(theDragNote.frame.minX)
        print(theDragNote.frame.minY)
        
        theDragNote.center = point
    }

    
    func saveNoteData() {
        let item = selfNoteDataManager.createItem()
        
        
        let itemCount = selfNoteDataManager.count()
        print("itemCount------\(itemCount)")
        if itemCount == 0{
            item.selfNote_ID = 1
        }else{
            let lastSelfNoteItem = selfNoteDataManager.itemWithIndex(index: 0)
            item.selfNote_ID = lastSelfNoteItem.selfNote_ID + 1
            print(lastSelfNoteItem.selfNote_ID)

        }
        
        print(item.selfNote_ID)
        guard let noteContent = allNoteData["selfNoteContent"] as? String?,
            let noteBgColor = allNoteData["selfNoteBgColor"] as? NSData,
            let noteFontColor = allNoteData["selfNoteFontColor"] as? NSData,
            let noteFontSize = allNoteData["selfNoteFontSize"] as? Double,
            let noteImage = allNoteData["selfNoteImage"] as? [UIImage],
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
        item.selfNote_X = Double(theDragNote.frame.minX)
        item.selfNote_Y = Double(theDragNote.frame.minY)
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
