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
    var image = UIImage()
    var privacy = Bool()
    var board_Id = Int16()
    var member_Id = Int()
    override init() {
        super.init()
    }
    
    
    init(atitle:String, lat:CLLocationDegrees, lon:CLLocationDegrees, imageName:UIImage, privacyBool:Bool,Id:Int16,member_ID:Int) {
        
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        currentTitle = atitle
        image = imageName
        privacy = privacyBool
        board_Id = Id
        member_Id = member_ID
        
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
