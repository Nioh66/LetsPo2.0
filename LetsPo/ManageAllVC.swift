//
//  ManageAllVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/7.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreData

class ManageAllVC: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,Delegation {
    
    let cellId = "CellId"
    var colView: UICollectionView!
    var all = [[String:Any]]()
    var dataManagerCount = Int()
    var deleteBtnFlag:Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManagerCount = boardDataManager.count()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 5
        
        // 設置每個 cell 的尺寸
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/3 - 10.0, height: UIScreen.main.bounds.size.width/3 - 10.0)
        
        colView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        colView.delegate   = self
        colView.dataSource = self
        colView.register(ManageAllCell.self, forCellWithReuseIdentifier: cellId)
        colView.backgroundColor = UIColor.white
        
        self.view.addSubview(colView)
        setFlagAndGsr()
        allArrayData()
        
        
        
    }
    func allArrayData(){
        all.removeAll()
        for i in 0..<dataManagerCount {
            let item = boardDataManager.itemWithIndex(index: i)
            let id = item.board_Id
            let time = item.board_CreateTime
            if let img = item.board_ScreenShot {
                let imgWithData = UIImage(data: img as Data)
                all.append(["board_ScreenShot":imgWithData!,"board_CreateTime":time!,"board_Id":id])
            }
            print("\(i) = \(id)")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = ManageAllCell()
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! ManageAllCell
        let imageString = all[indexPath.item]["board_ScreenShot"] as! UIImage
        cell.backdroundImage.image = imageString
        
        setCellBtn(cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = boardDataManager.itemWithIndex(index: indexPath.item)
        
        let id = item.board_Id
        let storyboard = UIStoryboard(name: "ManagePost", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailViewController") as! ManageDetailViewController
        vc.selectIndexID = id
        navigationController?.pushViewController(vc, animated: false)
        
    }
    
    func deleteCell(_ cell: UICollectionViewCell) {
        guard let indexPath = colView.indexPath(for: cell) else {return}
        let board_id = all[indexPath.item]["board_Id"] as! Int16
        all.remove(at: indexPath.item)
        print("nearbyDic \(all)")
        colView.deleteItems(at: [indexPath])
        print("board_id: \(board_id)")
        let keyword = "\(board_id)"
        coreDataDeleteAndSaveMethod(board_id: keyword)
    }
    
    func coreDataDeleteAndSaveMethod(board_id:String){
        let searchField = "board_Id"
        let keyword = "\(board_id)"
        guard let result = boardDataManager.searchField(field: searchField, forKeyword: keyword) as? [BoardData] else{
            print("Result case to [NoteData] failure!!!!")
            return
        }
        for boardData:BoardData in result {
            let boardID = boardData.board_Id
            print("boardID \(boardID)")
            boardDataManager.deleteItem(item: boardData)
            boardDataManager.saveContexWithCompletion(completion: { (success) in
                let searchField = "note_BoardID"
                guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
                    print("Result case to [NoteData] failure!!!!")
                    return
                }
                for noteAttribute:NoteData in result{
                    let noteID = noteAttribute.note_ID
                    let boardID = noteAttribute.note_BoardID
                    guard let image = noteAttribute.note_Image else {
                        return
                    }
                    print("noteID \(noteID),boardID \(boardID)")
                    noteDataManager.deleteItem(item: noteAttribute)
                    noteDataManager.saveContexWithCompletion(completion: { (success) in
                        print("delete note with all image success")
                    })
                    self.removeImageformDocument(items: image)
                }
                self.dataManagerCount = boardDataManager.count()
                print("delete success")
            })
        }
    }
    
    func removeImageformDocument(items:NSData) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: items as Data),
            let myAlbum = json as? [String: Any] else{
                print("imageJSONData transform to result failure!!!!!")
                return
        }
        for index in 0 ..< myAlbum.count {
            guard let stringPath = myAlbum["Image\(index)"] as? String
                else {
                    print("------String transform to URL failure------")
                    return
            }
            let filePath = "\(dirPath)/\(stringPath)"
            do {
                try fileManager.removeItem(atPath: filePath)
                print("delete image OK")
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }
    
    func setFlagAndGsr(){
        deleteBtnFlag = true
        addDoubleTapGesture()
    }
    
    func setCellBtn(cell:ManageAllCell){
        
        if deleteBtnFlag == true {
            cell.deleteBtn.isHidden = true
        }else {
            cell.deleteBtn.isHidden = false
        }
        cell.delegation = self
    }
    
    func handleDoubleTap(gestureRecognizer:UITapGestureRecognizer){
        print("hideAllDeleteBtn")
        hideAllDeleteBtn()
    }
    
    func addDoubleTapGesture(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gestureRecognizer:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    func hideAllDeleteBtn() {
        if !deleteBtnFlag{
            deleteBtnFlag = true
            colView.reloadData()
        }
    }
    
    func showAllDeleteBtn(){
        deleteBtnFlag = false
        colView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.topItem?.title = "全部選集"
        navigationController?.navigationBar.backgroundColor = UIColor.white
        dataManagerCount = boardDataManager.count()
        
        allArrayData()
        colView.reloadData()

    }
    override func viewWillDisappear(_ animated: Bool) {
        hideAllDeleteBtn()
    }
    
}
