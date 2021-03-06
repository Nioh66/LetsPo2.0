//
//  MapDetailViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class MapDetailViewController: UIViewController ,UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backdroundImage: UIImageView!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    var dataManagerCount = Int()
    var selectIndexID = Int16()
    var selectMember_id = Int()
    var image = UIImage()
    var boardTitle = String()
    let alamoMachine = AlamoMachine()
    var allNotesImageView = [UIImageView]()
    var allNotesID = [Int16]()
    let advanceImageView = AdvanceImageView()
    var friendName = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManagerCount = boardDataManager.count()
        
        let friendData = friendDataManager.searchField(field: "friend_FriendID", forKeyword: "\(selectMember_id)") as! [FriendData]
        
        for data:FriendData in friendData{
                friendName = data.friend_FriendName!
        }
        
        friendNameLabel.text = "From: \(friendName)"
        
        backdroundImage.image = image
        titleLabel.text = boardTitle
        backdroundImage.isUserInteractionEnabled = true
        let noteDic:[String:Any] = ["Board_ID":selectIndexID]
        
        advanceImageView.prepareIndicatorView(view: self.view)
        
        alamoMachine.doPostJobWith(urlString: alamoMachine.DOWNLOAD_PUBLICNOTES, parameter: noteDic) { (error, rsp) in
            
            if error != nil{
                print(error!)
                self.advanceImageView.advanceStop(view: self.view)
                return
            }
            guard let response = rsp?["AllData"] as? [String:Any] else{
                return
            }
            self.getNoteDetail(notesData: response)
           
            DispatchQueue.main.async {
                
                for (index,imageview) in self.allNotesImageView.enumerated(){
                    imageview.isUserInteractionEnabled = true
                    imageview.backgroundColor = UIColor.clear
                    let detailBtn = TapToShowDetail(target: self, action: #selector(self.goToDetail(gestureRecognizer:)))
                    detailBtn.postImageView = imageview
                    detailBtn.postID = self.allNotesID[index]
                    detailBtn.boardID = self.selectIndexID
                    
                    imageview.addGestureRecognizer(detailBtn)
                    self.backdroundImage.addSubview(imageview)
                    self.advanceImageView.advanceStop(view: self.view)

                }
                print(self.allNotesID)
                print(self.allNotesImageView)
            }
        }
    }
    
    func getNoteDetail(notesData:[String:Any]){
        
        
        
        for i in 0..<notesData.count{
            
            guard let noteData = notesData["Note\(i)"] as? [String:Any] else {
                return
            }
            
            guard let noteIDS = noteData["Note_ID"] as? String,
                let noteSelfieS = noteData["Note_Selfie"] as? String,
                let noteXS = noteData["Note_X"] as? String,
                let noteYS = noteData["Note_Y"] as? String else{
                    print("Case from noteData failure!!!!!")
                    return
            }
            
            guard
                let noteSelfie = NSData(base64Encoded: noteSelfieS, options: []),
                let noteID = Int16(noteIDS),
                let noteX = Double(noteXS),
                let noteY = Double(noteYS) else{
                    print("Case from String failure!!!!!")
                    return
            }
                let noteSelfieView = UIImageView(frame: CGRect(x: noteX, y: noteY, width: 100, height: 100))
                noteSelfieView.image = UIImage(data: noteSelfie as Data)
                allNotesImageView.append(noteSelfieView)
                allNotesID.append(noteID)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func goToDetail(gestureRecognizer:TapToShowDetail){
        let detailPostID = gestureRecognizer.postID
        let detailboardID = gestureRecognizer.boardID
        
        
        let publicPostDetailVC =  storyboard?.instantiateViewController(withIdentifier: "FriendsPostDetailVC") as! FriendsPostDetailVC
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        
    }
       
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    

}
