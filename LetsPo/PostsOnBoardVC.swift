//
//  PostsOnBoardVC.swift
//  LetsPo
//
//  Created by Pin Liao on 28/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class PostsOnBoardVC: UIViewController ,UIPopoverPresentationControllerDelegate{
    
    let getBoardPosts = GetBoardNotes()
    var postIDs = [Int16]()
    var detailPostID:Int16 = 0
    
    let test001 = Note()
    
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var boardBgImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let postsScreenShot = getBoardPosts.getNotesSelfie(boardID: 1),
            let allPosts = getBoardPosts.presentNotes(boardID: 1, selfies: postsScreenShot),
            let bgImage = getBoardPosts.getBgImage(boardID: 1),
            let allPostsID = getBoardPosts.getNotesID(boardID: 1)
            else{
                return
        }
        
        boardBgImage.isUserInteractionEnabled = true
        
        boardBgImage.image = bgImage
        postIDs = allPostsID
        for (index,imageview) in allPosts.enumerated(){
            print(index)
            imageview.isUserInteractionEnabled = true
            imageview.backgroundColor = UIColor.clear
            
            let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
            detailBtn.postImageView = imageview
            detailBtn.postID = allPostsID[index]
            boardBgImage.addSubview(imageview)
            
            imageview.addGestureRecognizer(detailBtn)
        }

        
        
                //    self.view.setNeedsDisplay()
        // Do any additional setup after loading the view.
    }
    func imageViewAddGesture(targetView:UIImageView , index:Int) {

    
    }
    
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
         detailPostID = gestureRecognizer.postID
        
        print("GoToDetail did press")
        
        let detailPostVC =  storyboard?.instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailVC
        detailPostVC.modalPresentationStyle = .popover
        let popDetailPostVC = detailPostVC.popoverPresentationController
        popDetailPostVC?.delegate = self
        popDetailPostVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        popDetailPostVC?.sourceView = detailNoteAppearPoint
        popDetailPostVC?.sourceRect = detailNoteAppearPoint.bounds
        present(detailPostVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


class TapToShowDetail: UITapGestureRecognizer {
    var postID : Int16 = 0
    var postImageView:UIImageView? = nil
}
