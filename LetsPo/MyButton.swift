//
//  MyButton.swift
//  NoteSharer
//
//  Created by Pin Liao on 2017/7/17.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit

class MyButton: UIButton {

    init(frame:CGRect,title:String,tag:Int,bgColor:UIColor) {
        super.init(frame:frame)
        
        self.frame = frame
        self.tag = tag
        self.backgroundColor = bgColor
        self.setTitle(title, for: .normal)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
