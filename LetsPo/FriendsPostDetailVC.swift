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
    let alamoMachine = AlamoMachine()
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
        publicPostT.frame = CGRect(x: 0, y: 3, width: displayNoteV.frame.size.width, height: displayNoteV.frame.size.height*0.77)
    }
    
    func noteDetailMachine(noteData:[String:Any],note:Note,noteText:NoteText) {
        imageForCell.removeAll()
        guard let noteContent = noteData["Note_Content"] as? String,
            let noteFontColorS = noteData["Note_FontColor"] as? String,
            let noteFontSizeS = noteData["Note_FontSize"] as? String,
            let noteBgColorS = noteData["Note_BgColor"] as? String,
            let noteImageJSON = noteData["Note_Image"] as? String else{
                print("Case from noteData failure!!!!!")
                return
        }
        
        guard let noteFontColorNSData = NSData(base64Encoded: noteFontColorS, options: []),
            let noteFontColor = NSKeyedUnarchiver.unarchiveObject(with: noteFontColorNSData as Data) as? UIColor,
            let noteFontSize = Double(noteFontSizeS),
            let noteBgColorNSData = NSData(base64Encoded: noteBgColorS, options: [])
             else{
                print("Case from String failure!!!!!")
                return
        }
        let noteBgColor = noteDataManager.reverseColorDataToColor(data: noteBgColorNSData)
        
        
        if noteImageJSON != ""{
            let noteImageJ = convertToDictionary(text: noteImageJSON)
            
            guard let noteImage = noteImageJ as? [String:String] else {
                return
            }
            
            alamoMachine.downloadImage(imageDic: noteImage, complete: { (error, rspImages) in
                if error != nil{
                    return
                }else{
                    guard let theImages = rspImages else{
                        return
                    }
                    self.imageForCell = theImages
                    note.posterColor = noteBgColor
                    note.backgroundColor = UIColor.clear
                    noteText.text = noteContent
                    noteText.textColor = noteFontColor
                    noteText.font = UIFont.boldSystemFont(ofSize: CGFloat(noteFontSize))
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.displayNoteV = note
                        self.publicPostT = noteText
                        self.publicPostT.isEditable = false
                        self.displayNoteV.addSubview(self.publicPostT)
                    }
                }})
        }else{
            note.posterColor = noteBgColor
            note.backgroundColor = UIColor.clear
            noteText.text = noteContent
            noteText.textColor = noteFontColor
            noteText.font = UIFont.boldSystemFont(ofSize: CGFloat(noteFontSize))
        //    DispatchQueue.main.async {
                self.displayNoteV = note
                self.publicPostT = noteText
                self.publicPostT.isEditable = false
                self.displayNoteV.addSubview(self.publicPostT)
        //    }
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
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let noteIDDic:[String:Any] = ["Note_ID":publicPostID]
        
        alamoMachine.doPostJobWith(urlString: alamoMachine.DOWNLOAD_PUBLICNOTEDETAIL, parameter: noteIDDic) { (error, response) in
          
            if error != nil{
                print(error!)
                return
            }
            guard let noteData = response?["NoteData"] as? [String:Any] else{
                return
            }
            self.noteDetailMachine(noteData: noteData, note: self.publicPost, noteText: self.publicPostT)
            
        }
        

        //        DispatchQueue.main.async {
        //            self.publicPostT.isEditable = false
        //            self.displayNoteV.addSubview(self.publicPostT)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
