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
    var postIDs = [Int16]()
    let getBoardPosts = GetBoardNotes()
    var detailPostID:Int16 = 0

    
        
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var backGroundImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManagerCount = boardDataManager.count()
        
        print("selectIndex \(selectIndexID)")
//        for i in 0..<dataManagerCount {
//            let item = boardDataManager.itemWithIndex(index: i)
//            let board_id = item.board_Id
//            if selectIndexID == board_id {
//                var imgWithData = UIImage()
//                if let img = item.board_BgPic {
//                    imgWithData = UIImage(data: img as Data)!
//                }
//                backGroundImage.image = imgWithData
//            }
//        }
        guard let postsScreenShot = getBoardPosts.getNotesSelfie(boardID: Int(selectIndexID)),
            let allPosts = getBoardPosts.presentNotes(boardID: Int(selectIndexID), selfies: postsScreenShot),
            let bgImage = getBoardPosts.getBgImage(boardID: Int(selectIndexID)),
            let allPostsID = getBoardPosts.getNotesID(boardID: Int(selectIndexID))
            else{
                return
        }
        
        backGroundImage.image = bgImage
        backGroundImage.isUserInteractionEnabled = true
        
        postIDs = allPostsID
        for (index,imageview) in allPosts.enumerated(){
            print(index)
            imageview.isUserInteractionEnabled = true
            imageview.backgroundColor = UIColor.clear
            
            let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
            detailBtn.postImageView = imageview
            detailBtn.postID = allPostsID[index]
            backGroundImage.addSubview(imageview)
            
            imageview.addGestureRecognizer(detailBtn)
        }
        
    }
    
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
        detailPostID = gestureRecognizer.postID
        
        print("GoToDetail did press")
        
//          let detailPostVC =  storyboard?.instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailVC
//          detailPostVC.modalPresentationStyle = .popover
//          let popDetailPostVC = detailPostVC.popoverPresentationController
//          popDetailPostVC?.delegate = self
//          popDetailPostVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//        
//          popDetailPostVC?.sourceView = detailNoteAppearPoint
//          popDetailPostVC?.sourceRect = detailNoteAppearPoint.bounds
//          present(detailPostVC, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
