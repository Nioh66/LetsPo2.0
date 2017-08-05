//
//  SelfPostHomeVC.swift
//  LetsPo
//
//  Created by Pin Liao on 24/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

enum ViewMode {
    case Mode_Home
    case Mode_Adding
    case Mode_Deleting
}



class SelfPostHomeVC: UIViewController ,UIPopoverPresentationControllerDelegate{
    
    let sendBgImageNN = Notification.Name("sendSelfBgImage")
    let newNoteComingNN = Notification.Name("newNoteComing")

    deinit {
        NotificationCenter.default.removeObserver(self,name: sendBgImageNN,object: nil)
        NotificationCenter.default.removeObserver(self,name: newNoteComingNN,object: nil)
    }
    @IBOutlet weak var detailPostAppearV: UIView!
    @IBOutlet weak var bgSettingBtn: UIButton!
    @IBOutlet weak var addNewPostBtn: UIButton!
    @IBOutlet weak var deletePostBtn: UIButton!

    @IBOutlet weak var selfBgImage: UIImageView!
    
    var theDragNote:UIImageView? = nil
    var posterX:CGFloat = 150
    var posterY:CGFloat = 150
    let posterEdge:CGFloat = 100
    let getAllPosts = SelfBoardSetting()
    var detailSelfPostID:Int16 = 0
    var secondTime:Bool!
    var fromNewNote:Bool!

      override func viewDidLoad() {
        super.viewDidLoad()
        self.addingObserver()
        self.navigationController?.isNavigationBarHidden = true
        selfBgImage.isUserInteractionEnabled = true

        secondTime = false
        fromNewNote = false
        
        
    }
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
        detailSelfPostID = gestureRecognizer.postID
        
        print("GoToDetail did press")
        
        let detailSelfPostVC =  storyboard?.instantiateViewController(withIdentifier: "SelfPostDetailVC") as! SelfPostDetailVC
        detailSelfPostVC.modalPresentationStyle = .popover
        detailSelfPostVC.selfPostID = detailSelfPostID
        let popDetailPostVC = detailSelfPostVC.popoverPresentationController
        popDetailPostVC?.delegate = self
        popDetailPostVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popDetailPostVC?.sourceView = detailPostAppearV
        popDetailPostVC?.sourceRect = detailPostAppearV.bounds
        present(detailSelfPostVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.topItem?.title = "臨時便貼"
        tabBarController?.tabBar.isHidden = false
        
        guard let allSelfPostsID = getAllPosts.getSelfNotesID() else{
            return
        }
        
        print("secondTime = \(secondTime)")
        
        if let notes = getAllPosts.getSelfboardNotes() {
            
            for (index,imageV) in notes.enumerated(){
                
                imageV.isUserInteractionEnabled = true
                imageV.backgroundColor = UIColor.clear
                
                let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
                
                
                detailBtn.postImageView = imageV
                detailBtn.postID = allSelfPostsID[index]
                imageV.addGestureRecognizer(detailBtn)
                
                
                print("fromNewNote \(fromNewNote)")
                
                // 如果是普通的第二次進入這頁 先拔掉所有的 imageV
                if secondTime == true && fromNewNote == false {
                    print("DispatchQueue secondTime = \(secondTime)indexID \(allSelfPostsID[index])")
                    DispatchQueue.main.async() {
                        // 不知道為什麼要在 DispatchQueue 拔，但網路上都這樣寫
                        imageV.removeFromSuperview()
                        
                    }
                }
                // 如果是透過新增跳轉到這一頁 則不拔掉最後一個新增的 view
                // 為什麼透過新增的 view 不能拔掉呢？ 我不知道.... (還沒addSubView所以不能拔？)
                if secondTime == true && fromNewNote == true && index < notes.count - 1 {
                    DispatchQueue.main.async() {
                        imageV.removeFromSuperview()
                    }
                    print("secondTime\(secondTime) fromNewNote\(fromNewNote) index\(index)")
                }
                print("index ... =  \(allSelfPostsID[index])")
                selfBgImage.addSubview(imageV)
                print("add add add")
                
            }
            // fromNewNote 設成 false 等一下跳來跳去 又是一條好漢 繼續全部拔掉再貼上
            fromNewNote = false
            secondTime = true
            print("addSubview secondTime = \(secondTime)fromNewNote \(fromNewNote)")
        }
  

    }
    
    
        // MARK: Adding NotificationCenter observer
    func addingObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: sendBgImageNN,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newNoteComing), name: newNoteComingNN, object: nil)

    }
    
    //MARK: New post coming noti method
    func newNoteComing(notification:Notification) {
        
        let refreshVC = storyboard?.instantiateViewController(withIdentifier: "SelfPostHomeVC")
        
        // how to refresh
        self.dismiss(animated: false, completion: nil)
        self.present(refreshVC!, animated: false, completion: nil)

        fromNewNote = true
        print("fromNewNote \(fromNewNote)")

    }
    
    
//    func panTheNote(sender:UIPanGestureRecognizer) {
//        
//        let point = sender.location(in: selfBgImage)
//        
//        
//        theDragNote?.center = point
//    }

    
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectBgImage"){
            _ = segue.destination as! SelfPostBgSelectVC
            
        }else if(segue.identifier == "newSelfNote"){
            let bgImageWithNotes = self.getBGimageWithPosts()
            let newPostSegue = segue.destination as! SelfNewPostVC
            newPostSegue.bgImage = bgImageWithNotes
        }else{
            
        }
    }
    // MARK: Get Bgselect image noti method
    func theChooseOne(notification:Notification) {
        
        let  BgImage:UIImage = notification.userInfo!["selfBg"] as! UIImage
        
        selfBgImage.image = BgImage
    }
    
    func getBGimageWithPosts() -> UIImage {
        bgSettingBtn.alpha = 0.0
        addNewPostBtn.alpha = 0.0
        deletePostBtn.alpha = 0.0
 //       self.tabBarController?.tabBar.isHidden = true
      let BGimageWithPosts = self.view.boardScreenShot()
        
        bgSettingBtn.alpha = 1
        addNewPostBtn.alpha = 1
        deletePostBtn.alpha = 1
        
        return BGimageWithPosts!
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
