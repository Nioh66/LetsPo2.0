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
        frinedPlace = friendsSpot()
        mapView.addAnnotations(friendsSpot())
        
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
        //        rightBtn.setImage(UIImage(named: "rightBtn.png"), for: .normal)
        pin?.rightCalloutAccessoryView = rightBtn
        let left = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        pin?.leftCalloutAccessoryView = left
        
        
        let myAnnotation = annotation as! SpotAnnotation
        let detailImage = UIImageView.init(image: myAnnotation.image)
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
                let image = myAnnotation.image
                
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
        locationManager.startUpdate()
        monitorRegion(userLocation: coordinate)
        locationManager.stopUpdate()
        
    }
    func locationManager(userDidExitRegion region: CLRegion) {
        print("Exit \(region.identifier)")
        mutableNotificationContent(title: "離開！", body: "點擊查閱", indentifier: "DidExitRegion")
        if UserDefaults.standard.bool(forKey: "shakeNotice") == true {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
    }
    
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
            let img = value["BgPic"] as! UIImage
            let alert = value["alert"] as! Bool
            
            distance = locationManager.distance(lat: lat, lon: lon, userLocation: userLocation)
            
            // 距離小於 1000 則存回 near
            if distance <  1000 && alert == true {
                if count == 1 {
                    nearbyDictionary.append(["name":board_ID,"lat":lat, "lon":lon, "distance":distance,"BgPic":img])
                }else {
                    count = 0
                    nearbyDictionary.removeAll()
                    nearbyDictionary.append(["name":board_ID,"lat":lat, "lon":lon, "distance":distance,"BgPic":img])
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
            let img = value["BgPic"] as! UIImage
            let privacy = value["privacy"] as! Bool
            let member_ID = UserDefaults.standard.integer(forKey: "Member_ID")
            let title = value["title"] as! String
            // 加入大頭針
            let annotation = SpotAnnotation( atitle: title, lat: lat, lon: lon, imageName: img,privacyBool: privacy,Id:board_Id, member_ID: member_ID)
            
            result.append(annotation)
        }

        return result
    }
    func friendsSpot() -> [SpotAnnotation]{
        var result = [SpotAnnotation]()
        let dic = getFriendLocation()
        for value in dic {
            let name = value["friendName"] as! String
            let lat = value["lat"] as! Double
            let lon = value["lon"] as! Double
            let image = UIImage(named: "default_3")
            
            let id = value["id"] as! Int
            let annotation = SpotAnnotation( atitle: name, lat: lat, lon: lon, imageName: image!,privacyBool: true,Id:1, member_ID: id)
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
            if let img = item.board_ScreenShot {
                let imgWithData = UIImage(data: img as Data)
                locations.append(["board_Id":board_ID,"lat":lat,"lon":lon,"board_CreateTime":time!,"BgPic":imgWithData!,"privacy":privacy,"alert":alert,"title":title ?? ""])
                
            }
        }
         return locations
    }
    
    func getFriendLocation()->[[String:Any]]{
        var friendLocations = [[String:Any]]()
        //        var feinenData = [String:Any?]()
        //        alamoMachine.doPostJobWith(urlString: "", parameter: feinenData) { (error, rsp) in
        //            if let error = error {
        //                print(error)
        //            }
        //            guard let response = rsp,
        //                let resultBool = response["result"] as? Bool else {
        //                    return
        //            }
        //            if resultBool {
        //
        //            }
        //
        //
        //        }
        
        let UrlString = "http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=bp102"
        let myUrl = NSURL(string: UrlString)
        let optData = try? Data(contentsOf: myUrl! as URL)
        guard let data = optData else {
            return friendLocations
        }
        if let jsonArray = try? JSONSerialization.jsonObject(with: data, options:[])  as? [String:AnyObject] {
            if let friends = jsonArray?["friends"] as? [[String:Any]] {
                for value in friends {
                    let strName = value["friendName"] as! String
                    
                    //                        let time = value["lastUpdateDateTime"] as! String
                    
                    var lat = Double()
                    if let latt = Double(value["lat"] as! String) {
                        lat = latt
                    }
                    var lon = Double()
                    if let lonn = Double(value["lon"] as! String) {
                        lon = lonn
                    }
                    
                    let id = Int(value["id"] as! String)!
                    
                    friendLocations.append(["friendName":strName,"lat":lat,"lon":lon,"id":id])
                    
                }
            }
            
        }
        
        return friendLocations
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
