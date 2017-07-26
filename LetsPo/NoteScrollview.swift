//
//  NoteScrollview.swift
//  NoteSharer
//
//  Created by Pin Liao on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit

class NoteScrollview :Note {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let textScrollview = UIScrollView()
        
        textScrollview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height*0.75)
        textScrollview.contentSize = CGSize(width: frame.size.width, height: frame.size.height)
        
        textScrollview.showsVerticalScrollIndicator = true
        textScrollview.showsHorizontalScrollIndicator = false
        //    textScrollview.indicatorStyle = UIColor.black
        textScrollview.isScrollEnabled = true
        textScrollview.bounces = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
//        self.addSubview(textScrollview)
        
        

    }
    
    
}
