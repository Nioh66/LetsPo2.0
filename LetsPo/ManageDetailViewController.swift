//
//  ManageDetailViewController.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class ManageDetailViewController: UIViewController ,UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var backBtn: UIButton!
    let boardSettingNN = Notification.Name("boardSetting")
    let newNoteComingNN = Notification.Name("newPublicNoteComing")
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: boardSettingNN,object: nil)
        NotificationCenter.default.removeObserver(self,name: newNoteComingNN,object: nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name(rawValue: "notificationCenter"),object: nil)
    }
    
    var dataManagerCount = Int()
    var selectIndexID = Int16()
    var selectIDformMap = Int16()
    let getBoardPosts = GetBoardNotes()
    var secondTime:Bool!
    var fromNewNote:Bool!
    var deleteBtns = [[String:UIButton]]()
    var hidehide:Bool!
    var imagArr = [UIImageView]()
    var deleteBtn = deleteView()
    var deleteBtnControll = manageView()
    //for server
    var deleteNoteX = Double()
    var deleteNoteY = Double()
    var deleteBoardLat = Double()
    var deleteBoardLon = Double()
    var memberID:Int? = nil
    let uploadMachine = AlamoMachine()
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var boardSettingBtn: UIButton!
    @IBOutlet weak var addPostBtn: UIButton!
    @IBOutlet weak var deletePostBtn: UIButton!
    
    @IBOutlet weak var detailNoteAppearPoint: UIView!
    @IBOutlet weak var backGroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        secondTime = false
        fromNewNote = false
        
        self.addingObserver()
        
        dataManagerCount = boardDataManager.count()
        
        print("select Index ID \(selectIndexID)")
        for i in 0 ..< dataManagerCount{
            let item = boardDataManager.itemWithIndex(index: i)
            let boardId = item.board_Id
                if boardId == selectIndexID {
                let title = item.board_Title
                titleLabel.text = title ?? ""
                //For server
                    deleteBoardLat = item.board_Lat
                    deleteBoardLon = item.board_Lon
            }
        }
    }
    
    func goToDetail(gestureRecognizer:TapToShowDetail){
        
        let detailPostID = gestureRecognizer.postID
        let detailboardID = gestureRecognizer.boardID
        print("--PostID\(detailPostID)")
        
        let publicPostDetailVC =  storyboard?.instantiateViewController(withIdentifier: "PublicPostDetailVC") as! PublicPostDetailVC
        publicPostDetailVC.modalPresentationStyle = .popover
        publicPostDetailVC.publicPostID = detailPostID
        publicPostDetailVC.boardID = detailboardID
        let popDetailPostVC = publicPostDetailVC.popoverPresentationController
        popDetailPostVC?.delegate = self
        popDetailPostVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popDetailPostVC?.sourceView = detailNoteAppearPoint
        popDetailPostVC?.sourceRect = detailNoteAppearPoint.bounds
        present(publicPostDetailVC, animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func boardSettingBtnPressed(_ sender: UIButton) {
        // PublicBoardSettingVC
        
        print("boardSettingBtnPressed action")
        
        let publicBoardSettinglVC =  storyboard?.instantiateViewController(withIdentifier: "PublicBoardSettingVC") as! PublicBoardSettingVC
        publicBoardSettinglVC.modalPresentationStyle = .popover
        publicBoardSettinglVC.boardID = selectIndexID
        publicBoardSettinglVC.preferredContentSize = CGSize(width: 125, height: 100)
        let popDetailPostVC = publicBoardSettinglVC.popoverPresentationController
        popDetailPostVC?.delegate = self
        popDetailPostVC?.permittedArrowDirections = .up
        popDetailPostVC?.sourceView = boardSettingBtn
        popDetailPostVC?.sourceRect = boardSettingBtn.bounds
        present(publicBoardSettinglVC, animated: true, completion: nil)
        
        
    }
    
    
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        titleLabel.isHidden = false
        backBtn.isHidden = false
        hidehide = false
        dataManagerCount = boardDataManager.count()
        if selectIndexID == 0 {
            print("nil")
            return
        }
        guard let postsScreenShot = getBoardPosts.getNotesSelfie(boardID: selectIndexID),
            let allPosts = getBoardPosts.presentNotes(boardID: selectIndexID, selfies: postsScreenShot),
            let bgImage = getBoardPosts.getBgImage(boardID: selectIndexID),
            let allPostsID = getBoardPosts.getNotesID(boardID: selectIndexID)
            else{
                return
        }
        print(backGroundImage)
        
        backGroundImage.image = bgImage
        backGroundImage.isUserInteractionEnabled = true
        
        for (index,imageview) in allPosts.enumerated(){
            print(index)
            imageview.isUserInteractionEnabled = true
            imageview.backgroundColor = UIColor.clear
            
            let detailBtn = TapToShowDetail(target: self, action: #selector(goToDetail(gestureRecognizer:)))
            detailBtn.postImageView = imageview
            detailBtn.postID = allPostsID[index]
            detailBtn.boardID = selectIndexID
            
            // 每張note上的刪除鈕
            deleteBtn = deleteView(type: .custom)
            deleteBtn.frame = CGRect(x: 3, y: 3, width: 20, height: 20)
            deleteBtn.setImage(UIImage(named: "garbage"), for: .normal)
            deleteBtn.isHidden = true
            deleteBtn.addTarget(self, action: #selector(delete(sender:)), for: .touchUpInside)
            deleteBtn.postImageView = imageview
            deleteBtn.postID = allPostsID[index]
            
            // 頁面上的刪除鈕 總控
            deleteBtnControll = manageView(type:.custom)
            deleteBtnControll.frame = CGRect(x: 3, y:(view.frame.size.height) * 0.9, width: 40, height: 40)
            deleteBtnControll.setImage(UIImage(named: "garbage"), for: .normal)
            deleteBtnControll.addTarget(self, action: #selector(deleteBtnAction(sender:)), for: .touchUpInside)
            deleteBtnControll.postID = allPostsID[index]
            
            imageview.addGestureRecognizer(detailBtn)
            
            // 如果是普通的第二次進入這頁 先拔掉所有的 imageV
            if secondTime == true && fromNewNote == false {
                DispatchQueue.main.async() {
                    // 不知道為什麼要在 DispatchQueue 拔，但網路上都這樣寫
                    imageview.removeFromSuperview()
                    
                }
            }
            // 如果是透過新增跳轉到這一頁 則不拔掉最後一個新增的 view
            // 為什麼透過新增的 view 不能拔掉呢？ 我不知道.... (還沒addSubView所以不能拔？)
            if secondTime == true && fromNewNote == true && index < allPosts.count - 1 {
                DispatchQueue.main.async() {
                    imageview.removeFromSuperview()
                }
            }
            backGroundImage.addSubview(imageview)
            // 刪除鈕上加上tag ID
            deleteBtn.tag = Int(allPostsID[index])
            
            // 把所有刪除鈕妝到按鈕陣列 才能一起控制
            deleteBtns.append(["id":deleteBtn])
            deleteBtnControll.button = deleteBtns
            deleteBtn.postImageView?.addSubview(deleteBtn)
            deleteBtnControll.postImageView = deleteBtn

            
        }
        // fromNewNote 設成 false 等一下跳來跳去 又是一條好漢 繼續全部拔掉再貼上
        fromNewNote = false
        secondTime = true
        backGroundImage.addSubview(deleteBtnControll)
        
    }
    // MARK: Adding NotificationCenter observer
    func addingObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(newNoteComing), name: newNoteComingNN, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(theChooseOne),
                                               name: NSNotification.Name(rawValue: "notificationCenter"),
                                               object: nil)
    }
    
    func deleteBtnAction(sender:manageView) {
        //控制所有小垃圾桶的隱藏和開啟
        if hidehide != false {
            guard let btnCount = sender.button?.count else {
                return
            }
            for i in 0 ..< Int(btnCount) {
                let senderBtn = sender.button?[i]["id"]
                DispatchQueue.main.async {
                    senderBtn?.isHidden = true
                }
            }
            hidehide = false
        }else {
            let btnCount = sender.button?.count
            for i in 0 ..< Int(btnCount!) {
                let senderBtn = sender.button?[i]["id"]
                DispatchQueue.main.async {
                    senderBtn?.isHidden = false
                }
            }
            hidehide = true
        }
    }
    
    // MARK: - delete note form core Data
    func delete(sender:deleteView) {
        let tag = sender.tag
        for i in deleteBtns {
            if tag == i["id"]?.tag && tag == Int(sender.postID) {
                coreDataDeleteAndSaveMethod(note_ID: "\(tag)",board_id:"\(selectIndexID)")
                // 暫時隱藏被刪除的note 反正出去回來後就會重刷
                sender.postImageView?.isHidden = true
                
            }
            // 刪除後 隱藏所有刪除鈕並拍照刷新
            i["id"]?.isHidden = true
            hidehide = false
            
        }
        uploadBoardBg()
        
        memberID = UserDefaults.standard.integer(forKey: "Member_ID")
        
        if(memberID != 0){
            self.deleteServerNoteData()
        }
    }
    
    // MARK: Server delete
    func deleteServerNoteData() {
        print(memberID)
        print(deleteBoardLat)
        print(deleteBoardLon)
        print(deleteNoteX)
        print(deleteNoteY)
        let deleteDic:[String:Any?] = ["Board_CreateMemberID":memberID!,
                                       "Board_Lat":deleteBoardLat,
                                       "Board_Lon":deleteBoardLon,
                                       "Note_X":deleteNoteX,
                                       "Note_Y":deleteNoteY]
        
        uploadMachine.doPostJobWith(urlString: uploadMachine.DELETE_NOTE, parameter: deleteDic) { (error, response) in
            if error != nil{
                print("Delete Note failure!!")
                print(error!)
            }
                print("Delete Note complete!!")
        }
    }
    
    func coreDataDeleteAndSaveMethod(note_ID:String,board_id:String){
        // 搜索並刪除被刪除的note
        let searchField = "note_BoardID"
        let keyword = "\(board_id)"
        guard let result = noteDataManager.searchField(field: searchField, forKeyword: keyword) as? [NoteData] else{
            print("Result case to [NoteData] failure!!!!")
            return
        }
        for noteAttribute:NoteData in result {
            let noteID = noteAttribute.note_ID
            let boardID = noteAttribute.note_BoardID
            var imageData:NSData? = nil
            if let image = noteAttribute.note_Image {
                imageData = image
            }
            //for server 
            deleteNoteX = noteAttribute.note_X
            deleteNoteY = noteAttribute.note_Y
            
            if "\(noteID)" == note_ID {
                print("noteID \(noteID),boardID \(boardID)")
                noteDataManager.deleteItem(item: noteAttribute)
                noteDataManager.saveContexWithCompletion(completion: { (success) in
                    print("delete note with all image success")
                })
                if imageData != nil {
                    print("imageData not nil")
                    self.removeImageformDocument(items:imageData!)
                }
            }
        }
    }
    
    func removeImageformDocument(items:NSData) {
        // 取得欲刪除的note的照片路徑 並刪除
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: items as Data),
            let myAlbum = json as? [String: Any] else{
                print("imageJSONData transform to result failure!!!!!")
                return
        }
        for index in 0 ..< myAlbum.count {
            guard let stringPath = myAlbum["Image\(index)"] as? String
                else {
                    print("------String transform to URL failure------")
                    return
            }
            let filePath = "\(dirPath)/\(stringPath)"
            do {
                try fileManager.removeItem(atPath: filePath)
                print("delete image OK")
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }
    
    func uploadBoardBg() {
        guard let newBoardPic = self.view.boardScreenShot(),
            let newBoardBg = UIImageJPEGRepresentation(newBoardPic, 1.0) as NSData? else{
                return
        }
        
        
        let oldBoardData = boardDataManager.searchField(field: "board_Id", forKeyword: "\(selectIndexID)") as! [BoardData]
        
        for data:BoardData in oldBoardData{
            if data.board_Id == selectIndexID {
                data.board_CreateTime = NSDate()
                data.board_ScreenShot = newBoardBg
                boardDataManager.saveContexWithCompletion { (success) in
                    if (success) {
                        print("BoardData save succeed!!!")
                    }else{
                        print("BoardData save failure!!!")
                    }
                }
            }
        }
    }
    
    func theChooseOne(notification:Notification) {
        if let board_Id = notification.userInfo?["id"] as? Int16 {
            selectIndexID = board_Id
            print("notification")
        }
    }
    
    func newNoteComing(notification:Notification) {
        
        let refreshVC = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! ManageDetailViewController
        
        // how to refresh
        self.dismiss(animated: false, completion: nil)
        
        refreshVC.selectIndexID = selectIndexID
        self.present(refreshVC, animated: false, completion: nil)
        
        fromNewNote = true
        print("fromNewNote \(fromNewNote)")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newPublicNote"){
            let bgImageWithNotes = self.getBGimageWithPosts()
            let newPostSegue = segue.destination as! NewPublicPostVC
            newPostSegue.bgImage = bgImageWithNotes
            newPostSegue.boardID = selectIndexID
        }else{
            
        }
    }
    
    
    func getBGimageWithPosts() -> UIImage {
        titleLabel.isHidden = true
        backBtn.isHidden = true
        deleteBtnControll.alpha = 0.0
        boardSettingBtn.alpha = 0.0
        addPostBtn.alpha = 0.0

        
        let BGimageWithPosts = self.view.boardScreenShot()
        boardSettingBtn.alpha = 1
        addPostBtn.alpha = 1
        
        
        return BGimageWithPosts!
    }
    
}
