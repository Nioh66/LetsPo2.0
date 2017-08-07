//
//  ExistBoardVC.swift
//  LetsPo
//
//  Created by Pin Liao on 07/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit
import CoreLocation

class ExistBoardVC: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LocationManagerDelegate{
    
    let boardSearchfield = "board_Id"
    let boardSearchKeyword = ""
    let cellSpace = 10
    let itemCount:CGFloat = 3
    let spacing:CGFloat = 3
    
    var resizeNote = UIImage()
    var Lat:Double = 0
    var Lon:Double = 0
    var allNoteData = [String:Any]()
    var nearbyDic = [[String:Any]]()
    
    var nearbyBoardScreenShot = [UIImage]()
    var nearbyBoardID = [Int16]()
    var allBoardScreenShot = [UIImage]()
    var allBoardID = [Int16]()
    let locationManager = LocationManager()
    let dataManagerCount = boardDataManager.count()
    var count = 0

    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        
        let location = CLLocation(latitude: Lat, longitude: Lon)
        monitorRegion(userLocation: location)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getAllBoard()

        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind:
            UICollectionElementKindSectionHeader,
            withReuseIdentifier: "Header")
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind:
            UICollectionElementKindSectionFooter,
            withReuseIdentifier: "Footer")
        print("\(allBoardScreenShot.count)")
        print("\(allBoardID.count)")
        print("\(nearbyDic.count)")
        collectionView.reloadData()

        
                // Do any additional setup after loading the view.
    }
    // MARK: Get board data
    func getAllBoard() {
        guard let result = boardDataManager.searchField(field: boardSearchfield, forKeyword: boardSearchKeyword) as? [BoardData] else{
            print("xxx")
            return
        }
        print(result)
        print("xx.xx")
        for allBoard:BoardData in result{
            print("xxx.xxx")

            guard let boardSSD = allBoard.board_ScreenShot as Data?,
                let boardSS = UIImage(data: boardSSD) else{
                    print("xx")
                    return
            }
            print("x")
            allBoardID.append(allBoard.board_Id)
            allBoardScreenShot.append(boardSS)
        }
    }
    
    
    
    // MARK: CollectionView Delegate method
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var returnCount : Int = 0
        if section == 1{
            returnCount = nearbyDic.count
        }else{
            returnCount = allBoardScreenShot.count
        }
        return returnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ExistBoardCell
        
        let section = indexPath.section
        
        if section == 1{
            cell.existBoardImageV.image = nearbyDic[indexPath.row]["screenshot"] as? UIImage
        }else if section == 2{
            cell.existBoardImageV.image = allBoardScreenShot[indexPath.row]
        }else{
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if section == 1 {
            let dragExistBoardVC = storyboard?.instantiateViewController(withIdentifier:"DragExistBoardVC") as! DragExistBoardVC
            navigationController?.pushViewController(dragExistBoardVC, animated: true)

        }else if section == 2 {
            let dragExistBoardVC = storyboard?.instantiateViewController(withIdentifier:"DragExistBoardVC") as! DragExistBoardVC
            navigationController?.pushViewController(dragExistBoardVC, animated: true)

        }else{
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.size.width
        let width = (screenWidth-(itemCount-1)*spacing)/itemCount
        let size = CGSize(width: width, height: width)
        return size
            }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reuseView = UICollectionReusableView()
        let label = UILabel(frame: CGRect(
            x: 0, y: 0,
            width: collectionView.frame.size.width, height: 40))
        label.textAlignment = .center
        
        // header
        if kind == UICollectionElementKindSectionHeader {
            // 依據前面註冊設置的識別名稱 "Header" 取得目前使用的 header
            reuseView =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "Header",
                    for: indexPath)
            // 設置 header 的內容
            reuseView.backgroundColor =
                UIColor.darkGray
            label.text = "Header";
            label.textColor = UIColor.white
            
        } else if kind ==
            UICollectionElementKindSectionFooter {
            // 依據前面註冊設置的識別名稱 "Footer" 取得目前使用的 footer
            reuseView =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionFooter,
                    withReuseIdentifier: "Footer",
                    for: indexPath)
            // 設置 footer 的內容
            reuseView.backgroundColor =
                UIColor.cyan
            label.text = "Footer";
            label.textColor = UIColor.black
            
        }
        
        reuseView.addSubview(label)
        return reuseView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func locationManager(updatedUserLocation coordinate: CLLocation) {
        print("----M----")
        monitorRegion(userLocation: coordinate)
        locationManager.stopUpdate()
        
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
            
            let Creater = item.board_Creater
            let lat = item.board_Lat
            let lon = item.board_Lon
            var imgWithData = UIImage()
            let board_id = item.board_Id
            if let img = item.board_ScreenShot {
                imgWithData = UIImage(data: img as Data)!
            }
            
            let pins = CLLocation.init(latitude: lat, longitude: lon)
            distance = pins.distance(from: userLocation) * 1.09361
            if distance <  2500 {
                if count == 1 {
                    nearbyDic.append(["name":Creater ?? "","lat":lat, "lon":lon, "distance":distance,"screenshot":imgWithData,"index":i,"board_id":board_id])
//                    nearbyBoardScreenShot.append(imgWithData)
//                    nearbyBoardID.append(board_id)
                    
                    
                }else {
                    count = 0
                    nearbyDic.removeAll()
                    nearbyDic.append(["name":Creater ?? "","lat":lat, "lon":lon, "distance":distance,"screenshot":imgWithData,"index":i,"board_id":board_id])
                    count = 1
                }
            }
        }
        nearbyDic.sort { ($0["distance"] as! Double) < ($1["distance"] as! Double) }
    }

}
