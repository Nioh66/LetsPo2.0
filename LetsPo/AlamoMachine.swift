//
//  AlamoMachine.swift
//  LetsPo
//
//  Created by Pin Liao on 13/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias doneHandler = (_ erro:Error?,_ result:[String:Any]?) -> ()

class AlamoMachine {
    
    
    let DELETE_BOARD = "deleteBoard.php"
    let DELETE_NOTE = "deleteNote.php"
    let FINDFRIEND = "findFriend.php"
    let SAVE_BOARD = "saveBoardData.php"
    let SAVE_NOTE = "saveNoteData.php"
    let UPDATE_BOARDBG = "updataBoardBG.php"
    let UPDATE_BOARDSETTING = "updateBoard.php"
    let UPDATE_BOARDSCREENSHOT = "updateBoardScreenshot.php"
    let UPDATE_ALL = "updateAll.php"
    let NEW_MEMBER = "newMember.php"

   
    
    
    
    
    
    
    
    func doPostJobWith(urlString:String,parameter:[String:Any?],imageDic:[UIImage]?,complete:@escaping doneHandler) {
        let BASE_URL = "https://nioh66.000webhostapp.com/LetsPo/"
        let DATA_KEY = "data"
        
        
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted),
            let jsonString = String.init(data: jsonData, encoding: .utf8)else{
                return
        }
        
        
        NSLog("DoPost Parameter: %@", jsonString)
        let finalParameter:[String:String] = [DATA_KEY:jsonString]
        
        //        guard let uploadJson = try? JSONSerialization.data(withJSONObject: finalParameter, options: .prettyPrinted) else { return  }
        //
        
        
        Alamofire.request(BASE_URL+urlString, method: .post,parameters:finalParameter,
                          headers: nil).response { (Response) in
                            
                            if Response.error == nil{
                            
                                guard let returnDic = JSON(Response.data!).dictionaryObject else{
                                    return
                                }
                                complete(nil,returnDic)
//                                if JSON(Response.data!)["result"].boolValue{
//                                    complete(nil,returnDic)
//
//                                }else{
//                                    let falseDic:[String:Any]
//                                    let error = returnDic["errorCode"] as Any
//                                    let
//                                    let errorAlert = ["errorCode":error]
//                                    complete(nil, errorAlert)
//                                }
                            }
                            else{
                            complete(Response.error,nil)
                            }
                            
                                
        }
        
    }
    

}
