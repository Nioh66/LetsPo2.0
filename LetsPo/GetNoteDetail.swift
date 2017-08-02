//
//  GetNoteDetail.swift
//  LetsPo
//
//  Created by Pin Liao on 31/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import Foundation
import UIKit

class GetNoteDetail {
    
    
    func getNoteSetting(boardID: Int16,noteID: Int16,note:Note) -> Note? {
        let searchField = "note_BoardID"
        let keyword = "\(boardID)"
      
        
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        for noteAttribute:NoteData in result{
            if noteAttribute.note_ID == noteID {
                
                guard let noteBgColorData = noteAttribute.note_BgColor else{
                    print("getNoteSetting------------NoteAttributes case failure!!!!!")
                    return nil
                }
                
                let noteColor = noteDataManager.reverseColorDataToColor(data: noteBgColorData)
                print("noteColor------\(noteColor.cgColor)")
                note.posterColor = noteColor
                note.backgroundColor = UIColor.clear
            }else{
                print("There's no NoteBg")
            }
            
        }
        return note
    }
    
    
    func getNoteText(boardID: Int16,noteID: Int16,noteText:NoteText) -> NoteText? {
        
        let searchField = "note_BoardID"
        let keyword = "\(boardID)"
//        let noteText = NoteText()
        
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        
        for noteAttribute:NoteData in result{
            if noteAttribute.note_ID == noteID {
                
                guard let noteFontColorData = noteAttribute.note_FontColor as Data?,
                    let noteFontColor = NSKeyedUnarchiver.unarchiveObject(with: noteFontColorData) as? UIColor
                    else{
                        print("getNoteText----------------NoteAttributes case failure!!!!!")
                        return nil
                }
                let noteFontsize = noteAttribute.note_FontSize
                let noteContent = noteAttribute.note_Content
                
                noteText.text = noteContent
                noteText.textColor = noteFontColor
                noteText.font = UIFont.boldSystemFont(ofSize: CGFloat(noteFontsize))
                
            }else{
                print("There's no image")
            }
            
            
        }
        return noteText
    }
    
    func getNoteImage(boardID: Int16,noteID: Int16) -> [UIImage]? {
        let searchField = "note_BoardID"
        let keyword = "\(boardID)"
        var noteImages = [UIImage]()
        
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        
        for noteAttribute:NoteData in result{
            if noteAttribute.note_ID == noteID {
                guard let noteImageData = noteAttribute.note_Image
                    else{
                        print("getNoteImage----------------NoteAttributes case failure!!!!!")
                        return nil
                }
                guard let noteImgs = noteDataManager.transformDataToImage(imageJSONData: noteImageData)
                    else{
                        print("transformDataToImage----------------NoteAttributes case failure!!!!!")
                        return nil
                }
                
                noteImages = noteImgs
            }else{
                print("There's no image")
            }
        }
        return noteImages
    }
    

}
