//
//  PublicPostDetailVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/2.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class PublicPostDetailVC: UIViewController ,UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource{

    @IBOutlet weak var publicDetailCollectionV: UICollectionView!

    @IBOutlet weak var displayNoteV: Note!
    @IBOutlet weak var displayNoteImage: UIImageView!


     let getNoteDetail = GetNoteDetail()
        var publicPostID = Int16()
        var publicPost = Note()
        var publicPostT = NoteText()
        var imageForCell = [UIImage]()
        let cellSpace:CGFloat = 1
        var boardID = Int16()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
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
        
        override func viewWillAppear(_ animated: Bool) {
            
            DispatchQueue.main.async {
                self.publicPostT.isEditable = false
                self.displayNoteV.addSubview(self.publicPostT)
                let collectBgcolor = UIColor(cgColor: self.displayNoteV.posterColor.cgColor)
                self.publicDetailCollectionV.backgroundColor = collectBgcolor
                self.displayNoteV.addSubview(self.publicDetailCollectionV)
                
            }
        }
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        // MARK: Collectionview delegate method
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return imageForCell.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PublicDetailImageCell
            
            
            cell.detailImage.image = imageForCell[indexPath.row]
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            displayNoteImage.image = imageForCell[indexPath.row]
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let length = collectionView.frame.size.height
            let cellSize = CGSize(width: length, height: length)
            
            return cellSize
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return cellSpace
        }
        
}
