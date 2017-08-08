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
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "notificationCenter"),object: nil)
    }
    
    var dataManagerCount = Int()
    var selectIndexID = Int16()
    var selectIDformMap = Int16()
    let getBoardPosts = GetBoardNotes()
    var secondTime:Bool!
    var fromNewNote:Bool!
    
    
    
    @IBOutlet weak var boardSettingBtn: UIButton!
    @IBOutlet weak var addPostBtn: UIButton!
    @IBOutlet weak var deletePostBtn: UIButton!
    
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var backGroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secondTime = false
        fromNewNote = false
        
        self.addingObserver()
        
        
        
        dataManagerCount = boardDataManager.count()
        
        print("select Index ID \(selectIndexID)")
        //        print("select ID from map \(selectIDformMap)")
        
        //        if selectIndexID == 0 {
        //            print("nil")
        //            return
        //        }
        //        selectIndexID = 1
        
        //        guard let postsScreenShot = getBoardPosts.getNotesSelfie(boardID: selectIndexID),
        //            let allPosts = getBoardPosts.presentNotes(boardID: selectIndexID, selfies: postsScreenShot),
        //            let bgImage = getBoardPosts.getBgImage(boardID: selectIndexID),
        //            let allPostsID = getBoardPosts.getNotesID(boardID: selectIndexID)
        //            else{
        //                return
        //        }
        //        print(backGroundImage)
        //
        //        backGroundImage.image = bgImage
        //        backGroundImage.isUserInteractionEnabled = true
        //
        //        for (index,imageview) in allPosts.enumerated(){
        //            print(index)
        //            imageview.isUserInteractionEnabled = true
        //            imageview.backgroundColor = UIColor.clear
        //
        //            let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
        //            detailBtn.postImageView = imageview
        //            detailBtn.postID = allPostsID[index]
        //            detailBtn.boardID = selectIndexID
        //            backGroundImage.addSubview(imageview)
        //
        //            imageview.addGestureRecognizer(detailBtn)
        //        }
        
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
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        dataManagerCount = boardDataManager.count()
        if selectIndexID == 0 {
            print("nil")
            return
        }
        guard let postsScreenShot = getBoardPosts.getNotesSelfie(boardID: selectIndexID),
            let allPosts = getBoardPosts.presentNotes(boardID: selectIndexID, selfies: postsScreenShot),
            let bgImage = getBoardPosts.getBgImage(boardID: selectIndexID),
            let allPostsID = getBoardPosts.getNotesID(boardID: selectIndexID)
            else{
                return
        }
        print(backGroundImage)
        
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
            
            
            imageview.addGestureRecognizer(detailBtn)
            
            print("fromNewNote \(fromNewNote)")
            
            // 如果是普通的第二次進入這頁 先拔掉所有的 imageV
            if secondTime == true && fromNewNote == false {
                print("DispatchQueue secondTime = \(secondTime)indexID \(allPostsID[index])")
                DispatchQueue.main.async() {
                    // 不知道為什麼要在 DispatchQueue 拔，但網路上都這樣寫
                    imageview.removeFromSuperview()
                    
                }
            }
            // 如果是透過新增跳轉到這一頁 則不拔掉最後一個新增的 view
            // 為什麼透過新增的 view 不能拔掉呢？ 我不知道.... (還沒addSubView所以不能拔？)
            if secondTime == true && fromNewNote == true && index < allPosts.count - 1 {
                DispatchQueue.main.async() {
                    imageview.removeFromSuperview()
                }
                print("secondTime\(secondTime) fromNewNote\(fromNewNote) index\(index)")
            }
            print("index ... =  \(allPostsID[index])")
            backGroundImage.addSubview(imageview)
            print("add add add")
            
        }
        // fromNewNote 設成 false 等一下跳來跳去 又是一條好漢 繼續全部拔掉再貼上
        fromNewNote = false
        secondTime = true
        print("addSubview secondTime = \(secondTime)fromNewNote \(fromNewNote)")
        
    }
    // MARK: Adding NotificationCenter observer
    func addingObserver() {
        //      NotificationCenter.default.addObserver(self, selector: #selector(boardReset),name: boardSettingNN,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newNoteComing), name: newNoteComingNN, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: NSNotification.Name(rawValue: "notificationCenter"),
                                               object: nil)
        
        
    }
    func theChooseOne(notification:Notification) {
        if let board_Id = notification.userInfo?["id"] as? Int16 {
            selectIndexID = board_Id
            print("notification")
        }
    }
    
    func newNoteComing(notification:Notification) {
        
        let refreshVC = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! ManageDetailViewController
        
        // how to refresh
        self.dismiss(animated: false, completion: nil)
        
        refreshVC.selectIndexID = selectIndexID
        self.present(refreshVC, animated: false, completion: nil)
        
        fromNewNote = true
        print("fromNewNote \(fromNewNote)")
        
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
            newPostSegue.boardID = selectIndexID
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
