//
//  accountViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/23.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class AccountVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let cellTitle = ["個人資料","通知管理","好友管理"]
    let selfieBgImageNN = Notification.Name("selfie")
    var login:Bool!
    let resetAccount = Notification.Name("resetAccount")
    
    @IBOutlet weak var registBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalImage: UIImageView!
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: selfieBgImageNN, object: nil)
        NotificationCenter.default.removeObserver(self, name: resetAccount, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        login = false
        if memberDataManager.count() > 0 {
            login = true
            loginBtn.isHidden = true
            registBtn.isHidden = true
            personalName.isHidden = false
            
        }else {
            loginBtn.isHidden = false
            registBtn.isHidden = false
            personalName.isHidden = true
            personalImage.image = UIImage(named: "user")
        }

        
        
        let count = memberDataManager.count()
        for i in 0 ..< count {
            let item = memberDataManager.itemWithIndex(index: i)
            personalName.text = item.member_Name
            
            let image = item.member_Selfie
            
            if image != nil {
                guard let ii = UIImage(data: image! as Data) else {return}
                personalImage.image = ii
            }else {
                personalImage.image = UIImage(named: "user")
            }
        }

        personalImage.frame = CGRect(x: view.center.x, y: 30, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.width/2)
        personalImage.backgroundColor = UIColor.black
        personalImage.layer.cornerRadius = (self.personalImage.frame.size.width) / 2
        personalImage.clipsToBounds = true
        
        print("\(UIScreen.main.bounds.size.width)")


        NotificationCenter.default.addObserver(self, selector: #selector(reset),
                                               name: resetAccount,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(theBGimage), name: selfieBgImageNN, object: nil)

    }
    
    func reset(notification:Notification) {
//        let refreshVC = storyboard?.instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
//        
//        // how to refresh
//        self.dismiss(animated: false, completion: nil)
//        self.present(refreshVC, animated: false, completion: nil)
    
        
    }
    
    func theBGimage(notification:Notification) {
        personalImage.image = notification.userInfo!["selfieBg"] as? UIImage//??
        
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if login == false {
            print("還沒有資料和登錄")
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            navigationController?.pushViewController(nextPage!, animated: true)
        }
    }
    
    @IBAction func registButtonPressed(_ sender: UIButton) {
        if login == false {
            print("還沒有資料和登錄")
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "RegistVC") as? RegistVC
            navigationController?.pushViewController(nextPage!, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = cellTitle[indexPath.row]
        cell?.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        cell?.selectionStyle = .none
        if login == false {
            if indexPath.row == 0 || indexPath.row == 2 {
                cell?.textLabel?.textColor = UIColor.lightGray
            }
        }else {
            cell?.textLabel?.textColor = UIColor.black
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        if indexPath.row == 0 {
            if login == true {
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "PersonalDetailVC") as? PersonalDetailVC
                nextPage?.navigationItem.leftItemsSupplementBackButton = true
                navigationController?.pushViewController(nextPage!, animated: true)
            }
        }else if indexPath.row == 1{
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "NotiSettingVC") as? NotiSettingVC
                nextPage?.navigationItem.leftItemsSupplementBackButton = true
                navigationController?.pushViewController(nextPage!, animated: true)
            
        }else if indexPath.row == 2{
            if login == true {
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "MyNiggerVC") as? MyNiggerVC
                nextPage?.navigationItem.leftItemsSupplementBackButton = true
                navigationController?.pushViewController(nextPage!, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
        login = false
        if memberDataManager.count() > 0 {
            login = true
            loginBtn.isHidden = true
            registBtn.isHidden = true
            personalName.isHidden = false
            let item = memberDataManager.itemWithIndex(index: 0)
            personalName.text = item.member_Name
            
            let image = item.member_Selfie
            
            if image != nil {
                guard let img = UIImage(data: image! as Data) else {return}
                personalImage.image = img
            }else {
                personalImage.image = #imageLiteral(resourceName: "user")
            }
            
            table.reloadData()
            
        }else {
            personalName.isHidden = true
            personalImage.image = UIImage(named: "user")
        }

        
    }
}
