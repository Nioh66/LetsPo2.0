//
//  BoardSettingVC.swift
//  LetsPo
//
//  Created by Pin Liao on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit
class BoardSettingVC: UIViewController ,UINavigationControllerDelegate{
    @IBOutlet weak var topBg: UIImageView!
    @IBOutlet weak var boardSetting: UIView!
    @IBOutlet weak var boardCheckBtn: UIImageView!

    let sendBgImageNN = Notification.Name("sendBgImage")
    var topBgImage:UIImage!
    var thePost:Note!
    var resizeNote:UIImage!
    let resetNote = Notification.Name("resetNote")

    var boardAlert:Bool = false
    var boardPrivacy:Bool = false
//    var boardLat:Double = 0.0
//    var boardLon:Double = 0.0
    
    var allNoteData = [String:Any]()    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: sendBgImageNN,
                                                  object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        boardSetting.layer.cornerRadius = 10.0
        boardCheckBtn.layer.cornerRadius = 10.0
        topBg.layer.cornerRadius = 10.0
        topBg.layer.masksToBounds = true
    
        let tapToNext = UITapGestureRecognizer(target: self, action: #selector(goToNextPage))
        boardCheckBtn.isUserInteractionEnabled = true
        boardCheckBtn.addGestureRecognizer(tapToNext)

        

        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: sendBgImageNN,
                                               object: nil)
        
    }
   // Notification method

    func theChooseOne(notification:Notification) {
      
        topBgImage = notification.userInfo!["myBg"] as! UIImage
        
        topBg.image = topBgImage
    }

   // Go to next page
    func goToNextPage() {
        
        let dragVC = storyboard?.instantiateViewController(withIdentifier:"DragBoardVC") as! DragBoardVC
        
        dragVC.topBgImages = topBg.image
        dragVC.resizeNote = resizeNote
        dragVC.thePost = thePost
        dragVC.allNoteData = allNoteData
        
        
        dragVC.boardAlert = boardAlert
        dragVC.boardPrivacy = boardPrivacy
//        dragVC.boardLat = boardLat
//        dragVC.boardLon = boardLon
       navigationController?.pushViewController(dragVC, animated: true)
        
    }
    
    //IBAction swtich
    
    @IBAction func privacyValueSwitchToChange(_ sender: UISwitch) {
        
        if sender.isOn {
             boardPrivacy = true
        }else{
            boardPrivacy = false
        }
        
    }
    @IBAction func alertValueSwitchToChange(_ sender: UISwitch) {
        if sender.isOn {
            boardAlert = true
        }else{
            boardAlert = false
        }
    }
    
}
