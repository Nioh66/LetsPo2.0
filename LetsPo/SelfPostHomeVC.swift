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

      override func viewDidLoad() {
        super.viewDidLoad()
        self.addingObserver()
        self.navigationController?.isNavigationBarHidden = true
        selfBgImage.isUserInteractionEnabled = true

        
        
        
        
        
        if let notes = getAllPosts.getSelfboardNotes() {
            
            for (index,imageV) in notes.enumerated(){
                imageV.isUserInteractionEnabled = true
                imageV.backgroundColor = UIColor.clear
                
                let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
                detailBtn.postImageView = imageV

                selfBgImage.addSubview(imageV)
                imageV.addGestureRecognizer(detailBtn)

            }
        }
        
        
    }
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
        detailSelfPostID = gestureRecognizer.postID
        
        print("GoToDetail did press")
        
        let detailSelfPostVC =  storyboard?.instantiateViewController(withIdentifier: "SelfPostDetailVC") as! SelfPostDetailVC
        detailSelfPostVC.modalPresentationStyle = .popover
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
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
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


    }
    
    
    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: selfBgImage)
        
        
        theDragNote?.center = point
    }

    
    
   
    
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
