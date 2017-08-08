//
//  ManageAllCell.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/7.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

@objc protocol Delegation:class {
    
    func deleteCell(_ cell: UICollectionViewCell)
    func hideAllDeleteBtn()
    func showAllDeleteBtn()
}

class ManageAllCell: UICollectionViewCell {
    
    var backdroundImage = UIImageView()
    var deleteBtn:UIButton!
    
    weak var delegation : Delegation!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let w = Double(
            UIScreen.main.bounds.size.width)
        
        layer.cornerRadius = 4.0
        // 建立一個 UIImageView
        backdroundImage = UIImageView(frame: CGRect(x: 0, y: 0,width: w/3 - 10.0, height: w/3 - 10.0))
        backdroundImage.contentMode = .scaleToFill
        
        self.addSubview(backdroundImage)
        
        setCall()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCall(){
        addDeleteButton()
        addLongPressGesture()
    }
    
    // merk: fade animation with delete func
    func fadeAndDelete() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.delegation?.deleteCell(self)
            
        })
    }
    
    func addLongPressGesture(){
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longClick(longPress:)))
        self.addGestureRecognizer(longPress)
        
    }
    
    func longClick(longPress:UILongPressGestureRecognizer){
        print("showAllDeleteBtn")
        delegation.showAllDeleteBtn()
    }
    
    func addDeleteButton(){
        deleteBtn = UIButton(type: .custom)
        deleteBtn.frame = CGRect(x: 3, y: 3, width: 20, height: 20)
        deleteBtn.setImage(UIImage(named: "garbage"), for: .normal)
        deleteBtn.isHidden = true
        deleteBtn.addTarget(self, action: #selector(fadeAndDelete), for: .touchUpInside)
        
        self.addSubview(deleteBtn)
    }
    
}
