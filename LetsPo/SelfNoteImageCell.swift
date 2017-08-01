//
//  SelfNoteImageCell.swift
//  LetsPo
//
//  Created by Pin Liao on 01/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfNoteImageCell: UICollectionViewCell {

    @IBOutlet weak var selfNoteImageV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selfNoteImageV.layer.cornerRadius = 10.0
        selfNoteImageV.layer.masksToBounds = true
    }
}
