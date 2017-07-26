//
//  ManageCollectionViewCell.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
@objc protocol ActionDelegation:class {
    
    func deleteCell(_ cell: UICollectionViewCell)
    func hideAllDeleteBtn()
    func showAllDeleteBtn()
}


class ManageCollectionViewCell: UICollectionViewCell {

    var deleteBtn:UIButton!
    
    @IBOutlet weak var backdroundImage: UIImageView!
    
    weak var delegation : ActionDelegation!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        layer.cornerRadius = 4.0
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        self.clipsToBounds = true
        backdroundImage.contentMode = .scaleAspectFill
        
        setCall()
        
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
        
        delegation.showAllDeleteBtn()
    }
    
    
    func addDeleteButton(){
        deleteBtn = UIButton(type: .custom)
        deleteBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        deleteBtn.setImage(UIImage(named:"delete"), for: .normal)
        deleteBtn.isHidden = true
        deleteBtn.addTarget(self, action: #selector(fadeAndDelete), for: .touchUpInside)
        contentView.addSubview(deleteBtn)
    }

}
