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
        let verifiMachine = AlamoMachine()
        
        let verification = ["Account":accountLabel.text,
                            "Password":passwordLabel.text]
        verifiMachine.doPostJobWith(urlString: verifiMachine.LOGIN, parameter: verification) { (error, response) in
            if error != nil {
                print(error!)
            }
            else{
                guard let rsp = response else{
                    return
                }
                let result = rsp["result"] as! Bool
                if result {
                    self.saveToCoreData(data: rsp)
                }
                else{
                    let errorResult = rsp["errorCode"] as! String
                    self.vertificateAlert(errorCode: errorResult)
                    print(errorResult)
                }
            }
        }
        // 上資料庫去驗證
        
    }
    
    func saveToCoreData(data:[String:Any]) {
        print("\(data)")
        
        guard let memberID = data["Member_ID"] as?  String,
            let memberName = data["Member_Name"] as? String,
            let memberPassword = data["Member_Password"] as? String,
            let memberEmail = data["Member_Email"]  as? String,
            let memberIDInt64 = Int64(memberID)
            else{
                return
            }
        let memberItem = memberDataManager.createItem()

        
        let memberSelfieDataString = data["Member_Selfie"] as? String
        if memberSelfieDataString != nil{
            let memberSelfie = NSData(base64Encoded: memberSelfieDataString!, options: [])
            memberItem.member_Selfie = memberSelfie
        }
        memberItem.member_ID = memberIDInt64
        memberItem.member_Name = memberName
        memberItem.member_Password = memberPassword
        memberItem.member_Email = memberEmail
        UserDefaults.standard.set(memberIDInt64, forKey: "Member_ID")

        memberDataManager.saveContexWithCompletion { (success) in
            if(success){
                print("Save member data success!!!!!")
            }else{
                print("Save member data failure!!!!!")
            }
        }
    }
    
    func vertificateAlert(errorCode:String) {
        let alert = UIAlertController.init(title: errorCode, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
         self.navigationController?.isNavigationBarHidden = true
        
    }
   
}
