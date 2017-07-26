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
 //   private var  mydrawTest:Int? = nil
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
    

    var borderColor = UIColor(red: 182.0/255.0, green: 153.0/255.0, blue: 75.0/255.0, alpha: 0.38)
    var posterColor = UIColor(red: 253.0/255.0, green: 237.0/255.0, blue: 166.0/255.0, alpha: 1.0)
    
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder:aDecoder)
        self.backgroundColor = UIColor.clear

    }
    
    override func draw(_ rect: CGRect) {
        //Add Note
        
   //     if(mydrawTest == nil){
    
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
    }
//            mydrawTest = 1}
//        else{
//            return}
//    }
    
    
    func giveMeFreshNewNote() {
        shapeLayer.fillColor = posterColor.cgColor

    }
    
    
    // MARK: Change background color
    func changeBgColor(button:UIButton){
        switch button.tag {
        case 101:
            shapeLayer.fillColor = UIColor.red.cgColor
        case 102:
            shapeLayer.fillColor = UIColor.green.cgColor
        case 103:
            shapeLayer.fillColor = UIColor.blue.cgColor
        case 104:
            shapeLayer.fillColor = UIColor.cyan.cgColor
        case 105:
            shapeLayer.fillColor = posterColor.cgColor
        case 106:
            shapeLayer.fillColor = UIColor.brown.cgColor
        case 107:
            shapeLayer.fillColor = UIColor.gray.cgColor
        case 108:
            shapeLayer.fillColor = UIColor.lightGray.cgColor
        case 109:
            shapeLayer.fillColor = UIColor.white.cgColor
        default:
            shapeLayer.fillColor = UIColor.black.cgColor
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

