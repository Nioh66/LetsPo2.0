//
//  NotiSettingVC.swift
//  LetsPo
//
//  Created by Pin Liao on 25/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class NotiSettingVC: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var allowSoundNotice: UISwitch!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var allowShakeNotice: UISwitch!
    @IBOutlet weak var allowNotice: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
        
        if UserDefaults.standard.bool(forKey: "UserNotification") == true {
            allowNotice.isOn = true
           
        }else {
            allowNotice.isOn = false
        }
        if UserDefaults.standard.bool(forKey: "soundNotice") == true {
            allowSoundNotice.isOn = true
            
        }else {
            allowSoundNotice.isOn = false
        }
        if UserDefaults.standard.bool(forKey: "shakeNotice") == true {
            allowShakeNotice.isOn = true
            
        }else {
            allowShakeNotice.isOn = false
        }
        
    }
    @IBAction func allowNoticeSetting(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "UserNotification")
            hideView.isHidden = false
        }else {
            UserDefaults.standard.set(false, forKey: "UserNotification")
            hideView.isHidden = true
        }
    }
    @IBAction func shakeNotice(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "shakeNotice")
        }else {
            UserDefaults.standard.set(false, forKey: "shakeNotice")
        }
    }

    @IBAction func settingFinishBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func soundNotce(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "soundNotice")
        }else {
            UserDefaults.standard.set(false, forKey: "soundNotice")
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
