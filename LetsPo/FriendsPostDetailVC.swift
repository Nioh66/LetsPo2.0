//
//  FriendsPostDetailVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class FriendsPostDetailVC: UIViewController,UICollectionViewDelegate ,UICollectionViewDataSource {
    
    @IBOutlet weak var displayNoteV: Note!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var collectionViewLayout : PostsLinearFlowLayout!
    private var pageWidth : CGFloat{
        return  self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    
    private var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }
    var animationsCount = 0
    
    let getNoteDetail = GetNoteDetail()
    var publicPostID = Int16()
    var publicPost = Note()
    var publicPostT = NoteText()
    var imageForCell = [UIImage]()
    let cellSpace:CGFloat = 1
    var boardID = Int16()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.configureDataSource()
        self.configureCollectionView()
        self.configurePageControl()
        
        
        //  selfPost.frame = CGRect(x: 5, y: 5, width: 300, height: 300)
        publicPostT.frame = CGRect(x: 0, y: 0, width: displayNoteV.frame.size.width*0.8, height: displayNoteV.frame.size.height*0.7)
        
        guard let postBg = getNoteDetail.getNoteSetting(boardID: boardID, noteID: publicPostID, note: displayNoteV),
            let postText = getNoteDetail.getNoteText(boardID: boardID, noteID: publicPostID, noteText: publicPostT)
            else{
                print("getNoteSetting fail")
                return
        }
        
        
        
        displayNoteV = postBg
        publicPostT = postText
        if let postImage = getNoteDetail.getNoteImage(boardID: boardID, noteID: publicPostID){
            imageForCell = postImage
        }
        
    }
    
    func configureCollectionView() {
        self.collectionView.register(UINib.init(nibName: "AllPostsImageCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.collectionViewLayout = PostsLinearFlowLayout.configureLayout(collectionView: self.collectionView, itemSize: CGSize.init(width: 180, height: 180), minimumLineSpacing: 0)
    }
    
    func configurePageControl() {
        self.pageControl.numberOfPages = imageForCell.count
    }
    
    private func scrollToPage(page: Int, animated: Bool) {
        self.collectionView.isUserInteractionEnabled = false
        self.animationsCount += 1
        let pageOffset = CGFloat(page) * self.pageWidth - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPoint(x: pageOffset, y: 0), animated: true)
        self.pageControl.currentPage = page
    }
    
    // MARK: collectionView datasource method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageForCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AllPostsImageCell
        cell.postImageV.layer.cornerRadius = 10.0
        cell.postImageV.layer.masksToBounds = true
        cell.postImageV.image = imageForCell[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking {
            return
        }
        
        let selectedPage = indexPath.row;
        
        if selectedPage == self.pageControl.currentPage {
            //可加popview
            NSLog("Did select center item")
        }
        else {
 
        }
    }
    
    // MARK: collectionView delegate method
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if ((self.animationsCount - 1) == 0) {
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(self.contentOffset / self.pageWidth)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.publicPostT.isEditable = false
            self.displayNoteV.addSubview(self.publicPostT)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
