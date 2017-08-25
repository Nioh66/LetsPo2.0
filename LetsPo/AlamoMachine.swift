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

typealias imageHandler = (_ error:Error?,_ images:[UIImage]?) -> ()
class AlamoMachine {
    
    let ADD_FRIEND = "addFriend.php"
    let DELETE_BOARD = "deleteBoard.php"
    let DELETE_NOTE = "deleteNote.php"
    let FIND_FRIEND = "findFriend.php"
    let SAVE_BOARD = "saveBoardData.php"
    let SAVE_NOTE = "saveNoteData.php"
    let UPDATE_BOARDBG = "updataBoardBG.php"
    let UPDATE_BOARDSETTING = "updateBoard.php"
    let UPDATE_BOARDSCREENSHOT = "updateBoardScreenshot.php"
    let DOWNLOAD_ALL = "downloadAll.php"
    let DOWNLOAD_PUBLIC = "boardForMap.php"
    let DOWNLOAD_PUBLICNOTES = "publicBoardNotes.php"
    let DOWNLOAD_PUBLICNOTEDETAIL = "publicNoteDetail.php"
    let DOWNLOAD_FRIEND = "downloadFriend.php"
    let NEW_MEMBER = "newMember.php"
    let LOGIN = "login.php"
    
   
    func downloadImage(imageDic:[String:String],complete:@escaping imageHandler) {
        
        
        var requestChain = [DataRequest]()
        let imageCount = imageDic.count
        
        for num in 0..<imageCount{
            guard let targetURL = imageDic["Image\(num)"] else{
                print("TargetURL case failure")
                return
            }
            let imageReqest = Alamofire.request(targetURL)
            requestChain.append(imageReqest)
            
        }
        SessionManager.default.startRequestsImmediately = false
        let chain = RequestChain(requests: requestChain)
        chain.start { (downloadImages, error) in
           
           
                    complete(nil,downloadImages)
            
        }
    }
    
    func downloadImageImmediately(imageDic:[String:String],complete:@escaping imageHandler) {
        
        
        var requestChain = [DataRequest]()
        let imageCount = imageDic.count
        
        for num in 0..<imageCount{
            guard let targetURL = imageDic["Image\(num)"] else{
                print("TargetURL case failure")
                return
            }
            let imageReqest = Alamofire.request(targetURL)
            requestChain.append(imageReqest)
            
        }
        SessionManager.default.startRequestsImmediately = true
        let chain = RequestChain(requests: requestChain)
        chain.start { (downloadImages, error) in
            
            
            complete(nil,downloadImages)
            
        }
    }

    
    
    
    
    
    
    
    
    
    func doPostJobWith(urlString:String,parameter:[String:Any?],complete:@escaping doneHandler) {
        let BASE_URL = "https://nioh66.000webhostapp.com/LetsPo/"
        let DATA_KEY = "data"
        
        SessionManager.default.startRequestsImmediately = true

        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted),
            let jsonString = String.init(data: jsonData, encoding: .utf8)else{
                return
        }
        
        
        //NSLog("DoPost Parameter: %@", jsonString)
        let finalParameter:[String:String] = [DATA_KEY:jsonString]
        
        //        guard let uploadJson = try? JSONSerialization.data(withJSONObject: finalParameter, options: .prettyPrinted) else { return  }
        //
        
        
        Alamofire.request(BASE_URL+urlString, method: .post,parameters:finalParameter,
                          headers: nil).response { (Response) in
                            
                            let str = String(data:Response.data!, encoding: String.Encoding.utf8)
                            print(str!)
                            if Response.error == nil{
                                print(Response.data!)
                                guard let returnDic = JSON(Response.data!).dictionaryObject else{
                            //        print(JSON(Response.data!).dictionaryObject)

                                    return
                                }
                                complete(nil,returnDic)

                            }
                            else{
                           complete(Response.error,nil)
                            }
        }
    }
}


class RequestChain {
    typealias CompletionHandler = (_ Images:[UIImage]?, _ errorResult:ErrorResult?) -> Void
    
    struct ErrorResult {
        let request:DataRequest?
        let error:Error?
    }
    var album = [UIImage]()
    
    fileprivate var requests:[DataRequest] = []
    
    init(requests:[DataRequest]) {
        self.requests = requests
    }
    
    func start(_ completionHandler:@escaping CompletionHandler) {
        if let request = requests.first {
            request.response(completionHandler: { (response:DefaultDataResponse) in
                if let error = response.error {
                    completionHandler(nil, ErrorResult(request: request, error: error))
                    return
                }
                
                if let imageData = response.data{
                    let image = UIImage(data: imageData)
                        self.album.append(image!)
                }
                
                
                self.requests.removeFirst()
                self.start(completionHandler)
            })
            request.resume()
        }else {
            completionHandler(album, nil)
            return
        }
        
    }
}




