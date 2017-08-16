//
//  FindNiggerVC.swift
//  LetsPo
//
//  Created by Pin Liao on 25/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class FindNiggerVC: UIViewController {
    
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var inputID: UITextField!
    
    var friendID = Int64()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.navigationItem.leftItemsSupplementBackButton = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        
        guard let searchId = inputID.text,
            let friendID = Int64(searchId) else {
            notNumberAlert()
            return
        }
       searchID(friendID: friendID)
    }
    func searchID(friendID:Int64) {
        let member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
        let alamoMachine = AlamoMachine()
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
                    
                }else{
                    self.notNumberAlert()
                }
                
                
            }
        }
        
        
    }
    
    func notNumberAlert() {
        
        let alert = UIAlertController.init(title: "不存在此ID", message: nil, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (Timer) in
            alert.dismiss(animated: false, completion: nil)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: hideKeyboard
    
    func hideKeyboard(tap:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.inputID.resignFirstResponder()
        }
        
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
