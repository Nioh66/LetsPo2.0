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
        
        
        let backView = UIView()
        backView.center = view.center
        print(view.center.x)
        print(view.center.y)
        
        backView.frame = CGRect(x: view.center.x - 50 , y: view.center.y - 50, width: 100.0, height: 100.0)
        backView.backgroundColor = UIColor(colorLiteralRed: 150.0/255, green: 150.0/255, blue: 150.0/255, alpha: 0.8)
        backView.layer.cornerRadius = 4.0
        
        advanceImageView.activityIndicatorViewStyle = .whiteLarge
        advanceImageView.color = UIColor.white
        advanceImageView.hidesWhenStopped = true
        advanceImageView.center = view.center
        
        
        advanceContent.addSubview(backView)
        advanceContent.addSubview(advanceImageView)
        
        advanceImageView.startAnimating()
    }
    
    func advanceStart(){
        advanceImageView.startAnimating()
    }
    func advanceStop(view:UIView){
        advanceImageView.stopAnimating()
        advanceContent.removeFromSuperview()
        advanceImageView.removeFromSuperview()
    }
    func timerAdvanceImageView(view:UIView) {
        prepareIndicatorView(view: view)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (Timer) in
            self.advanceStop(view:view)
        }
    }

}
