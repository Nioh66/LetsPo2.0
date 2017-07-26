//
//  testViewController.swift
//  LetsPo
//
//  Created by Pin Liao on 23/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class testViewController: UIViewController ,ThePostDelegate{

    let vCNote = NewPostVC()

    var popoView:Note? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vCNote.delegate = self

        // Do any additional setup after loading the view.
        vCNote.getMyPopo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
 
    func sendthePost(post: Note!) {
        popoView = post
        
        print("----=====------\(post)")
     //   self.view.addSubview(popoView!)

        print("-=-=--=-=-=-=-=-=-\(popoView?.subviews)")
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
