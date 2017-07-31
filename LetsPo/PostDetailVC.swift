//
//  PostDetailVC.swift
//  LetsPo
//
//  Created by Pin Liao on 31/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class PostDetailVC: UIViewController {

    @IBOutlet weak var noteView: Note!
    let getPost = GetNoteDetail()
    var detilPostID:Int16 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let postBg = getPost.getNoteSetting(boardID: 1, noteID: 1) else{
            print("getNoteSetting fail")
            return
        }
        let postText = getPost.getNoteText(boardID: 1, noteID: 1)
        let postImage = getPost.getNoteImage(boardID: 1, noteID: 1)
        noteView = postBg
        
        noteView.addSubview(postText!)
        
        
        //        DispatchQueue.main.async {
        //            guard let postBg = self.getPost.getNoteSetting(boardID: 27, noteID: 1) else{
        //                print("getNoteSetting fail")
        //                return
        //            }
        //            let postText = self.getPost.getNoteText(boardID: 27, noteID: 1)
        //            let postImage = self.getPost.getNoteImage(boardID: 27, noteID: 1)
        //            self.noteView = postBg
        //
        //            self.noteView.addSubview(postText!)
        //            self.noteView.setNeedsDisplay()
        //        }
        //
        
        
        
        self.noteView.setNeedsDisplay()

        // Do any additional setup after loading the view.
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
