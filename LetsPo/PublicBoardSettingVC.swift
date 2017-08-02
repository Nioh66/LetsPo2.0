//
//  PublicBoardSettingVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/2.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class PublicBoardSettingVC: UIViewController {
   
    
    @IBOutlet weak var boardPrivacyValue: UISwitch!
    @IBOutlet weak var boardAlertValue: UISwitch!
    
    
    var publicPostID = Int16()
    var boardID = Int16()
    var boardAlert = Bool()
    var boardPrivacy = Bool()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(boardID)") as! [BoardData]
        
        
        for data in oldBoardData{
            if data.board_Id == boardID{
                if (data.board_Alert) {
                    boardAlertValue.isOn = true
                }else{
                    boardAlertValue.isOn = false
                }
                if (data.board_Privacy) {
                    boardPrivacyValue.isOn = true
                }else{
                    boardPrivacyValue.isOn = false

                }
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func publicSwitchChangeValue(_ sender: UISwitch) {
        
        if sender.isOn {
            boardPrivacy = true
        }else{
            boardPrivacy = false
        }
        self.updateBoardData()
        print("ssssss")
    }

    @IBAction func noticeSwitchChangeValue(_ sender: UISwitch) {
        
        if sender.isOn {
            boardAlert = true
        }else{
            boardAlert = false
        }
        self.updateBoardData()
        print("ssssss")
    }
    
    func updateBoardData() {
        
        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(boardID)") as! [BoardData]
        
        
        for data in oldBoardData{
            if data.board_Id == boardID{
                data.board_Alert = boardAlert
                data.board_Privacy = boardPrivacy
                data.board_CreateTime = NSDate()
                
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

}
