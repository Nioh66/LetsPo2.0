//
//  RegistVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/10.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreData

class RegistVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var personalImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var cellTextField: UITextField!
    let cellTitle = ["E-Mail:","Password:","Name"]
    var cellSubtitle = [String]()
    let selfieBgImageNN = Notification.Name("selfie")
    var photographer = UIImagePickerController()
    var imageFactory = MyPhoto()
    var selfImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.clear
        emailTextField.placeholder = "請輸入e-mail"
        nameTextField.placeholder = "請輸入名字"
        passTextField.placeholder = "請輸入8位字母或數字密碼"
        
        // 個人照片 frame
        personalImage.backgroundColor = UIColor.black
        personalImage.layer.cornerRadius = personalImage.frame.size.width / 2
        personalImage.layer.masksToBounds = true
       
    }
    
    
    @IBAction func editSelfImage(_ sender: UIButton) {
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
    
    @IBAction func pressedRegist(_ sender: Any) {
        //值不為空
        if emailTextField.text == "" || nameTextField.text == "" || passTextField.text == "" {
            alertMakeSure()
        }else if (checkMail() != true || checkPassword() != true){
            alertMakeSure()
        }else {
            saveMamberInfo()
            memberDataManager.saveContexWithCompletion(completion: { (success) in
                if(success){
                    print("-success-")
                }
            })
        }
    }
    
    func checkMail()->Bool {
        var checkOk:Bool
        guard let mail = emailTextField.text else {return false}
        if mail.contains("@"){
            checkOk = true
        }else {
            checkOk = false
        }
        
        return checkOk
    }
    func checkPassword()->Bool {
        var checkOk:Bool
        guard let password = passTextField.text else {return false}
        if password.characters.count >= 8 {
            checkOk = true
        }else {
            checkOk = false
        }
        
        return checkOk
    }
    
    func alertMakeSure(){
        let alert = UIAlertController(title: "資料填寫不完全", message: "請從新確認", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
    func saveMamberInfo(){
        let finalItem = memberDataManager.createItem()
        
        finalItem.member_Name = nameTextField.text
        finalItem.member_Email = emailTextField.text
        finalItem.member_Password = passTextField.text
        guard let imagedata = UIImagePNGRepresentation(selfImage) else {
            
            return
        }
        finalItem.member_Selfie = imagedata as NSData
        print("\(finalItem)")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        selfImage = imageX
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
