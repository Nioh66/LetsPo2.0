//
//  PersonalDetailVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/23.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit

class PersonalDetailVC: UIViewController ,UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
    @IBOutlet weak var personalImage: UIImageView!
    @IBOutlet weak var selfDataTable: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    let cellTitle = ["ID:","Name:","E-Mail:"]
    let cellSubtitle = ["9527","PinLiao","nioh946@gmail.com"]
    let selfieBgImageNN = Notification.Name("selfie")
    var photographer = UIImagePickerController()
    var imageFactory = MyPhoto()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = cellSubtitle[1]
        setLabelWithFrame()
        personalImage.backgroundColor = UIColor.black
        personalImage.layer.cornerRadius = personalImage.frame.size.width / 2
        personalImage.layer.masksToBounds = true
//      personalImage.frame = CGRect(x: self.view.center.x - 75, y: 75, width: 150, height: 150)
        
       
    }
    @IBAction func editeSelfie(_ sender: Any) {
    let alert = UIAlertController(title: "Edite", message: "Please select source", preferredStyle:.alert)
    let camera = UIAlertAction(title: "Camera", style: .default) { _ in
        self.photographer.sourceType = .camera
        self.photographer.cameraDevice = .rear
        self.photographer.allowsEditing = true
        self.photographer.delegate = self
        self.present(self.photographer, animated: true, completion: nil)
        }
        
    let photos = UIAlertAction(title: "Photos", style: .default) { _ in
        
        self.photographer.sourceType = .photoLibrary
        self.photographer.allowsEditing = true
        self.photographer.delegate = self
        self.present(self.photographer, animated: true, completion: nil)
        
        }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
       
        alert.addAction(camera)
        alert.addAction(photos)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        cell?.textLabel?.text = cellTitle[indexPath.row]
        cell?.detailTextLabel?.text = cellSubtitle[indexPath.row]
        cell?.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        cell?.selectionStyle = .default
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setLabelWithFrame(){
        nameLabel.font = UIFont.systemFont(ofSize: 25)
        nameLabel.frame = CGRect(x: 0, y: self.view.center.y * 0.70, width: UIScreen.main.bounds.size.width, height: 30)
      }
   
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.title = "個人資料"
   //     self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editBtnAction))
    }
    
    func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let saveAlert = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(saveAlert, animated: true)
        } else {
            let saveAlert = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(saveAlert, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            else{
                return
        }
        //resize image
        guard let imageX = imageFactory.resizeFromImage(input: image)
            else {
                return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageX, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        
        
        NotificationCenter.default.post(name: selfieBgImageNN, object: nil, userInfo: ["selfieBg":imageX])
        
        //Change selfie image
        personalImage.image = imageX

        
        self.dismiss(animated: true, completion: nil)
        
    }

    
}




//    func editBtnAction(){
//        let nextPage = storyboard?.instantiateViewController(withIdentifier: "InfoEditVC") as? InfoEditVC
//        nextPage?.navigationItem.leftItemsSupplementBackButton = true
//        navigationController?.pushViewController(nextPage!, animated: true)
//    }
//


