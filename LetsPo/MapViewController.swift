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

class MapViewController:  UIViewController ,CLLocationManagerDelegate,MKMapViewDelegate {
    
    var dataManager:CoreDataManager<BoardData>!
    var dataManagerCount = Int()
    
    let locationManager = CLLocationManager()
    var location = CLLocation()
    var places:[SpotAnnotation]!
    var zoomLevel = CLLocationDegrees()
    var region = CLCircularRegion()
    var reUpdate = NSLock()
    var shouldReUpdate = Bool()
    var nearbyDictionary = [[String:Any]]()
    var titleName:String = ""
    var count: Int = 0
    
    var tttt = UIImage()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 可以選擇永遠定位或者使用時定位
        locationManager.requestAlwaysAuthorization()
//        if CLLocationManager.authorizationStatus() == .authorizedAlways{
//            locationManager.requestAlwaysAuthorization()
//        }
//        else {
//            locationManager.requestWhenInUseAuthorization()
//        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        
        self.locationManager.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            // 防止秒數內再度觸發方法
            self.doUnlock()
            self.locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        
        dataManager = CoreDataManager(initWithModel: "LetsPoModel", dbFileName: "boardData.sqlite", dbPathURL: nil, sortKey: "board_CreateTime", entityName: "BoardData")
        
        dataManagerCount = dataManager.count()
        
        
        places = spot()
        filterAnnotations(paramPlaces: places)
        
        // 回到當前位置
        let locationButton = UIButton(type: .custom)
        let x = UIScreen.main.bounds.size.width * 0.76
        let y = UIScreen.main.bounds.size.height * 0.76
        locationButton.frame = CGRect(x: x, y: y, width: 80, height: 85)
        locationButton.addTarget(self, action: #selector(zoomToUserLocation), for: .touchUpInside)
        let btnImage = UIImage(named: "rightBtn.png")
        locationButton.imageView?.contentMode = .center
        locationButton.setImage(btnImage, for: .normal)
        self.view.addSubview(locationButton)
        
        
        // tmp add location button (press once only)
        let addlocations = UIButton(type: .custom)
        addlocations.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        addlocations.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
        addlocations.setImage(UIImage(named: "addNote.png"), for: .normal)
        self.view.addSubview(addlocations)
        
//        let result = dataManager.searchField(field: "board_Privacy", forKeyword: "0") as! [BoardData]
////        print(result)
//        for tmp:BoardData in result{
//            print("name: \(String(describing: tmp.board_Creater))Lat:\(String(describing: tmp.board_Lat))Lon:\(String(describing: tmp.board_Lon))time:\(String(describing: tmp.board_CreateTime))Privacy:\(String(describing: tmp.board_Privacy))")
//        }
//        
        
        
       
    }
    
    typealias EditItemCompletion = (_ success: Bool , _ result : BoardData?) -> ()
    
    func editeWithItem(item: BoardData?,withCompletion completion:EditItemCompletion?){
            
        if(completion == nil){
                return
        }
            var finalItem = item
        
        for i in 0...8{
        
//            if(finalItem == nil){
                finalItem = self.dataManager.createItem()
                finalItem?.board_CreateTime = NSDate()
//            }

            let nameArr = ["Tom","Jack","Hunter","Lucy","Sandy","Lisa","Jo","Bob","Andraw"]
            
        finalItem?.board_Creater = nameArr[i]
        
        let lat = [0.33087803,0.331622,0.33045275,0.337566,0.33546547,0.33424,0.33754,0.334643,0.6544343]
        let lon = [0.0305999,0.030337,0.02953296,0.041202,0.030544,0.03012364,0.0303322,0.0304657,0.9754]
        
        finalItem?.board_Lat = 37 + lat[i]
        finalItem?.board_Lon = -122 + lon[i]
        let image = ["myNigger.jpg","delete.png","deer.jpg","map.png","rightBtn.png","insert.png","right-arrow.png","BgSettings.png","Trashcan.png"]
            let iii = image[i]
        let img = UIImage(named: iii)
        let imgData = UIImageJPEGRepresentation(img!, 1)
        finalItem?.board_BgPic = imgData! as NSData
        finalItem?.board_Privacy = true
            
            completion!(true, finalItem)
        }
        
    }
    
    func zoomToUserLocation(){
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = self.mapView.userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.01
        mapRegion.span.longitudeDelta = 0.01
        
        mapView.setRegion(mapRegion, animated: true)
    }
    func addLocation(){
        
        self.editeWithItem(item: nil) { (success, result) in
            if(success){
                self.dataManager.saveContexWithCompletion(completion: { (success) in
                    if(success){
               }
                })
            }
        }
     }
    
    // mark - pins method
    func filterAnnotations(paramPlaces:[SpotAnnotation]){
        let latDelta = self.mapView.region.span.latitudeDelta / 15
        let lonDelta = self.mapView.region.span.longitudeDelta / 15
        
        for p:SpotAnnotation in paramPlaces {
            p.cleanPlaces()
        }
        var spotsToShow = [SpotAnnotation]()
        
        for i in 0..<places.count {
            
            let currentObject = paramPlaces[i]
            let lat = currentObject.coordinate.latitude
            let lon = currentObject.coordinate.longitude
            
            var found = false
            
            for tempAnnotation:SpotAnnotation in spotsToShow {
                let tempLat = tempAnnotation.coordinate.latitude - lat
                let tempLon = tempAnnotation.coordinate.longitude - lon
                if fabs(tempLat) < latDelta && fabs(tempLon) < lonDelta {
                    
                    self.mapView.removeAnnotation(currentObject)
                    found = true
                    tempAnnotation.addPlasce(place: currentObject)
                    
                    break
                }
            }
            if !found {
                spotsToShow.append(currentObject)
                mapView.addAnnotation(currentObject)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if zoomLevel != mapView.region.span.longitudeDelta {
            
            for ano:Any in mapView.selectedAnnotations {
                mapView .deselectAnnotation(ano as? MKAnnotation, animated: false)
                
            }
            filterAnnotations(paramPlaces: places)
            zoomLevel = mapView.region.span.longitudeDelta
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
                
        let PinIdentifier = "PinIdentifier"
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: PinIdentifier)
//            as? MKPinAnnotationView
        if (pin == nil){
//            pin = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: PinIdentifier)
             pin = MKAnnotationView.init(annotation: annotation, reuseIdentifier: PinIdentifier)
        }else {
            
            pin?.annotation = annotation
        }
        let rightBtn = UIButton(type: .detailDisclosure)
//        rightBtn.setImage(UIImage(named: "rightBtn.png"), for: .normal)
        pin?.rightCalloutAccessoryView = rightBtn
        
        
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
                                                  constant: 100)
        detailImage.addConstraint(widthConstraint)
        detailImage.addConstraint(heightConstraint)
        detailImage.contentMode = .scaleAspectFill
        pin?.detailCalloutAccessoryView = detailImage
        pin?.canShowCallout = true
        pin?.isEnabled = true
        if myAnnotation.privacy == true {
            tttt = UIImage(named: "map.png")!
        }else {
            tttt = UIImage(named: "delete.png")!
        }
        pin?.image = tttt
        
        
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let myAnnotation = view.annotation as! SpotAnnotation
        let placeCount = myAnnotation.placesCount()
        
        if placeCount <= 0 {return}
        
        if placeCount == 1 {
            titleName = myAnnotation.currentTitle
            if (control as? UIButton)?.buttonType == .detailDisclosure {
                performSegue(withIdentifier:"getDetail", sender: self)
            }
            print("Press one callout view")
        }else {
            print("Press many callout view")
        }
    }
    
    func doUnlock(){
        reUpdate.unlock()
        if shouldReUpdate{
            shouldReUpdate = false
        }
    }
    
    // mark - Region monitoring method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if reUpdate.try() == false {
            shouldReUpdate = true
            return
        }
        monitorRegion(userLocation: locations.last!)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("CREATED REGION: \(region.identifier) - \(locationManager.monitoredRegions.count)")
        
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter \(region.identifier)")
        mutableNotificationContent(title: "You Did Enter My Monitoring Area", body: "CLLocationManager did enter region:\(region.identifier)", indentifier: "DidEnterRegion")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit \(region.identifier)")
        mutableNotificationContent(title: "You Did Exit My Monitoring Area", body: "CLLocationManager did Exit region:\(region.identifier)", indentifier: "DidExitRegion")
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        //        print("monitoringDidFailForRegion \(String(describing: region)) \(error)")
        
    }
    
    func mutableNotificationContent(title:String, body:String, indentifier:String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
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
            let strName = value["board_Creater"] as! String
            
            //let time = value["lastUpdateDateTime"] as! String
            
            let lat = value["lat"] as! Double

            let lon = value["lon"] as! Double
            
            let img = value["BgPic"] as! UIImage
            
            let alert = value["alert"] as! Bool
            
            let pins = CLLocation.init(latitude: lat, longitude: lon)
            distance = pins.distance(from: userLocation) * 1.09361
            
            // 距離小於 2500 則存回 near
            if distance <  2500 && alert == true {
                if count == 1 {
                    nearbyDictionary.append(["name":strName,"lat":lat, "lon":lon, "distance":distance,"BgPic":img])
                }else {
                    count = 0
                    nearbyDictionary.removeAll()
                    nearbyDictionary.append(["name":strName,"lat":lat, "lon":lon, "distance":distance,"BgPic":img])
                    count = 1
                }
                if nearbyDictionary.count < 20 {
                    if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        region = CLCircularRegion.init(center: coordinate, radius: 150, identifier: strName)
                        
                        // nearbyDictionary 內的定位開始 Monitoring
                        locationManager.startMonitoring(for: region)
                        locationManager.requestState(for: region)
                        
                        // 超過 2300 則停止 Monitoring
                        if distance > 2300 {
                            locationManager.stopMonitoring(for: region)
                            print("stop \(strName)")
                        }
                    }
                }
            }
        }
        nearbyDictionary.sort { ($0["distance"] as! Double) < ($1["distance"] as! Double) }
        

    }
    
    func spot() -> [SpotAnnotation] {
        var result = [SpotAnnotation]()
        
        let dic = getLocations()
        for value in dic {
            let strName = value["board_Creater"] as! String
            
            // let time = value["lastUpdateDateTime"] as! String
            
            let lat = value["lat"] as! Double
            let lon = value["lon"] as! Double
            let img = value["BgPic"] as! UIImage
            let privacy = value["privacy"] as! Bool
            
            let annotation = SpotAnnotation( atitle: strName, lat: lat, lon: lon, imageName: img,privacyBool: privacy)
            
            result.append(annotation)
        }
        print("result count \(result.count)")
        return result
    }
    
    func getLocations() -> [[String:Any]] {
        var locations = [[String:Any]]()
       
        
        for i in 0..<dataManagerCount {
            let item = dataManager.itemWithIndex(index: i)
            
            let Creater = item.board_Creater
            let lat = item.board_Lat
            let lon = item.board_Lon
            let time = item.board_CreateTime
            let privacy = item.board_Privacy
            let alert = item.board_Alert
            if let img = item.board_BgPic {
                let imgWithData = UIImage(data: img as Data)
                locations.append(["board_Creater":Creater!,"lat":lat,"lon":lon,"board_CreateTime":time!,"BgPic":imgWithData!,"privacy":privacy,"alert":alert])
            }
        }
//        print("locations :\(locations)")
        print("location count :\(locations.count)")

//        let UrlString = "http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=bp102"
//        let myUrl = NSURL(string: UrlString)
//        let optData = try? Data(contentsOf: myUrl! as URL)
//        guard let data = optData else {
//            return friends
//        }
//        if let jsonArray = try? JSONSerialization.jsonObject(with: data, options:[])  as? [String:AnyObject] {
//            friends = (jsonArray?["friends"] as? [[String:Any]])!
//            friends.sort { ($0["lastUpdateDateTime"] as! String) > ($1["lastUpdateDateTime"] as! String) }
//            
//        }
        
        return locations
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getDetail" {
            let vc = segue.destination as! MapDetailViewController
            vc.navigationItem.title = titleName
        }
    }
}
