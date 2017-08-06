//
//  SelfPostDetailVC.swift
//  LetsPo
//
//  Created by Pin Liao on 01/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfPostDetailVC: UIViewController ,UICollectionViewDelegate ,UICollectionViewDataSource{
    private var collectionViewLayout : PostsLinearFlowLayout!
    //    private var dataSource: Array<Int>!
    private var pageWidth : CGFloat{
        return  self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    
    private var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }
    var animationsCount = 0
    


    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var displayNoteV: Note!
    let getSelfPost = SelfNoteDetail()
    var selfPostID = Int16()
    var selfPost = Note()
    var selfPostT = NoteText()
    var imageForCell = [UIImage]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  selfPost.frame = CGRect(x: 5, y: 5, width: 300, height: 300)
        selfPostT.frame = CGRect(x: 0, y: 0, width: displayNoteV.frame.size.width*0.8, height: displayNoteV.frame.size.height*0.7)
        
        
        guard let postBg = getSelfPost.getSelfNoteBg(noteID: selfPostID, note: displayNoteV),
            let postText = getSelfPost.getSelfNoteText(noteID: selfPostID, noteText: selfPostT)
            else{
            print("getNoteSetting fail")
            return
        }
        
        displayNoteV = postBg
        selfPostT = postText
        if let postImage = getSelfPost.getNoteImage(noteID: selfPostID){
        imageForCell = postImage
            
            
            //self.configureDataSource()
            self.configureCollectionView()
            self.configurePageControl()
            

        }
        
   //   displayNoteV.addSubview(selfPostT)
        
        

//        selfPostT = postText!
//        selfPost.posterColor = postBg.posterColor
//        
//        displayNoteV = selfPost
      //  view.addSubview(selfPost)
        

        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async {
            self.selfPostT.isEditable = false
            self.displayNoteV.addSubview(self.selfPostT)

  //          self.displayNoteV.setNeedsDisplay()
  //          self.displayNoteV.setNeedsLayout()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Collectionview delegate method
    
    
    
    func configureCollectionView() {
        self.collectionView.register(UINib.init(nibName: "AllPostsImageCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.collectionViewLayout = PostsLinearFlowLayout.configureLayout(collectionView: self.collectionView, itemSize: CGSize.init(width: 180, height: 180), minimumLineSpacing: 0)
    }
    
    //    func configureDataSource ()  {
    //        self.dataSource = [Int]()
    //        for i in 0..<imageForCell.count{
    //            self.dataSource.append(i)
    //        }
    //    }
    
    func configurePageControl() {
        self.pageControl.numberOfPages = imageForCell.count
    }
    
    private func scrollToPage(page: Int, animated: Bool) {
        self.collectionView.isUserInteractionEnabled = false
        self.animationsCount += 1
        let pageOffset = CGFloat(page) * self.pageWidth - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPoint(x: pageOffset, y: 0), animated: true)
        self.pageControl.currentPage = page
        //        self.configureButtons()
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
            
            //          self.scrollToPage(page: selectedPage, animated: true)
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
        //       self.configurebtn
        
    }
    
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return cellSpace
//    }
//    
    }
