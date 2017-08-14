//
//  LoginVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/10.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var registBtn: UIButton!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var accountLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 10.0
        contentView.layer.masksToBounds = true
        if memberDataManager.count() > 0 {
            registBtn.isHidden = true
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tap)
        
    }
    func hideKeyboard(tapG:UITapGestureRecognizer){
        
        passwordLabel.resignFirstResponder()
        accountLabel.resignFirstResponder()
        
    }
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        // 上資料庫去驗證
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
         self.navigationController?.isNavigationBarHidden = true
        
    }
   
}
