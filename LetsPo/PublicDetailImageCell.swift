//
//  PublicDetailImageCell.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/2.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class PublicDetailImageCell: UICollectionViewCell {
    
    @IBOutlet weak var detailImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        detailImage.layer.cornerRadius = 10.0
        detailImage.layer.masksToBounds = true
    }
    
    
}
