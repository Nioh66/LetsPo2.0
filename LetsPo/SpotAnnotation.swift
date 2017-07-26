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
    
    override init() {
        super.init()
    }
    
    
    init(atitle:String, lat:CLLocationDegrees, lon:CLLocationDegrees, imageName:UIImage, privacyBool:Bool) {
        
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        currentTitle = atitle
        image = imageName
        privacy = privacyBool
        
    }
    public var title: String? {
        if places.count == 1 {
            return currentTitle
        }else {
            return "\(places.count) 張留言板 "
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
