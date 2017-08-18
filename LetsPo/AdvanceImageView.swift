//
//  AdvanceImageView.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class AdvanceImageView: UIImageView {
    let advanceImageView = UIActivityIndicatorView()
    let advanceContent = UIView()

    func prepareIndicatorView(view:UIView){
        advanceContent.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        advanceContent.backgroundColor = UIColor(colorLiteralRed: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.1)
        view.addSubview(advanceContent)
        
        if advanceImageView.isAnimating {
            print("這這這這這這這這這這這這")
            advanceImageView.removeFromSuperview()
        }
        
        // 再調整
//        let backView = UIImageView()
//        backView.center = view.center
//        backView.frame = CGRect(x: view.center.x, y: view.center.y, width: 100.0, height: 100.0)
//        backView.backgroundColor = UIColor.lightGray
//        backView.layer.cornerRadius = 4.0
        

        advanceImageView.activityIndicatorViewStyle = .whiteLarge
        advanceImageView.color = UIColor.white
        advanceImageView.hidesWhenStopped = true
        advanceImageView.center = view.center
//        backView.addSubview(advanceImageView)
        
        advanceContent.addSubview(advanceImageView)
        advanceImageView.startAnimating()
    }
    
    func advanceStart(){
        advanceImageView.startAnimating()
    }
    func advanceStop(){
        advanceImageView.stopAnimating()
    }


}
