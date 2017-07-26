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
   

    func theChooseOne(notification:Notification) {
      
        topBgImage = notification.userInfo!["myBg"] as! UIImage
        
        topBg.image = topBgImage
    }

   
    func goToNextPage() {
        
        let dragVC = storyboard?.instantiateViewController(withIdentifier:"DragBoardVC") as! DragBoardVC
        
        dragVC.topBgImages = topBg.image
        dragVC.resizeNote = resizeNote
        dragVC.thePost = thePost

       navigationController?.pushViewController(dragVC, animated: true)
        
        
        
//        self.performSegue(withIdentifier: "goBackSetting", sender: self)
//        present(dragVC, animated: false, completion: nil)
    }
}
