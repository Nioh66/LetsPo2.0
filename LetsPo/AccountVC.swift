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
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalImage: UIImageView!

    deinit {
        NotificationCenter.default.removeObserver(self, name: selfieBgImageNN, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(theBGimage), name: selfieBgImageNN, object: nil)
        // Do any additional setup after loading the view.
    }
    func theBGimage(notification:Notification) {
         personalImage.image = notification.userInfo!["selfieBg"] as! UIImage
        
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
        //        cell?.textLabel?.frame(forAlignmentRect: 10)
        cell?.textLabel?.text = cellTitle[indexPath.row]
        cell?.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        if indexPath.row == 0 {
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "PersonalDetailVC") as? PersonalDetailVC
            nextPage?.navigationItem.leftItemsSupplementBackButton = true
            navigationController?.pushViewController(nextPage!, animated: true)
        }else if indexPath.row == 1{
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "NotiSettingVC") as? NotiSettingVC
            nextPage?.navigationItem.leftItemsSupplementBackButton = true
            navigationController?.pushViewController(nextPage!, animated: true)
        }else if indexPath.row == 2{
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "MyNiggerVC") as? MyNiggerVC
            nextPage?.navigationItem.leftItemsSupplementBackButton = true
            navigationController?.pushViewController(nextPage!, animated: true)

        }else{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        personalImage.backgroundColor = UIColor.black
        personalImage.layer.cornerRadius = personalImage.frame.size.width / 2
        personalImage.layer.masksToBounds = true

        
    }
}
