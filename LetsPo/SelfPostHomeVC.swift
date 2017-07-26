//
//  SelfPostHomeVC.swift
//  LetsPo
//
//  Created by Pin Liao on 24/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfPostHomeVC: UIViewController {
    
    let sendBgImageNN = Notification.Name("sendSelfBgImage")
    
    
    @IBOutlet weak var selfBgImage: UIImageView!
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: sendBgImageNN,
                                                  object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        
        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: sendBgImageNN,
                                               object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectBgImage"){
            _ = segue.destination as! SelfPostBgSelectVC
            
        }else if(segue.identifier == "newSelfNote"){
            let newPostSegue = segue.destination as! SelfNewPostVC
            newPostSegue.bgImage = selfBgImage.image
        }else{
            
        }
    }
    
    func theChooseOne(notification:Notification) {
        
        let  BgImage:UIImage = notification.userInfo!["selfBg"] as! UIImage
        
        selfBgImage.image = BgImage
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
