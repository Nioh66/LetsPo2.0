//
//  SpotAnnotation.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import MapKit

class SpotAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var currentTitle:String!
    var places = [SpotAnnotation]()
    var ScreenShot = UIImage()
    var privacy = Bool()
    var board_Id = Int16()
    var member_Id = Int()
    var bgPic = UIImage()
    override init() {
        super.init()
    }
    
    
    init(atitle:String, lat:CLLocationDegrees, lon:CLLocationDegrees, ScreenShotPic:UIImage, privacyBool:Bool,Id:Int16,member_ID:Int,bgImg:UIImage) {
        
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        currentTitle = atitle
        ScreenShot = ScreenShotPic
        privacy = privacyBool
        board_Id = Id
        member_Id = member_ID
        bgPic = bgImg
        
    }
    public var title: String? {
        if currentTitle.characters.count > 10 {
            return currentTitle.substring(with: currentTitle.startIndex..<currentTitle.index(currentTitle.startIndex, offsetBy: 10)) + "..."
        }else {
            return currentTitle
        }
    }
    
    func placesCount() -> Int{
        
        return places.count
    }
    
    func cleanPlaces(){
        places.removeAll()
        places.append(self)
        
    }
    func addPlasce (place:SpotAnnotation){
        places.append(place)
    }
    
}
