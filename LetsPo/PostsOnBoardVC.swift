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
    var detilPostID:Int16 = 0
    
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
        boardBgImage.image = bgImage
        postIDs = allPostsID
        for (index,imageview) in allPosts.enumerated(){
            
            imageview.isUserInteractionEnabled = true
            imageview.backgroundColor = UIColor.blue
            
            let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail))
            detailBtn.postID = allPostsID[index]
            boardBgImage.addSubview(imageview)
            
            imageview.addGestureRecognizer(detailBtn)
        }

        
        //    self.view.setNeedsDisplay()
        // Do any additional setup after loading the view.
    }

    
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
         detilPostID = gestureRecognizer.postID
        
        
        
        performSegue(withIdentifier: "postDetail", sender: nil)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postDetail"{
           let vc = segue.destination
            let detailController = vc.popoverPresentationController
            if detailController != nil {
                detailController?.delegate = self
            }else{
                
            }
        }
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
}
