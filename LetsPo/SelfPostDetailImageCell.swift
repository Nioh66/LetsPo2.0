//
//  SelfPostDetailImageCell.swift
//  LetsPo
//
//  Created by Pin Liao on 02/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfPostDetailImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var selfDetailImageV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selfDetailImageV.layer.cornerRadius = 10.0
        selfDetailImageV.layer.masksToBounds = true
    }
}
