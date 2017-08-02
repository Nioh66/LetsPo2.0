//
//  GetBoardNotes.swift
//  LetsPo
//
//  Created by Pin Liao on 28/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import Foundation
import UIKit
class GetBoardNotes {
    
    func getNotesSelfie(boardID: Int16) -> [UIImage]? {
        let searchField = "note_BoardID"
        let keyword = "\(boardID)"
        var allNotes = [UIImage]()
        
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        
        for noteAttribute:NoteData in result{
            
                //let noteID = noteAttribute.note_ID
            
            
                guard let noteSelfieData = noteAttribute.note_Selfie,
                    let noteSelfieImage = UIImage(data: noteSelfieData as Data)
                    else{
                        print("noteSelfieImage----------------NoteAttributes case failure!!!!!")
                        return nil
                }
            
                allNotes.append(noteSelfieImage)
            }
        return allNotes
    }
    
    func presentNotes(boardID: Int16, selfies: [UIImage]) -> [UIImageView]? {
     
        let searchField = "note_BoardID"
        let keyword = "\(boardID)"
        var allNotesSelfie = [UIImageView]()
        var resultCount = 0
        
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        
        for noteAttribute:NoteData in result{
            
                let noteX = noteAttribute.note_X
                let noteY = noteAttribute.note_Y
            
            let noteSelfie = UIImageView(frame: CGRect(x: noteX, y: noteY, width: 100, height: 100))
            
            noteSelfie.image = selfies[resultCount]
            allNotesSelfie.append(noteSelfie)
            resultCount += 1
        }
        return allNotesSelfie
    }
    
    func getBgImage(boardID: Int16) -> UIImage? {
        let searchField = "board_Id"
        let keyword = "\(boardID)"
        var boardBgImage = UIImage()
        guard let result = boardDataManager.searchField(field: searchField, forKeyword: keyword) as? [BoardData] else{
            print("Result case to [BoardData] failure!!!!")
            return nil
        }
        
        for boardBg:BoardData in result{
           guard let bgImageData = boardBg.board_BgPic as Data?,
            let bgImage = UIImage(data: bgImageData) else{
                print("BgImage case failure!!!!!!")
                return nil
            }
            boardBgImage = bgImage
        }
        return boardBgImage
    }
    func getNotesID(boardID: Int16) -> [Int16]? {
        let searchField = "note_BoardID"
        let keyword = "\(boardID)"
        var allNotesID = [Int16]()
        
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return nil
        }
        for noteAttribute:NoteData in result{
            
            let noteID = noteAttribute.note_ID
            allNotesID.append(noteID)
        }

        return allNotesID
    }
    
    
      }
