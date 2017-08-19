//
//  TabBarVC.swift
//  LetsPo
//
//  Created by Pin Liao on 25/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit
import CoreData
var noteDataManager = CoreDataManager<NoteData>.init(initWithModel: "LetsPoModel",
                                           dbFileName: "LetsPoDB.sqlite",
                                           dbPathURL: nil,
                                           sortKey: "note_ID",
                                           entityName: "NoteData")
var memberDataManager = CoreDataManager<MemberData>.init(initWithModel: "LetsPoModel",
                                           dbFileName: "LetsPoDB.sqlite",
                                           dbPathURL: nil,
                                           sortKey: "member_ID",
                                           entityName: "MemberData")

var boardDataManager = CoreDataManager<BoardData>.init(initWithModel: "LetsPoModel",
                                                       dbFileName: "LetsPoDB.sqlite",
                                                       dbPathURL: nil,
                                                       sortKey: "board_CreateTime",
                                                       entityName: "BoardData")
var selfBoardDataManager = CoreDataManager<SelfBoardData>.init(initWithModel: "LetsPoModel",
                                                       dbFileName: "LetsPoDB.sqlite",
                                                       dbPathURL: nil,
                                                       sortKey: "selfBoard_ID",
                                                       entityName: "SelfBoardData")
var selfNoteDataManager = CoreDataManager<SelfNoteData>.init(initWithModel: "LetsPoModel",
                                                       dbFileName: "LetsPoDB.sqlite",
                                                       dbPathURL: nil,
                                                       sortKey: "selfNote_ID",
                                                       entityName: "SelfNoteData")
var friendDataManager = CoreDataManager<FriendData>.init(initWithModel: "LetsPoModel",
                                                             dbFileName: "LetsPoDB.sqlite",
                                                             dbPathURL: nil,
                                                             sortKey: "friend_ID",
                                                             entityName: "FriendData")




class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
