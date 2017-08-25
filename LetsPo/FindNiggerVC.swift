//
//  FindNiggerVC.swift
//  LetsPo
//
//  Created by Pin Liao on 25/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class FindNiggerVC: UIViewController {
    
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var inputID: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    var friendID = Int64()
    var member_ID:Int = 0
    let alamoMachine = AlamoMachine()
    //for CoreData
    var friendSelfieDataForC:NSData? = nil
    var friendNameForC:String? = nil
    let advanceImageView = AdvanceImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBtn.isHidden = true
        friendImage.layer.cornerRadius = 10.0
        friendImage.layer.masksToBounds = true
        member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
        self.view.backgroundColor = UIColor.clear
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        friendSelfieDataForC = nil
        guard let searchId = inputID.text,
            let friendID64 = Int64(searchId) else {
                notNumberAlert()
                return
        }
            let friendSearch = friendDataManager.searchField(field: "friend_FriendID", forKeyword: searchId)
        //判斷有無此朋友
        if friendSearch.count < 1{
            friendID = friendID64
            searchID(friendID: friendID)
        }else{
            haveFriendAlert()
        }
    }
   
    
    
    func searchID(friendID:Int64) {
        
        if friendID == Int64(member_ID) {
            sameAlert()
        }else{
            advanceImageView.prepareIndicatorView(view: self.view)
            let findDic = ["Member_ID":friendID]
            alamoMachine.doPostJobWith(urlString: alamoMachine.FIND_FRIEND, parameter: findDic) { (error, response) in
                if error != nil{
                    print(error!)
                }
                else{
                    guard let result = response?["result"] as? Bool else{
                        return
                    }
                    if result {
                        self.advanceImageView.advanceStop(view: self.view)
                        if let friendSelfieString = response?["Member_Selfie"] as? String{
                            let friendSelfieData = NSData(base64Encoded: friendSelfieString, options: [])
                            let friendSelfie = UIImage(data: friendSelfieData! as Data)
                            self.friendImage.image = friendSelfie

                            //for CoreData
                            self.friendSelfieDataForC = friendSelfieData
                            
                            
                        }else{
                            self.friendImage.image = #imageLiteral(resourceName: "user")

                        }
                        
                        guard let friendName = response?["Member_Name"] as? String
                            else{
                                return
                        }
                        
                        self.friendLabel.text = friendName
                        self.addBtn.isHidden = false
                        
                        //for CoreData
                        self.friendNameForC = friendName
                        
                    }else{
                        
                        self.notNumberAlert()
                    }
                }
            }
        }}
    
    func notNumberAlert() {
        self.advanceImageView.advanceStop(view: self.view)
        let alert = UIAlertController.init(title: "不存在此ID", message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (Timer) in
            alert.dismiss(animated: false, completion: nil)
        }
        
    }
    func sameAlert() {
        
        let alert = UIAlertController.init(title: "這是你的帳號！", message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (Timer) in
            alert.dismiss(animated: false, completion: nil)
        }
        
    }
    func addFriendAlert() {
        
        let alert = UIAlertController.init(title: "已新增好友", message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (Timer) in
            alert.dismiss(animated: false, completion: nil)
        }
        
    }
    func haveFriendAlert() {
        
        let alert = UIAlertController.init(title: "你已有此好友", message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (Timer) in
            alert.dismiss(animated: false, completion: nil)
        }
        
    }

    @IBAction func addBtnPressed(_ sender: UIButton) {
        advanceImageView.prepareIndicatorView(view: self.view)
        let addDic:[String:Any?] = ["SelfMember_ID":member_ID,"Member_ID":friendID]
        alamoMachine.doPostJobWith(urlString: alamoMachine.ADD_FRIEND, parameter: addDic) { (error, response) in
            if error != nil{
                self.advanceImageView.advanceStop(view: self.view)
                print(error!)
            }else{
                guard let result = response?["result"] as? Bool else{
                    return
                }
                if result{
                    self.addBtn.isHidden = true

                    //加入CoreData
                    
                    var idArray = [Int16]()
                    for i in 0 ..< friendDataManager.count() {
                        let lastFriendItem = friendDataManager.itemWithIndex(index: i)
                        let id = lastFriendItem.friend_ID
                        idArray.append(id)
                    }
                    idArray.sort { $0 > $1 }
                    
                    let item = friendDataManager.createItem()
                    if idArray.count < 1{
                        item.friend_ID = 1

                    }else{
                        let lastID = idArray[0]

                        item.friend_ID = lastID + 1
                    }
                    
                    item.friend_FriendName = self.friendNameForC
                    item.friend_FriendSelfie = self.friendSelfieDataForC
                    item.friend_FriendID = self.friendID
                    
                    
                    friendDataManager.saveContexWithCompletion(completion: { (success) in
                            print("Add friend success")
                        NotificationCenter.default.post(name: friendComing, object: nil, userInfo: nil)
                        self.advanceImageView.advanceStop(view: self.view)
                        self.addFriendAlert()
                        
                    })
                    
                }
            }
            
        }

    }
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: hideKeyboard
    
    func hideKeyboard(tap:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.inputID.resignFirstResponder()
        }
        
    }
    
    
}
