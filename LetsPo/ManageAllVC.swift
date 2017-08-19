//
//  ManageAllVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/7.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreData

class ManageAllVC: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/3 - 10.0, height: UIScreen.main.bounds.size.width/3)
        
        colView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        colView.delegate   = self
        colView.dataSource = self
        colView.register(ManageAllCell.self, forCellWithReuseIdentifier: cellId)
        colView.backgroundColor = UIColor.white
        
        self.view.addSubview(colView)

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
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.topItem?.title = "全部選集"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        dataManagerCount = boardDataManager.count()
        
        allArrayData()
        colView.reloadData()

    }
    override func viewWillDisappear(_ animated: Bool) {
        dismiss(animated: false, completion: nil)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
}
