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
    @IBOutlet weak var goExistBoard: UIButton!
    @IBOutlet weak var setBgImageBtn: UIButton!
    @IBOutlet weak var titleTextfield: UITextField!
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
    var boardLat:Double = 0.0
    var boardLon:Double = 0.0
    let boardCreatetime = NSDate()
    var boardTitle = ""
    
    
    var allNoteData = [String:Any]()
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: sendBgImageNN,
                                                  object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextfield.placeholder = "\(boardCreatetime)"
        setBgImageBtn.layer.cornerRadius = 10.0
        setBgImageBtn.layer.masksToBounds = true
        
        boardSetting.layer.cornerRadius = 10.0
        boardCheckBtn.layer.cornerRadius = 10.0
        topBg.layer.cornerRadius = 10.0
        topBg.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tap)
        
        
        
        let tapToNext = UITapGestureRecognizer(target: self, action: #selector(goToNextPage))
        boardCheckBtn.isUserInteractionEnabled = true
        boardCheckBtn.addGestureRecognizer(tapToNext)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: sendBgImageNN,
                                               object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        tabBarController?.tabBar.isHidden = true
    }
    
    func hideKeyboard(tapG:UITapGestureRecognizer){
        // self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.titleTextfield.resignFirstResponder()
        }
        
    }
    
    
    // Notification method
    
    func theChooseOne(notification:Notification) {
        
        topBgImage = notification.userInfo!["myBg"] as! UIImage
        print("get bg")
        topBg.image = topBgImage
    }
    
    // Go to next page
    func goToNextPage() {
        
        let dragVC = storyboard?.instantiateViewController(withIdentifier:"DragBoardVC") as! DragBoardVC
        if titleTextfield.text == "" {
            dragVC.boardTitle = titleTextfield.placeholder!
        }else{
            dragVC.boardTitle = boardTitle
        }
        
        dragVC.topBgImages = topBg.image
        dragVC.resizeNote = resizeNote
        dragVC.thePost = thePost
        dragVC.allNoteData = allNoteData
        dragVC.boardLat = boardLat
        dragVC.boardLon = boardLon
        dragVC.boardAlert = boardAlert
        dragVC.boardPrivacy = boardPrivacy
        dragVC.boardCreatetime = boardCreatetime
        navigationController?.pushViewController(dragVC, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goExistBoard" {
            let existBoardSegue = segue.destination as! ExistBoardVC
            existBoardSegue.resizeNote = resizeNote
            existBoardSegue.allNoteData = allNoteData
            existBoardSegue.Lat = boardLat
            existBoardSegue.Lon = boardLon
            
        }else if segue.identifier == "goDragBoard"{
            
        }else{
            
        }
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
