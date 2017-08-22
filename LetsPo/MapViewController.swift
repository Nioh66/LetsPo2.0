//
//  MapViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import CoreData
import AudioToolbox

class MapViewController:  UIViewController ,LocationManagerDelegate,MKMapViewDelegate {
    
    var dataManagerCount = Int()
    
    let locationManager = LocationManager()
    var location = CLLocation()
    var places:[SpotAnnotation]!
    var frinedPlace:[SpotAnnotation]!
    var zoomLevel = CLLocationDegrees()
    var region = CLCircularRegion()
    var reUpdate = NSLock()
    var shouldReUpdate = Bool()
    var nearbyDictionary = [[String:Any]]()
    var titleName:String = ""
    var count: Int = 0
    var allPublicBoards = [[String:Any]]()
    
    //for upload
    var userLat = Double()
    var userLon = Double()
    
    var privacy_pins = UIImage()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        locationManager.startUpdate()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            // 防止秒數內再度觸發方法
//            self.doUnlock()
            self.locationManager.startUpdate()
        }
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        
        dataManagerCount = boardDataManager.count()
        
        
        places = spot()
        mapView.addAnnotations(places)
        
        
        // 回到當前位置
        let locationButton = UIButton(type: .custom)
        let x = UIScreen.main.bounds.size.width * 0.76
        let y = UIScreen.main.bounds.size.height * 0.76
        locationButton.frame = CGRect(x: x, y: y, width: 80, height: 85)
        locationButton.addTarget(self, action: #selector(zoomToUserLocation), for: .touchUpInside)
        let btnImage = UIImage(named: "ufo_1")
        locationButton.imageView?.contentMode = .scaleAspectFit
        locationButton.setImage(btnImage, for: .normal)
        self.view.addSubview(locationButton)
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.downloadPublicBoard()
        }
    }
    
    
    func zoomToUserLocation(){
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.01
        mapRegion.span.longitudeDelta = 0.01
        
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let PinIdentifier = "PinIdentifier"
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: PinIdentifier)
        if (pin == nil){
            pin = MKAnnotationView.init(annotation: annotation, reuseIdentifier: PinIdentifier)
        }else {
            
            pin?.annotation = annotation
        }
        let rightBtn = UIButton(type: .detailDisclosure)
        rightBtn.setImage(UIImage(named: "white"), for: .normal)
        pin?.rightCalloutAccessoryView = rightBtn
        let left = UIView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        pin?.leftCalloutAccessoryView = left
        
        
        let myAnnotation = annotation as! SpotAnnotation
        let detailImage = UIImageView.init(image: myAnnotation.ScreenShot)
        detailImage.layer.cornerRadius = 5.0
        detailImage.layer.masksToBounds = true
        
        // Detail view 的 Constraint
        let widthConstraint = NSLayoutConstraint(item: detailImage,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 100)
        
        let heightConstraint = NSLayoutConstraint(item: detailImage,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 120)
        detailImage.addConstraint(widthConstraint)
        detailImage.addConstraint(heightConstraint)
        detailImage.contentMode = .scaleAspectFill
        pin?.detailCalloutAccessoryView = detailImage
        pin?.canShowCallout = true
        pin?.isEnabled = true
        
        let member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
        if myAnnotation.member_Id == member_ID {
            
            if myAnnotation.privacy == true {
                privacy_pins = UIImage(named: "pin_2")!
            }else{
                privacy_pins = UIImage(named: "pin_1")!
            }
        }else {
            privacy_pins = #imageLiteral(resourceName: "friendPin")
        }
        pin?.image = privacy_pins
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let myAnnotation = view.annotation as! SpotAnnotation
        let member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
        
        if myAnnotation.member_Id == member_ID {
            titleName = myAnnotation.currentTitle
            if (control as? UIButton)?.buttonType == .detailDisclosure {
                let id = myAnnotation.board_Id
                let storyboard = UIStoryboard(name: "ManagePost", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "detailViewController") as! ManageDetailViewController
                vc.selectIndexID = id
                navigationController?.pushViewController(vc, animated: false)
            }
        }else {
            titleName = myAnnotation.currentTitle
            if (control as? UIButton)?.buttonType == .detailDisclosure {
                let id = myAnnotation.board_Id
                let member_id = myAnnotation.member_Id
                let image = myAnnotation.bgPic
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "MapDetailViewController") as! MapDetailViewController
                vc.selectIndexID = id
                vc.selectMember_id = member_id
                vc.image = image
                vc.boardTitle = titleName
                navigationController?.pushViewController(vc, animated: false)
            }
        }

    }
    
    func doUnlock(){
        reUpdate.unlock()
        if shouldReUpdate{
            shouldReUpdate = false
        }
        
    }
    
    // mark - Region monitoring method
    func locationManager(updatedUserLocation coordinate: CLLocation) {
        if reUpdate.try() == false {
            shouldReUpdate = true
            return
        }
        
        //For server
        userLat = coordinate.coordinate.latitude
        userLon = coordinate.coordinate.longitude
        
        print("userLat。\(userLat)")
        print("userLon。\(userLon)")
        
        locationManager.startUpdate()
        monitorRegion(userLocation: coordinate)
        locationManager.stopUpdate()
        
    }
//    func locationManager(userDidExitRegion region: CLRegion) {
//        print("Exit \(region.identifier)")
//        mutableNotificationContent(title: "離開！", body: "點擊查閱", indentifier: "DidExitRegion")
//        if UserDefaults.standard.bool(forKey: "shakeNotice") == true {
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//        }
//        
//    }
    
    func locationManager(userDidEnterRegion region: CLRegion) {
        print("Enter \(region.identifier)")
        
        mutableNotificationContent(title: "附近有留言板喔!", body: "", indentifier: "DidEnterRegion")
        // 是否震動
        if UserDefaults.standard.bool(forKey: "shakeNotice") == true {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    func mutableNotificationContent(title:String, body:String, indentifier:String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if UserDefaults.standard.bool(forKey: "soundNotice") == true {
            content.sound = UNNotificationSound.default()
        }else {
            content.sound = nil
        }
        let request = UNNotificationRequest.init(identifier: indentifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("UserNotificationCenter Fail:\(String(describing: error))")
            }
        }
    }
    
    func monitorRegion(userLocation:CLLocation){
        let userLocation = userLocation
        let dic = getLocations()
        var distance = CLLocationDistance()
        
        count = count + 1
        for value in dic {
            let board_ID = value["board_Id"] as! Int16
            let lat = value["lat"] as! Double
            let lon = value["lon"] as! Double
            let img = value["ScreenShotPic"] as! UIImage
            let alert = value["alert"] as! Bool
            
            distance = locationManager.distance(lat: lat, lon: lon, userLocation: userLocation)
            
            // 距離小於 1000 則存回 near
            if distance <  1000 && alert == true {
                if count == 1 {
                    nearbyDictionary.append(["name":board_ID,"lat":lat, "lon":lon, "distance":distance,"ScreenShotPic":img])
                }else {
                    count = 0
                    nearbyDictionary.removeAll()
                    nearbyDictionary.append(["name":board_ID,"lat":lat, "lon":lon, "distance":distance,"ScreenShotPic":img])
                    count = 1
                }
                if nearbyDictionary.count < 20 {
                    // 開始進行追蹤
                    locationManager.isMonitoringAvailable(lat: lat, lon: lon, regi: region, distance: distance,identifier:"\(board_ID)")
                }
            }
        }
        nearbyDictionary.sort { ($0["distance"] as! Double) < ($1["distance"] as! Double) }
        
        
    }
    
    func spot() -> [SpotAnnotation] {
        var result = [SpotAnnotation]()
        
        let dic = getLocations()
        for value in dic {
            let board_Id = value["board_Id"] as! Int16
            let lat = value["lat"] as! Double
            let lon = value["lon"] as! Double
            let ScreenShotImg = value["ScreenShotPic"] as! UIImage
            let privacy = value["privacy"] as! Bool
            let member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
            let title = value["title"] as! String
            let bgPic = value["bgPic"] as! UIImage
            // 加入大頭針
            let annotation = SpotAnnotation( atitle: title, lat: lat, lon: lon, ScreenShotPic: ScreenShotImg,privacyBool: privacy,Id:board_Id, member_ID: member_ID, bgImg:bgPic)
            
            result.append(annotation)
        }

        return result
    }
    func friendsSpot() -> [SpotAnnotation]?{
        var result = [SpotAnnotation]()
        let dic = allPublicBoards
        
        for boardData in dic{
            
            guard let name = boardData["Board_Title"] as? String,
                let board_ID = boardData["Board_ID"] as? Int64,
                let lat = boardData["Board_Lat"] as? Double,
                let lon = boardData["Board_Lon"] as? Double,
                let friend_ID = boardData["Friend_ID"] as? Int64,
                let bgPic = boardData["Board_BgPic"] as? NSData,
                let bgImage = UIImage(data: bgPic as Data),
                let SSImageData = boardData["Board_ScreenShot"] as? NSData,
                let SSImage = UIImage(data: SSImageData as Data) else{
                    print("Case from friendsSpot boardData failure!!!!!")
                    return nil
            }
            
            let annotation = SpotAnnotation( atitle: name, lat: lat, lon: lon, ScreenShotPic: SSImage,privacyBool: true,Id:Int16(board_ID), member_ID: Int(friend_ID),bgImg:bgImage)
            result.append(annotation)
        }
        return result
    }

    
    func getLocations() -> [[String:Any]] {
        var locations = [[String:Any]]()
        for i in 0..<dataManagerCount {
            let item = boardDataManager.itemWithIndex(index: i)
            let board_ID = item.board_Id
            let lat = item.board_Lat
            let lon = item.board_Lon
            let time = item.board_CreateTime
            let privacy = item.board_Privacy
            let alert = item.board_Alert
            let title = item.board_Title
            let bgImage = item.board_BgPic
            let bgImageWithData = UIImage(data: bgImage! as Data)
            let img = item.board_ScreenShot
            let SSimgWithData = UIImage(data: img! as Data)
                locations.append(["board_Id":board_ID,"lat":lat,"lon":lon,"board_CreateTime":time!,"ScreenShotPic":SSimgWithData!,"privacy":privacy,"alert":alert,"title":title ?? "","bgPic":bgImageWithData!])
                
            
        }
         return locations
    }
    
    
    // MARK: Download public board
    func downloadPublicBoard() {
        let alamoMachine = AlamoMachine()
        let memberID = UserDefaults.standard.integer(forKey: "Member_ID")
        let memberDic:[String:Any] = ["Member_ID":memberID,
                         "Member_Lat":userLat,
                         "Member_Lon":userLon]

        let friendCount = friendDataManager.count()
        var friendIDDic = [String:Int64]()
        for i in 0..<friendCount{
            let friend = friendDataManager.itemWithIndex(index: i)
            let friendID = friend.friend_FriendID

            friendIDDic.updateValue(friendID, forKey: "Friend\(i)")
        }

        let uploadDic:[String:Any?] = ["Member":memberDic,
                                       "Friends":friendIDDic]
        print("=========uploadDic:\(uploadDic)=============")

        alamoMachine.doPostJobWith(urlString: alamoMachine.DOWNLOAD_PUBLIC, parameter: uploadDic) { (error, response) in
            if error != nil{
                print(error!)
                return
            }
            guard let result = response?["result"] as? Bool else{
                return
            }
            
            if result{
                guard let publicBoards = response?["availableBoards"] as? [[String:Any]] else{
                    print("Case availableBoards failure!!!!!")
                    return
                }
                
                self.handlePublicBoards(boards: publicBoards)
                
                
            }
            
        }
        
    }
    
    
    func handlePublicBoards(boards:[[String:Any]]) {
        
        print(boards)

        for boardData in boards{
            
            guard let boardTitle = boardData["Board_Title"] as? String,
                let boardIDS = boardData["Board_ID"] as? String,
                let boardLatS = boardData["Board_Lat"] as? String,
                let boardLonS = boardData["Board_Lon"] as? String,
                let friendIDS = boardData["Board_CreateMemberID"] as? String,
                let boardBgPicS = boardData["Board_BgPic"] as? String,
                let boardScreenShotS = boardData["Board_ScreenShot"] as? String
                 else{
                    print("Case from boardData failure!!!!!")
                    return
            }

            guard let friendID = Int64(friendIDS),
                let boardLat = Double(boardLatS),
                let boardLon = Double(boardLonS),
                let boardBgPic = NSData(base64Encoded: boardBgPicS, options: []),
                let boardID = Int64(boardIDS),
                let boardScreenShot = NSData(base64Encoded: boardScreenShotS, options: []) else{
                    print("Case from String failure!!!!!")
                    return
            }
            
            let publicBoardData:[String:Any] = ["Friend_ID":friendID,
                                                "Board_ID":boardID,
                                                "Board_Lat":boardLat,
                                                "Board_Lon":boardLon,
                                                "Board_BgPic":boardBgPic,
                                                "Board_ScreenShot":boardScreenShot,
                                                "Board_Title":boardTitle]
            allPublicBoards.append(publicBoardData)
            

        }
        if let frinedPlace = friendsSpot(){
        mapView.addAnnotations(frinedPlace)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        locationManager.startUpdate()
        
        
        dataManagerCount = boardDataManager.count()
        places = spot()
        mapView.removeAnnotations(places)
        mapView.addAnnotations(places)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
}
