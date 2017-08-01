//
//  ManageDetailViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class ManageDetailViewController: UIViewController {
    
    var dataManagerCount = Int()
    var selectIndexID = Int16()
    
        
    @IBOutlet weak var backGroundImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManagerCount = boardDataManager.count()
        
        print("selectIndex \(selectIndexID)")
        for i in 0..<dataManagerCount {
            let item = boardDataManager.itemWithIndex(index: i)
            let board_id = item.board_Id
            if selectIndexID == board_id {
                var imgWithData = UIImage()
                if let img = item.board_BgPic {
                    imgWithData = UIImage(data: img as Data)!
                }
                backGroundImage.image = imgWithData
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        dataManagerCount = boardDataManager.count()
        
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
