//
//  GuideViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/9/8.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var startButton: UIButton!
    
    fileprivate var scrollView: UIScrollView!
    
    fileprivate let numOfPages = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = self.view.bounds
        
        scrollView = UIScrollView(frame: frame)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        scrollView.contentOffset = CGPoint.zero
        // 將 scrollView 的 contentSize 設為螢幕寬度的5倍
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(numOfPages), height: frame.size.height)
        
        scrollView.delegate = self
        
        for index  in 0..<numOfPages {
            let imageView = UIImageView(image: UIImage(named: "GuideImage\(index + 1)"))
            imageView.frame = CGRect(x: frame.size.width * CGFloat(index), y: 0, width: frame.size.width, height: frame.size.height)
            scrollView.addSubview(imageView)
        }
        
        self.view.insertSubview(scrollView, at: 0)
        
        
//        startButton.layer.cornerRadius = 15.0
        // 隱藏開始按鈕
        startButton.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        self.dismiss(animated: false, completion: nil)
        present(tabBarVC, animated: true, completion: nil)
        

    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

extension GuideViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 隨著滑動改變pageControl的狀態
        
        pageControl.currentPage = Int(offset.x / self.view.frame.size.width)
        
        // 因為currentPage是從0開始，所以numOfPages減1
        if pageControl.currentPage == numOfPages - 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.startButton.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.startButton.alpha = 0.0
            })
        }
    }
}
