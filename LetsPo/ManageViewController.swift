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

class ManageViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, ActionDelegation, ScrollPagerDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollPager: ScrollPager!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dataManagerCount = Int()
    let locationManager = CLLocationManager()
    
    var deleteBtnFlag:Bool!
    var recent = [UIImage]()
    var nearby = [UIImage]()
    var all = [UIImage]()
    var nearbyDic = [[String:Any]]()
    var count = 0
    var secondTime = false
    
    var collectionViewTwo:UICollectionView!
    var collectionViewOne: UICollectionView!
    var collectionViewThree:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManagerMethod()
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)
        //let documnetPath = documentPaths[0] as! String
        print(documentPaths)
        
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
        
        collectionViewThree = UICollectionView(frame: self.view.frame, collectionViewLayout: FlowLayout())
        collectionViewThree.register(UINib.init(nibName: "ManageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
        collectionViewThree.delegate = self
        collectionViewThree.dataSource = self
        collectionViewThree.backgroundColor = UIColor.clear
        self.view.addSubview(collectionViewThree)
        
        dataManagerCount = boardDataManager.count()
        print("dataManagerCount1111 \(dataManagerCount)")
        // 第一次進入還沒新增時的底圖
        if dataManagerCount == 0 {
            nearby.append(UIImage(named: "deer.jpg")!)
            recent.append(UIImage(named: "myNigger.jpg")!)
            all.append(UIImage(named: "Sky.jpg")!)
        }
        
        
        // incase core location too slow
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            self.arrayImageData()
            self.secondTime = true
        }

        
        setFlagAndGsr()
        
        // assign view to each page
        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("RECENT", collectionViewOne),
            ("NEARBY", collectionViewTwo),
            ("ALL", collectionViewThree),
            ])
        
        print("dataManagerCount2222 \(dataManagerCount)")
        
       
    
    }
    
    func arrayImageData(){
        // 第二次以後回來這頁時 刷新array裡的內容
        if secondTime == true{
            all.removeAll()
            recent.removeAll()
        }
        for i in 0..<dataManagerCount {
            let item = boardDataManager.itemWithIndex(index: i)
            let date = item.board_CreateTime
            if let img = item.board_ScreenShot {
                let imgWithData = UIImage(data: img as Data)
                all.append(imgWithData!)
            }
            
            print("\(i) = \(String(describing: date))")
        }
        // 只取前五個 作為最近的內容
        if dataManagerCount >= 5 {
            for i in 0..<5 {
                let item = boardDataManager.itemWithIndex(index: i)
                if let img = item.board_ScreenShot {
                    let imgWithData = UIImage(data: img as Data)
                    recent.append(imgWithData!)
                }
            }
        }else {
            for i in 0..<dataManagerCount {
                let item = boardDataManager.itemWithIndex(index: i)
                if let img = item.board_ScreenShot {
                    let imgWithData = UIImage(data: img as Data)
                    recent.append(imgWithData!)
                }
            }
        }
        
        for value in nearbyDic {
            let imageName = value["BgPic"] as! UIImage
            if count == 1 {
                nearby.append(imageName)
            }else {
                count = 0
                nearby.removeAll()
                nearby.append(imageName)
                count = 1
            }
        }
        reloadAllData()

        print("recent count: \(recent.count)")
        print("nearby count : \(nearby.count)")
        print("all count: \(all.count)")
    }
    
    func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {
        print("scrollPager index changed: \(changedIndex)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = Int()
        
        if collectionView == self.collectionViewOne {
            count = recent.count
        }
        else if collectionView == self.collectionViewTwo {
            if nearby.count == 0 {
                count = 1
            }else {
                count = nearby.count
            }
        }else if collectionView == self.collectionViewThree {
            count = all.count
        }
        return count
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = ManageCollectionViewCell()
    
        if collectionView == self.collectionViewOne {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ManageCollectionViewCell
            
                let imageString = recent[indexPath.item]
                cell.backdroundImage.image = imageString
           
        }else if collectionView == self.collectionViewTwo {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ManageCollectionViewCell
            if nearby.count != 0 {
                let imageString = nearby[indexPath.item]
                cell.backdroundImage.image = imageString
            }else {
                // 第一次進入還沒新增時的底圖
                cell.backdroundImage.image = UIImage(named:"deer.jpg")
            }
        }else if collectionView == self.collectionViewThree {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ManageCollectionViewCell
            
                let imageString = all[indexPath.item]
                cell.backdroundImage.image = imageString
           
        }
        setCellBtn(cell: cell)
        return cell
    }
    
    
    //Mark: - remove object form indexPath
    func deleteCell(_ cell: UICollectionViewCell) {
        
        if let indexPath = collectionViewOne.indexPath(for: cell) {
            let item = boardDataManager.itemWithIndex(index: indexPath.row)
            for i in 0..<nearbyDic.count {
                let path = nearbyDic[i]["index"] as! NSInteger
                if path == indexPath.row {
                    print("i = \(i) indexPath.row = \(indexPath.row)")
                    nearby.remove(at: i)
                }
            }
            self.all.remove(at: indexPath.row)
            self.recent.remove(at: indexPath.row)
            self.collectionViewOne.deleteItems(at: [indexPath])
            boardDataManager.deleteItem(item: item)
            boardDataManager.saveContexWithCompletion(completion: { success in
                if(success){
                    self.reloadAllData()
                }
            })
        }else if let indexPath = collectionViewTwo.indexPath(for: cell) {
            // 因為是另外抓出來的陣列 所以取得原來在core data裡的位置來做刪除
            let indexWithRow = nearbyDic[indexPath.row]["index"] as! NSInteger
            
            print("indexWithRow: \(indexWithRow)")
            
                let item = boardDataManager.itemWithIndex(index: indexWithRow)
            boardDataManager.deleteItem(item: item)
            if indexWithRow < recent.count {
                print("indexWithRow \(indexWithRow) <= recent.count")
                self.recent.remove(at: indexWithRow)
                self.all.remove(at: indexWithRow)
            }else {
                print("indexWithRow \(indexWithRow) >= recent.count")
                self.all.remove(at: indexWithRow)
            }
            self.nearby.remove(at: indexPath.row)
            self.collectionViewTwo.deleteItems(at: [indexPath])
            boardDataManager.saveContexWithCompletion(completion: { success in
                if(success){
                    self.reloadAllData()
                }
            })
        }else if let indexPath = collectionViewThree.indexPath(for: cell) {
            let item = boardDataManager.itemWithIndex(index: indexPath.row)
            boardDataManager.deleteItem(item: item)
            self.all.remove(at: indexPath.row)
            for i in 0..<nearby.count {
                let path = nearbyDic[i]["index"] as! NSInteger
                if path == indexPath.row {
                    print("i = \(i) indexPath.row = \(indexPath.row)")
                    self.nearby.remove(at: i)
                }
            }
            if recent.count > 0 && indexPath.row < recent.count{
                self.recent.remove(at: indexPath.row)
            }
            self.collectionViewThree.deleteItems(at: [indexPath])
            boardDataManager.saveContexWithCompletion(completion: { success in
                if(success){
                    self.reloadAllData()
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.section),\(indexPath.item)")
        let item = boardDataManager.itemWithIndex(index: indexPath.item)
        let board_Id = item.board_Id
        print("did selected board_Id =  \(board_Id)")
        performSegue(withIdentifier:"manageDetail", sender: board_Id)
        
        hideAllDeleteBtn()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageDetail" {
            let vc = segue.destination as! ManageDetailViewController
            vc.selectIndexID = sender as! Int16

        }
    }

    
    // set gesture method
    func setFlagAndGsr(){
        deleteBtnFlag = true
        addDoubleTapGesture()
    }

    func setCellBtn(cell:ManageCollectionViewCell){
        
        if deleteBtnFlag == true {
            cell.deleteBtn.isHidden = true
        }else {
            cell.deleteBtn.isHidden = false
        }
        cell.delegation = self
    }

    func handleDoubleTap(gestureRecognizer:UITapGestureRecognizer){
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
            reloadAllData()
        }
    }
    
    func showAllDeleteBtn(){
        deleteBtnFlag = false
        reloadAllData()
    }
    
    func reloadAllData(){
        collectionViewOne.reloadData()
        collectionViewTwo.reloadData()
        collectionViewThree.reloadData()
    }
    
    // MARK: location manager methods
    func locationManagerMethod(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.activityType = .automotiveNavigation
        self.locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        monitorRegion(userLocation: locations.last!)
        locationManager.stopUpdatingLocation()
    }
    
    func monitorRegion(userLocation:CLLocation){
        let userLocation = userLocation
        var distance = CLLocationDistance()
        count = count + 1
        for i in 0..<dataManagerCount {
            let item = boardDataManager.itemWithIndex(index: i)
            
            let Creater = item.board_Creater
            let lat = item.board_Lat
            let lon = item.board_Lon
            var imgWithData = UIImage()
            if let img = item.board_ScreenShot {
                imgWithData = UIImage(data: img as Data)!
            }
            
            let pins = CLLocation.init(latitude: lat, longitude: lon)
            distance = pins.distance(from: userLocation) * 1.09361
            if distance <  2500 {
                if count == 1 {
                    nearbyDic.append(["name":Creater!,"lat":lat, "lon":lon, "distance":distance,"BgPic":imgWithData,"index":i])
                }else {
                    count = 0
                    nearbyDic.removeAll()
                    nearbyDic.append(["name":Creater!,"lat":lat, "lon":lon, "distance":distance,"BgPic":imgWithData,"index":i])
                    count = 1
                }
            }
        }
        nearbyDic.sort { ($0["distance"] as! Double) < ($1["distance"] as! Double) }
//        print("near dictionary \(nearbyDic)")
        print("nearbyDic count \(nearbyDic.count)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        dataManagerCount = boardDataManager.count()
        // 從其他頁面跳過來的時候可以更新內容
        if secondTime == true{
            self.locationManager.startUpdatingLocation()
            
            // 每次回來都回到recent ? 暫定
            scrollPager.setSelectedIndex(index: 0, animated: false)
            arrayImageData()
            reloadAllData()
        }
    }
    
    // set frame for scroll view
    override func viewDidLayoutSubviews() {
        scrollView.frame = CGRect(x: 0.0, y: 0.0, width: contentView.bounds.size.width, height: view.bounds.size.height)
        
    }
}
