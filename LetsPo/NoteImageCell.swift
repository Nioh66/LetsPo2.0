//
//  NoteImageCell.swift
//  LetsPo
//
//  Created by Pin Liao on 26/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class NoteImageCell: UICollectionViewCell {
    
    @IBOutlet weak var noteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        noteImage.layer.cornerRadius = 10.0
        noteImage.layer.masksToBounds = true
        
        // Initialization code
    }

}
