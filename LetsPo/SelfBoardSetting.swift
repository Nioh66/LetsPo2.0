//
//  SelfBoardSetting.swift
//  LetsPo
//
//  Created by Pin Liao on 01/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import Foundation
import UIKit

class SelfBoardSetting {
    //..
    
    
    
    func getSelfboardBg() -> UIImage? {
        let searchField = "selfBoard_ID"
        let keyword = "1"
        var selfBoardBg = UIImage()
        
        guard let result = selfBoardDataManager.searchField(field: searchField, forKeyword: keyword) as? [SelfBoardData] else{
            print("Result case to [SelfBoardData] failure!!!!")
            return nil
        }
        
        for selfBoard:SelfBoardData in result{
            guard let bgImageData = selfBoard.selfBoard_Pic as Data?,
                let bgImage = UIImage(data: bgImageData)
                else{
                    print("BgImage case failure!!!!!!")
                    return nil
            }
            selfBoardBg = bgImage
        }
        
        return selfBoardBg
    }
    
    
    func getSelfboardNotes() -> [UIImageView]? {
        let searchField = "selfNote_BoardID"
        let keyword = "1"
        var allSelfNotesSelfie = [UIImageView]()
        
        guard let result = selfNoteDataManager.searchField(field: searchField, forKeyword: keyword) as? [SelfNoteData] else{
            print("Result case to [SelfNoteData] failure!!!!")
            return nil
        }
        
        for noteAttribute:SelfNoteData in result{
            
            guard let noteSelfieNSData = noteAttribute.selfNote_ScreenShot as Data?,
                let noteSelfie = UIImage(data: noteSelfieNSData) else{
                    print("Self note sefies transform failure!!!!!")
                    return nil
            }
            
            let noteX = noteAttribute.selfNote_X
            let noteY = noteAttribute.selfNote_Y
            
            
            let noteSelfieView = UIImageView(frame: CGRect(x: noteX, y: noteY, width: 100, height: 100))
            noteSelfieView.image = noteSelfie
            allSelfNotesSelfie.append(noteSelfieView)
        }
        
        return allSelfNotesSelfie
    }
}
