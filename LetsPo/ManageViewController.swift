//
//  ManageViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

let identifier = "identifier"

class ManageViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, ScrollPagerDelegate,LocationManagerDelegate {
    
    @IBOutlet weak var noticeImageView: UIImageView!
    @IBOutlet weak var scrollPager: ScrollPager!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var allBtn: UIButton!
    var dataManagerCount = Int()
    let locationManager = LocationManager()
    
    var deleteBtnFlag:Bool!
    var recent = [UIImage]()
    var recentArr = [String]()
    var nearbyDic = [[String:Any]]()
    var count = 0
    var count1 = 0
    var secondTime = false
    var formMap = false
    var scrollPage = Int()
    
    var collectionViewTwo:UICollectionView!
    var collectionViewOne: UICollectionView!
    let dismissSelf = Notification.Name("dismissSelf")
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: dismissSelf,object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.clear
        locationManager.delegate = self
        
        // register three collectionView
        collectionViewOne = UICollectionView(frame: self.view.frame, collectionViewLayout: FlowLayout())
        collectionViewOne.register(UINib.init(nibName: "ManageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        collectionViewOne.backgroundColor = UIColor.clear
        collectionViewOne.delegate = self
        collectionViewOne.dataSource = self
        scrollView.addSubview(collectionViewOne)
        
        collectionViewTwo = UICollectionView(frame: self.view.frame, collectionViewLayout: FlowLayout())
        collectionViewTwo.register(UINib.init(nibName: "ManageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        collectionViewTwo.delegate = self
        collectionViewTwo.dataSource = self
        collectionViewTwo.backgroundColor = UIColor.clear
        self.view.addSubview(collectionViewTwo)
        
        //  全部選集的按鈕
        allBtn.setTitleColor(UIColor.lightGray, for: .highlighted)
        allBtn.setTitleColor(UIColor.white, for: .normal)
        allBtn.adjustsImageWhenHighlighted = false
        
        dataManagerCount = boardDataManager.count()
        
         NotificationCenter.default.addObserver(self, selector: #selector(userPressDeleteBtn), name: dismissSelf, object: nil)
        
        // assign view to each page
        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("RECENT", collectionViewOne),
            ("NEARBY", collectionViewTwo)
            ])
        
    }
    func userPressDeleteBtn(){
        dataManagerCount = boardDataManager.count()
        arrayImageData()
    }
    
    func arrayImageData(){
        // 每次刷新都先移掉所有內容
        recent.removeAll()
        recentArr.removeAll()
        // 只取前五張近期的留言板
        if dataManagerCount >= 5 {
            for i in 0..<5 {
                let item = boardDataManager.itemWithIndex(index: i)
                if let img = item.board_ScreenShot {
                    let imgWithData = UIImage(data: img as Data)
                    recent.append(imgWithData!)
                }
                let title = item.board_Title ?? ""
                recentArr.append(title)
            }
        }else {
            for i in 0..<dataManagerCount {
                let item = boardDataManager.itemWithIndex(index: i)
                if let img = item.board_ScreenShot {
                    let imgWithData = UIImage(data: img as Data)
                    recent.append(imgWithData!)
                    let title = item.board_Title ?? ""
                    recentArr.append(title)
                }
            }
        }
        reloadAllData()
    }
    
    func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {
        print("scrollPager index changed: \(changedIndex)")
        scrollPage = changedIndex
        firstTimeNoticeImage()

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = Int()
        
        if collectionView == self.collectionViewOne {
            count = recent.count
        }
        else if collectionView == self.collectionViewTwo {
            count = nearbyDic.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = ManageCollectionViewCell()
        
        if collectionView == self.collectionViewOne {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ManageCollectionViewCell
            let imageString = recent[indexPath.item]
            cell.backdroundImage.image = imageString
            let title = recentArr[indexPath.item]
            cell.titleLabel.text = title
            
        }else if collectionView == self.collectionViewTwo {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ManageCollectionViewCell
            let imageString = nearbyDic[indexPath.item]
            let imageName = imageString["BgPic"] as! UIImage
            let title = imageString["title"]
            cell.backdroundImage.image = imageName
            cell.titleLabel.text = title as? String
            
        }
        
        return cell
    }
    
    
    //Mark: - remove object form indexPath
    func deleteCell(_ cell: UICollectionViewCell) {
        if let indexPath = collectionViewOne.indexPath(for: cell) {
            recent.remove(at: indexPath.item)
            collectionViewOne.deleteItems(at: [indexPath])
            // 用按下的indexPath 來取得board_id 並一併刪除note
            let item = boardDataManager.itemWithIndex(index: indexPath.row)
            let keyword = "\(item.board_Id)"
            coreDataDeleteAndSaveMethod(board_id: keyword)
            
        }else if let indexPath = collectionViewTwo.indexPath(for: cell) {
            // 因為 nearbyDic 有經過排序 所以在排序前就先記錄原本的 indexPath 再透過原本存的 indexPath 來刪除
            let board_id = nearbyDic[indexPath.item]["board_id"] as! Int16
            nearbyDic.remove(at: indexPath.item)
            collectionViewTwo.deleteItems(at: [indexPath])
            let keyword = "\(board_id)"
            coreDataDeleteAndSaveMethod(board_id: keyword)
        }
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
            //先刪除該留言板
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
                    var imageData:NSData? = nil
                    if let image = noteAttribute.note_Image {
                        imageData = image
                    }
                    print("noteID \(noteID),boardID \(boardID)")
                    // 刪除留言板上所有的note
                    noteDataManager.deleteItem(item: noteAttribute)
                    noteDataManager.saveContexWithCompletion(completion: { (success) in
                        print("delete note with all image success")
                    })
                    if imageData != nil {
                        print("imageData not nil")
                        self.removeImageformDocument(items:imageData!)
                    }
                }
                self.dataManagerCount = boardDataManager.count()
                self.locationManager.startUpdate()
                self.arrayImageData()
                self.reloadAllData()
                print("delete success")
            })
        }
    }
    // 刪除存在 Document 資料夾的照片
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.section),\(indexPath.item)")
        if collectionView == self.collectionViewTwo {
            let board_Id = nearbyDic[indexPath.item]["board_id"] as! Int16
            print("form nearDic board_Id =  \(board_Id)")
            performSegue(withIdentifier:"manageDetail", sender: board_Id)
        }else {
            let item = boardDataManager.itemWithIndex(index: indexPath.item)
            let board_Id = item.board_Id
            print("did selected board_Id =  \(board_Id)")
            performSegue(withIdentifier:"manageDetail", sender: board_Id)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageDetail" {
            let vc = segue.destination as! ManageDetailViewController
            vc.selectIndexID = sender as! Int16
        }
    }
    
     func reloadAllData(){
        collectionViewOne.reloadData()
        collectionViewTwo.reloadData()
    }
    
    // MARK: location manager methods
    func locationManager(updatedUserLocation coordinate: CLLocation) {
        locationManager.startUpdate()
        monitorRegion(userLocation: coordinate)
        locationManager.stopUpdate()
        
    }
    func locationManager(userDidExitRegion region: CLRegion) {
        //print("Exit \(region.identifier)")
    }
    
    func locationManager(userDidEnterRegion region: CLRegion) {
        //print("Enter \(region.identifier)")
    }
    
    func monitorRegion(userLocation:CLLocation){
        let userLocation = userLocation
        var distance = CLLocationDistance()
        if dataManagerCount == 0 {
            nearbyDic.removeAll()
        }
        count = count + 1
        for i in 0..<dataManagerCount {
            let item = boardDataManager.itemWithIndex(index: i)
            let lat = item.board_Lat
            let lon = item.board_Lon
            var imgWithData = UIImage()
            let board_id = item.board_Id
            let title = item.board_Title ?? ""
            if let img = item.board_ScreenShot {
                imgWithData = UIImage(data: img as Data)!
            }
            
            distance = locationManager.distance(lat: lat, lon: lon, userLocation: userLocation)
            if distance <  2500 {
                if count == 1 {
                    nearbyDic.append(["title":title ,"lat":lat, "lon":lon, "distance":distance,"BgPic":imgWithData,"index":i,"board_id":board_id])
                }else {
                    count = 0
                    nearbyDic.removeAll()
                    nearbyDic.append(["title":title ,"lat":lat, "lon":lon, "distance":distance,"BgPic":imgWithData,"index":i,"board_id":board_id])
                    count = 1
                }
            }
        }
        nearbyDic.sort { ($0["distance"] as! Double) < ($1["distance"] as! Double) }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = false
        
        dataManagerCount = boardDataManager.count()
        // 從其他頁面跳過來的時候可以更新內容
        locationManager.startUpdate()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.arrayImageData()
            self.reloadAllData()
        }
        
        firstTimeNoticeImage()
    }
    
    func firstTimeNoticeImage(){
        var imageView = UIImage()
        // 如果沒有任何資料 放上教學頁面
        if dataManagerCount == 0 {
            if scrollPage == 0 {
                imageView = UIImage(named: "first")!
                
            }else {
                imageView = UIImage(named: "nearby_1")!
            }
        }
        // 如果附近沒有 放上指定圖片 避免空曠
        if nearbyDic.count == 0 {
            if scrollPage == 1 {
                imageView = UIImage(named: "nearby_1")!
            }
        }
        
        noticeImageView.clipsToBounds = true
        noticeImageView.layer.cornerRadius = 4.0
        noticeImageView.contentMode = .scaleToFill
        noticeImageView.image = imageView
    }
    
    // set frame for scroll view
    override func viewDidLayoutSubviews() {
        scrollView.frame = CGRect(x: 0.0, y: 0.0, width: contentView.bounds.size.width, height: view.bounds.size.height)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        noticeImageView.image = nil
    }

    
}
