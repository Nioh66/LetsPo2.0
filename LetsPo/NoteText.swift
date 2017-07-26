//
//  NoteText.swift
//  NoteSharer
//
//  Created by Pin Liao on 2017/7/10.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit

class NoteText: UITextView {
    
    let IMAGE_PADDING:CGFloat = 10
    
   // var myText = UITextView()
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame:frame ,textContainer:textContainer)
        
        
//        self.frame = frame
        // 背景顏色
        self.backgroundColor = UIColor.clear
        // 文字顏色
        self.textColor = UIColor.black
        // 文字字型及大小
        self.font = UIFont.boldSystemFont(ofSize: 14)
        //myText.font?.withSize(UIFont.systemFontSize)
        // 文字向左對齊
        self.textAlignment = .left
        // 預設文字內容
        self.text = "Enter Post content"
        // 適用的鍵盤樣式 這邊選擇預設的
        self.keyboardType = .default
        // 鍵盤上的 return 鍵樣式 這邊選擇預設的
        self.returnKeyType = .default
        

           }    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
       
 //       self.addSubview(myText)
    }
    
    // MARK: Change font color

    func changeFontColor(tag:Int){
        switch tag {
        case 111:
            self.textColor = UIColor.red
        case 112:
            self.textColor = UIColor.green
        case 113:
            self.textColor = UIColor.blue
        case 114:
            self.textColor = UIColor.cyan
        case 115:
            self.textColor = UIColor.yellow
        case 116:
            self.textColor = UIColor.brown
        case 117:
            self.textColor = UIColor.gray
        case 118:
            self.textColor = UIColor.lightGray
        case 119:
            self.textColor = UIColor.white
        default:
            self.textColor = UIColor.black
        }
    }
    
    func giveMeFreshNewNoteText() {
        self.textColor = UIColor.black
        self.text = "Enter Post content"
        self.font = UIFont.boldSystemFont(ofSize: 14)

    }

    func changeFontsize(value:CGFloat) {
        self.font = UIFont.boldSystemFont(ofSize: value)
    }
    
    // MARK: addImage
    func addImageInText(image:UIImage ,NoteView:Note){
        

        let textAttachment = NSTextAttachment()
        var attributedString :NSMutableAttributedString!
        attributedString = NSMutableAttributedString(attributedString:self.attributedText)
        
        var fixedImage = image
        
        fixedImage = UIImage.fixOrientation(ofImage: fixedImage)
        

        
        textAttachment.image = fixedImage
        
        
        
        let oldWidth = textAttachment.image!.size.width;
        
        // 10px for padding
//        let scaleFactor = oldWidth / (self.frame.size.width - IMAGE_PADDING);
        let scaleFactor = oldWidth / (self.frame.size.width - 100);

        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        textAttachment.accessibilityElementCount()
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        self.attributedText = attributedString;
        
        NoteView.addSubview(self)
        
    }
}

