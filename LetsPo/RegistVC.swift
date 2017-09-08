//
//  RegistVC.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/8/10.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

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
    var selfImage:UIImage? = nil
    var memberID:Int64? = nil
    let resetAccount = Notification.Name("resetAccount")
    let advanceImageView = AdvanceImageView()
    
    let uploadMachine = AlamoMachine()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        emailTextField.placeholder = "請輸入e-mail"
        nameTextField.placeholder = "請輸入名字"
        passTextField.placeholder = "請輸入>6位字母或數字密碼"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tap)

       
        // 個人照片 frame
        personalImage.frame = CGRect(x: view.center.x, y: 30, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.width/2)
        personalImage.backgroundColor = UIColor.black
        personalImage.layer.cornerRadius = personalImage.frame.size.width / 2
        personalImage.layer.masksToBounds = true
       
    }
    func hideKeyboard(tapG:UITapGestureRecognizer){
        
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        
    }

    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let duration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var frame = self.view.frame
                frame.origin.y = keyboardFrame.minY - self.view.frame.height
                self.view.frame = frame
            })
        }
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
            upload()
        }
    }
    func upload() {
        advanceImageView.prepareIndicatorView(view: self.view)
        var selfieData:String? = nil
        
        if let selfImage = selfImage{
        let selfImageData = UIImageJPEGRepresentation(selfImage, 0.8)
            let base64String = selfImageData?.base64EncodedString()
//        let strImageData = String.init(data: selfImageData!, encoding: .utf8)
            selfieData = base64String
        }
        let registDic:[String:Any?] = ["Member_Name":nameTextField.text,
                                       "Member_Password":passTextField.text,
                                       "Member_Email":emailTextField.text,
                                       "Member_Selfie":selfieData]
        uploadMachine.doPostJobWith(urlString: uploadMachine.NEW_MEMBER, parameter: registDic) { (error, rtn) in
            if error != nil{
                print(error!)
            }
            else{
                let response = rtn!
                let result = response["result"] as! Bool
                if result {
                    guard let rspMemberID = response["Member_ID"] as? Int64 else{
                        return
                    }
                    print(rspMemberID)
                          self.memberID = rspMemberID

                    if self.memberID != nil{
                        self.saveMamberInfo()
                        memberDataManager.saveContexWithCompletion(completion: { (success) in
                            if(success){
                                print("-success-")
//                                NotificationCenter.default.post(name: self.resetAccount, object: nil, userInfo: nil)
//                                for controller in (self.navigationController?.viewControllers)!
//                                {
//                                    if controller.isKind(of: AccountVC.self) == true{
//                                        
//                                        self.dismiss(animated: false) {
//                                            self.advanceImageView.advanceStop(view: self.view)
//                                            self.navigationController?.popToViewController(controller, animated: false)
//                                        }
//                                        break
//                                    }
//                                }
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                }else{
                    
                    self.sameEmailAler()
                    self.advanceImageView.advanceStop(view: self.view)
                }
            }
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
        if password.characters.count >= 6 {
            checkOk = true
        }else {
            checkOk = false
        }
        
        return checkOk
    }
    
    func alertMakeSure(){
        let alert = UIAlertController(title: "資料填寫不完全", message: "", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
    
    func sameEmailAler(){
        let alert = UIAlertController(title: "", message: "此E-mail已註冊", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        

    }
    func saveMamberInfo(){
        let finalItem = memberDataManager.createItem()
        
        finalItem.member_Name = nameTextField.text
        finalItem.member_Email = emailTextField.text
        finalItem.member_Password = passTextField.text
        finalItem.member_ID = memberID!
        UserDefaults.standard.set(memberID, forKey: "Member_ID")
        if selfImage != nil {
            guard let imagedata = UIImagePNGRepresentation(selfImage!) else {
                return
            }
            finalItem.member_Selfie = imagedata as NSData
            print("\(finalItem)")

        }
        
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        
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
        
        
        NotificationCenter.default.post(name: selfieBgImageNN, object: nil, userInfo: ["selfieBg":imageX])
        
        //Change selfie image
        personalImage.image = imageX
        selfImage = imageX
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
