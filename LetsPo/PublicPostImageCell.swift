//
//  PublicPostImageCell.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/2.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class PublicPostImageCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.layer.cornerRadius = 10.0
        postImage.layer.masksToBounds = true
    }
}
