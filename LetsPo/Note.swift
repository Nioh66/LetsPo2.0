//
//  Note.swift
//  NoteSharer
//
//  Created by Pin Liao on 21/06/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import Foundation
import UIKit

class Note: UIView {
    private var  mydrawTest:Int? = nil
    private let LINE_WIDTH:CGFloat = 2
//  var myText = UITextView()
//    private static var noteInstance:Note?
//
//    static func newNote() -> Note{
//        
//        
//        if noteInstance == nil{
//            noteInstance = Note()
//        }
//        return noteInstance!
//    }
    var shapeLayer = CAShapeLayer()
    var uploadcolor = UIColor()

    var borderColor = UIColor(red: 182.0/255.0, green: 153.0/255.0, blue: 75.0/255.0, alpha: 0.38)
    
    var darkBlueC = UIColor(red: 0.0/255.0,
                            green: 67.0/255.0,
                            blue: 88.0/255.0,
                            alpha: 1.0)
    var darkGreenC = UIColor(red: 31.0/255.0,
                             green: 138.0/255.0,
                             blue: 112.0/255.0,
                             alpha: 1.0)
    var lightGreenC = UIColor(red: 190.0/255.0,
                              green: 219.0/255.0,
                              blue: 57.0/255.0,
                              alpha: 1.0)
    var posterColor = UIColor(red: 253.0/255.0,
                              green: 237.0/255.0,
                              blue: 166.0/255.0,
                              alpha: 1.0)
    var orangeC = UIColor(red: 253.0/255.0,
                          green: 116.0/255.0,
                          blue: 0.0/255.0,
                          alpha: 1.0)
    var darkRedC = UIColor(red: 112.0/255.0,
                           green: 48.0/255.0,
                           blue: 48.0/255.0,
                           alpha: 1.0)
    var darkGreyC = UIColor(red: 47.0/255.0,
                            green: 52.0/255.0,
                            blue: 59.0/255.0,
                            alpha: 1.0)
    var lightGreyC = UIColor(red: 126.0/255.0,
                             green: 130.0/255.0,
                             blue: 122.0/255.0,
                             alpha: 1.0)
    var skinC = UIColor(red: 227.0/255.0,
                        green: 205.0/255.0,
                        blue: 164.0/255.0,
                        alpha: 1.0)
    var darkSkinC = UIColor(red: 199.0/255.0,
                            green: 121.0/255.0,
                            blue: 102.0/255.0,
                            alpha: 1.0)
    
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder:aDecoder)
        self.backgroundColor = UIColor.clear

    }
    
    override func draw(_ rect: CGRect) {
        //Add Note
        
        if(mydrawTest == nil){
    
        let path = UIBezierPath()

        let height = frame.height
        let width = frame.width

        path.move(to:CGPoint(x:0,y:0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width*0.7, y: height))
        path.addCurve(to: CGPoint(x: width*0.8, y: height*0.8), controlPoint1: CGPoint(x: width*0.8, y: height), controlPoint2:  CGPoint(x: width*0.8, y: height*0.8))
        path.addCurve(to: CGPoint(x: width, y: height*0.7), controlPoint1: CGPoint(x: width*0.8, y: height*0.75), controlPoint2:  CGPoint(x: width, y: height*0.9))
        
        path.move(to:CGPoint(x: width*0.7, y: height))
        path.addQuadCurve(to:CGPoint(x: width, y: height*0.7), controlPoint: CGPoint(x: width,y: height))
       
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))


        
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.fillColor = posterColor.cgColor
        shapeLayer.lineWidth = LINE_WIDTH;
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    
            mydrawTest = 1}
        else{
            return}
    }
    
    
    func giveMeFreshNewNote() {
        shapeLayer.fillColor = posterColor.cgColor

    }
    
    
    // MARK: Change background color
    func changeBgColor(button:UIButton){
        switch button.tag {
        case 101:
            shapeLayer.fillColor = darkBlueC.cgColor
            uploadcolor = darkBlueC
        case 102:
            shapeLayer.fillColor = darkGreenC.cgColor
            uploadcolor = darkGreenC

        case 103:
            shapeLayer.fillColor = lightGreenC.cgColor
            uploadcolor = lightGreenC

        case 104:
            shapeLayer.fillColor = posterColor.cgColor
            uploadcolor = posterColor

        case 105:
            shapeLayer.fillColor = orangeC.cgColor
            uploadcolor = orangeC

        case 106:
            shapeLayer.fillColor = darkRedC.cgColor
            uploadcolor = darkRedC

        case 107:
            shapeLayer.fillColor = darkGreyC.cgColor
            uploadcolor = darkGreyC

        case 108:
            shapeLayer.fillColor = lightGreyC.cgColor
            uploadcolor = lightGreyC

        case 109:
            shapeLayer.fillColor = skinC.cgColor
            uploadcolor = skinC

        default:
            shapeLayer.fillColor = darkSkinC.cgColor
            uploadcolor = darkSkinC

        }
    }
  

    
}




//  Resize the note
    extension UIView{
    func resizeNote() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 500, height: 500))
        self.drawHierarchy(in: CGRect(x: 0, y: 0, width: 500, height: 500) , afterScreenUpdates: false)
        
        let returnImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return returnImage
    }
        func resizeBoard() -> UIImage? {
            UIGraphicsBeginImageContext(CGSize(width: self.frame.size.width, height: self.frame.size.height))
            self.drawHierarchy(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height) , afterScreenUpdates: false)
            
            let returnImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            return returnImage
        }

    
}

