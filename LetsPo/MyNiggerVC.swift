//
//  MyNiggerVC.swift
//  LetsPo
//
//  Created by Pin Liao on 25/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

let friendComing = Notification.Name("friendComing")

class MyNiggerVC: UITableViewController {
    
    var friendsSelfie = [UIImage]()
    var friends = [String]()
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: friendComing,
                                                  object: nil)
           }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendNumber = friendDataManager.count()
        
        for i in 0..<friendNumber{
            let friend = friendDataManager.itemWithIndex(index: i)
            friends.append(friend.friend_FriendName!)
            if friend.friend_FriendSelfie == nil {
                friendsSelfie.append(#imageLiteral(resourceName: "success"))
            }else{
                if let selfieData = friend.friend_FriendSelfie {
                    let selfie = UIImage(data: selfieData as Data)
                    
                    friendsSelfie.append(selfie!)
                }
            }
        }
        
        self.navigationItem.leftItemsSupplementBackButton = true
        let addFrienfBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
        navigationItem.rightBarButtonItem = addFrienfBtn
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFriendComing),
                                               name: friendComing,
                                               object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func newFriendComing(notification:Notification) {
        
        friendsSelfie.removeAll()
        friends.removeAll()
        
        let friendNumber = friendDataManager.count()
        
        for i in 0..<friendNumber{
            let friend = friendDataManager.itemWithIndex(index: i)
            friends.append(friend.friend_FriendName!)
            if friend.friend_FriendSelfie == nil {
                friendsSelfie.append(#imageLiteral(resourceName: "success"))
            }else{
                if let selfieData = friend.friend_FriendSelfie {
                    let selfie = UIImage(data: selfieData as Data)
                    
                    friendsSelfie.append(selfie!)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func addFriend() {
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "FindNiggerVC") as! FindNiggerVC
        present(nextPage, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendsSelfie.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NiggerCell", for: indexPath)
        
        guard let finalCell = cell as? MyNiggerCell else {
            print("XXXXXXXXXXXXXXx")
            return cell
        }
        
        finalCell.friendImage.image = friendsSelfie[indexPath.row]
        finalCell.friendName.text = friends[indexPath.row]
        
        
        return finalCell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
