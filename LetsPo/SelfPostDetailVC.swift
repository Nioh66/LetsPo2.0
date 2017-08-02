//
//  SelfPostDetailVC.swift
//  LetsPo
//
//  Created by Pin Liao on 01/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfPostDetailVC: UIViewController ,UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource{

    @IBOutlet weak var selfDetailCollectionV: UICollectionView!
    
    @IBOutlet weak var displayNoteImage: UIImageView!
    @IBOutlet weak var displayNoteV: Note!
    let getSelfPost = SelfNoteDetail()
    var selfPostID = Int16()
    var selfPost = Note()
    var selfPostT = NoteText()
    var imageForCell = [UIImage]()
    let cellSpace:CGFloat = 1

    
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
        
        DispatchQueue.main.async {
            self.selfPostT.isEditable = false
            self.displayNoteV.addSubview(self.selfPostT)
            let collectBgcolor = UIColor(cgColor: self.displayNoteV.posterColor.cgColor)
            self.selfDetailCollectionV.backgroundColor = collectBgcolor
            self.displayNoteV.addSubview(self.selfDetailCollectionV)

  //          self.displayNoteV.setNeedsDisplay()
  //          self.displayNoteV.setNeedsLayout()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelfPostDetailImageCell
        
        
        cell.selfDetailImageV.image = imageForCell[indexPath.row]
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
