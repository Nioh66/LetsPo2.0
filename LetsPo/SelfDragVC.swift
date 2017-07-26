//
//  SelfDragVC.swift
//  LetsPo
//
//  Created by Pin Liao on 24/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfDragVC: UIViewController {

    
    var posterX:CGFloat = 150
    var posterY:CGFloat = 150
    let posterEdge:CGFloat = 100
    var bgImage:UIImage!
    var resizeNote:UIImage!
    var theDragNote = UIImageView()

    @IBOutlet weak var selfBgImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selfBgImage.image = bgImage
        
        theDragNote.frame = CGRect(x: posterX, y: posterY, width: posterEdge, height: posterEdge)
        theDragNote.image = resizeNote
        theDragNote.isUserInteractionEnabled = true
        
        selfBgImage.addSubview(theDragNote)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panTheNote))
        
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        
        theDragNote.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view.
    }

    func panTheNote(sender:UIPanGestureRecognizer) {
        
        let point = sender.location(in: selfBgImage)
        
        
        theDragNote.center = point
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
