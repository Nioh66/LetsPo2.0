//
//  FindNiggerVC.swift
//  LetsPo
//
//  Created by Pin Liao on 25/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class FindNiggerVC: UIViewController {

    @IBOutlet weak var inputID: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
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
