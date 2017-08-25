//
//  PostDetailVC.swift
//  LetsPo
//
//  Created by Pin Liao on 31/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {
    
    let getPost = GetNoteDetail()
    var detilPostID:Int16 = 0
    var post = Note()
    var postT = NoteText()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        post.frame = CGRect(x: 5, y: 5, width: 300, height: 300)
        postT.frame = CGRect(x: 0, y: 0, width: post.frame.size.width, height: post.frame.size.height)
        
        
        guard let postBg = getPost.getNoteSetting(boardID: 1, noteID: 1,note:post) else{
            print("getNoteSetting fail")
            return
        }
        
        
        
        let postText = getPost.getNoteText(boardID: 1, noteID: 1, noteText: postT)
        _ = getPost.getNoteImage(boardID: 1, noteID: 1)
        
        postT = postText!
        post.posterColor = postBg.posterColor
        
        
        view.addSubview(post)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.post.addSubview(self.postT)
            
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
