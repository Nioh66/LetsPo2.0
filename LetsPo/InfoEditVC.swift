//
//  InfoEditViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/23.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class InfoEditVC: UIViewController {
    @IBOutlet weak var imageEditBtn: UIButton!
    @IBOutlet weak var selfImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        selfImage.frame = CGRect(x: self.view.center.x - 75, y: 75, width: 150, height: 150)
        selfImage.backgroundColor = UIColor.black
        selfImage.layer.cornerRadius = selfImage.frame.size.width / 2

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func imageEditBtn(_ sender: Any) {
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
