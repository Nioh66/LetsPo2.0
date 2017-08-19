//
//  MapDetailViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class MapDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backdroundImage: UIImageView!
    
    var dataManagerCount = Int()
    var selectIndexID = Int16()
    var selectMember_id = Int()
    var image = UIImage()
    var boardTitle = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManagerCount = boardDataManager.count()
        
        backdroundImage.image = image
        titleLabel.text = boardTitle

        
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
//        let detailPostID = gestureRecognizer.postID
//        let detailboardID = gestureRecognizer.boardID
//        print("--PostID\(detailPostID)")
//        
//        
//        let publicPostDetailVC =  storyboard?.instantiateViewController(withIdentifier: "FriendsPostDetailVC") as! FriendsPostDetailVC
//        publicPostDetailVC.modalPresentationStyle = .popover
//        publicPostDetailVC.publicPostID = detailPostID
//        publicPostDetailVC.boardID = detailboardID
//        let popDetailPostVC = publicPostDetailVC.popoverPresentationController
//        popDetailPostVC?.delegate = self
//        popDetailPostVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//        popDetailPostVC?.sourceView = detailNoteAppearPoint
//        popDetailPostVC?.sourceRect = detailNoteAppearPoint.bounds
//        present(publicPostDetailVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        
    }
}
