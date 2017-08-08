//
//  SelfNoteDetail.swift
//  LetsPo
//
//  Created by Pin Liao on 01/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import Foundation
import UIKit

class SelfNoteDetail {
    
    func getSelfNoteBg(noteID: Int16,note:Note) -> Note? {
        
        let searchField = "selfNote_ID"
        let keyword = "\(noteID)"
        
        
        guard let result = selfNoteDataManager.searchField(field: searchField, forKeyword: keyword) as? [SelfNoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        for noteAttribute:SelfNoteData in result{
            
            
            guard let noteBgColorData = noteAttribute.selfNote_BgColor else{
                print("getNoteSetting------------NoteAttributes case failure!!!!!")
                return nil
            }
            
            let noteColor = selfNoteDataManager.reverseColorDataToColor(data: noteBgColorData)
            note.posterColor = noteColor
            note.backgroundColor = UIColor.clear
        }
        
        return note
    }
    
    func getSelfNoteText(noteID: Int16,noteText:NoteText) -> NoteText? {
        
        
        let searchField = "selfNote_ID"
        let keyword = "\(noteID)"
        
        
        guard let result = selfNoteDataManager.searchField(field: searchField, forKeyword: keyword) as? [SelfNoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        for noteAttribute:SelfNoteData in result{
            
            
            guard let noteFontColorData = noteAttribute.selfNote_FontColor as Data?,
                let noteFontColor = NSKeyedUnarchiver.unarchiveObject(with: noteFontColorData) as? UIColor
                else{
                    print("getNoteText----------------NoteAttributes case failure!!!!!")
                    return nil
            }
            let noteFontsize = noteAttribute.selfNote_FontSize
            let noteContent = noteAttribute.selfNote_Content
            
            noteText.text = noteContent
            noteText.textColor = noteFontColor
            noteText.font = UIFont.boldSystemFont(ofSize: CGFloat(noteFontsize))
            
        }
        return noteText
    }
    
    func getNoteImage(noteID: Int16) -> [UIImage]? {
        let searchField = "selfNote_ID"
        let keyword = "\(noteID)"
        var noteImages = [UIImage]()
        
        
        guard let result = selfNoteDataManager.searchField(field: searchField, forKeyword: keyword) as? [SelfNoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        for noteAttribute:SelfNoteData in result{
            
            guard let noteImageData = noteAttribute.selfNote_Image
                else{
                    print("getNoteImage----------------NoteAttributes case failure!!!!!")
                    return nil
            }
            guard let noteImgs = selfNoteDataManager.transformDataToImage(imageJSONData: noteImageData)
                else{
                    print("transformDataToImage----------------NoteAttributes case failure!!!!!")
                    return nil
            }
            
            noteImages = noteImgs
        }
        return noteImages
    }
    
    
    
    
}
