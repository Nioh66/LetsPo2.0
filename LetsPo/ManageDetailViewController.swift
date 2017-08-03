//
//  ManageDetailViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class ManageDetailViewController: UIViewController ,UIPopoverPresentationControllerDelegate{
    
    let boardSettingNN = Notification.Name("boardSetting")
    let newNoteComingNN = Notification.Name("newPublicNoteComing")

    deinit {
        NotificationCenter.default.removeObserver(self,name: boardSettingNN,object: nil)
        NotificationCenter.default.removeObserver(self,name: newNoteComingNN,object: nil)
    }
    
    var dataManagerCount = Int()
    var selectIndexID = Int16()
    let getBoardPosts = GetBoardNotes()

    
    @IBOutlet weak var boardSettingBtn: UIButton!
    @IBOutlet weak var addPostBtn: UIButton!
    @IBOutlet weak var deletePostBtn: UIButton!
        
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var backGroundImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.addingObserver()

        dataManagerCount = boardDataManager.count()
        
        print("selectIndex \(selectIndexID)")
        
        guard let postsScreenShot = getBoardPosts.getNotesSelfie(boardID: selectIndexID),
            let allPosts = getBoardPosts.presentNotes(boardID: selectIndexID, selfies: postsScreenShot),
            let bgImage = getBoardPosts.getBgImage(boardID: selectIndexID),
            let allPostsID = getBoardPosts.getNotesID(boardID: selectIndexID)
            else{
                return
        }
        
        backGroundImage.image = bgImage
        backGroundImage.isUserInteractionEnabled = true
        
        for (index,imageview) in allPosts.enumerated(){
            print(index)
            imageview.isUserInteractionEnabled = true
            imageview.backgroundColor = UIColor.clear
            
            let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
            detailBtn.postImageView = imageview
            detailBtn.postID = allPostsID[index]
            detailBtn.boardID = selectIndexID
            backGroundImage.addSubview(imageview)
            
            imageview.addGestureRecognizer(detailBtn)
        }
        
    }
    
    func goToDetail(gestureRecognizer:TapToShowDetail){

        let detailPostID = gestureRecognizer.postID
        let detailboardID = gestureRecognizer.boardID
        print("GoToDetail did press")
        
        let publicPostDetailVC =  storyboard?.instantiateViewController(withIdentifier: "PublicPostDetailVC") as! PublicPostDetailVC
        publicPostDetailVC.modalPresentationStyle = .popover
        publicPostDetailVC.publicPostID = detailPostID
        publicPostDetailVC.boardID = detailboardID
        let popDetailPostVC = publicPostDetailVC.popoverPresentationController
        popDetailPostVC?.delegate = self
        popDetailPostVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popDetailPostVC?.sourceView = detailNoteAppearPoint
        popDetailPostVC?.sourceRect = detailNoteAppearPoint.bounds
        present(publicPostDetailVC, animated: true, completion: nil)
    }
    
    
    @IBAction func boardSettingBtnPressed(_ sender: UIButton) {
       // PublicBoardSettingVC
        
        print("boardSettingBtnPressed action")
        
        let publicBoardSettinglVC =  storyboard?.instantiateViewController(withIdentifier: "PublicBoardSettingVC") as! PublicBoardSettingVC
        publicBoardSettinglVC.modalPresentationStyle = .popover
        publicBoardSettinglVC.boardID = selectIndexID
        publicBoardSettinglVC.preferredContentSize = CGSize(width: 125, height: 100)
        let popDetailPostVC = publicBoardSettinglVC.popoverPresentationController
        popDetailPostVC?.delegate = self
        popDetailPostVC?.permittedArrowDirections = .up
        popDetailPostVC?.sourceView = boardSettingBtn
        popDetailPostVC?.sourceRect = boardSettingBtn.bounds
        present(publicBoardSettinglVC, animated: true, completion: nil)

        
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
    // MARK: Adding NotificationCenter observer
    func addingObserver() {
  //      NotificationCenter.default.addObserver(self, selector: #selector(boardReset),name: boardSettingNN,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newNoteComing), name: newNoteComingNN, object: nil)
        
    }
    func newNoteComing(notification:Notification) {
        
        let refreshVC = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! ManageDetailViewController
        
        // how to refresh
        self.dismiss(animated: false, completion: nil)
        
        refreshVC.selectIndexID = selectIndexID
        self.present(refreshVC, animated: false, completion: nil)
        
        
    }
//    func boardReset(notification:Notification) {
//        
//        let  BgImage:UIImage = notification.userInfo!["selfBg"] as! UIImage
//        
//        selfBgImage.image = BgImage
//    }
//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newPublicNote"){
            let bgImageWithNotes = self.getBGimageWithPosts()
            let newPostSegue = segue.destination as! NewPublicPostVC
            newPostSegue.bgImage = bgImageWithNotes
        }else{
            
        }
    }
    
    
    
    func getBGimageWithPosts() -> UIImage {
        boardSettingBtn.alpha = 0.0
        addPostBtn.alpha = 0.0
        deletePostBtn.alpha = 0.0
        //       self.tabBarController?.tabBar.isHidden = true
        let BGimageWithPosts = self.view.boardScreenShot()
        
        boardSettingBtn.alpha = 1
        addPostBtn.alpha = 1
        deletePostBtn.alpha = 1
        
        return BGimageWithPosts!
    }

   }
