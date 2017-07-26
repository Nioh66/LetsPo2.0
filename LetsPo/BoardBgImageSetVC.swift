//
//  BoardBgImageSetVC.swift
//  LetsPo
//
//  Created by Pin Liao on 2017/7/20.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit

class BoardBgImageSetVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var photographer = UIImagePickerController()
    let imageFactory = MyPhoto()
    var bgImage:UIImage? = nil
    let sendBgImageNN = Notification.Name("sendBgImage")
    
    
    deinit {
      NotificationCenter.default.removeObserver(self,
                                                  name: sendBgImageNN,
                                                  object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageWidth = self.view.frame.size.width/3
        let imageHight = self.view.frame.size.height/5
        let width_Padding = self.view.frame.size.width/9
        let hight_Padding = self.view.frame.size.height/10
        
        
        
        let tapDefault01 = UITapGestureRecognizer(target: self, action: #selector(getDefault01Bg))
        let tapDefault02 = UITapGestureRecognizer(target: self, action: #selector(getDefault02Bg))
        let tapDefault03 = UITapGestureRecognizer(target: self, action: #selector(getDefault03Bg))
        let tapDefault04 = UITapGestureRecognizer(target: self, action: #selector(getDefault04Bg))

        let tapGetPhotos = UITapGestureRecognizer(target: self, action: #selector(getPhotosBg))
        let tapTakePhoto = UITapGestureRecognizer(target: self, action: #selector(takeBgPhoto))
        
        let defaultBg01 = UIImageView(frame: CGRect(x: width_Padding,
                                                    y: hight_Padding,
                                                    width: imageWidth,
                                                    height: imageHight))
        
        let defaultBg02 = UIImageView(frame: CGRect(x: (width_Padding*2)+imageWidth,
                                                    y: hight_Padding,
                                                    width: imageWidth,
                                                    height: imageHight))
        
        let defaultBg03 = UIImageView(frame: CGRect(x: width_Padding,
                                                    y: hight_Padding*2+imageHight,
                                                    width: imageWidth,
                                                    height: imageHight))
        
        let defaultBg04 = UIImageView(frame: CGRect(x: (width_Padding*2)+imageWidth,
                                                    y: hight_Padding*2+imageHight,
                                                    width: imageWidth,
                                                    height: imageHight))
        
        let photosBg = UIImageView(frame: CGRect(x: width_Padding,
                                                 y: hight_Padding*3+imageHight*2,
                                                 width: imageWidth,
                                                 height: imageHight))
        
        let takeAPhoto = UIImageView(frame: CGRect(x: (width_Padding*2)+imageWidth,
                                                   y: hight_Padding*3+imageHight*2,
                                                   width: imageWidth,
                                                   height: imageHight))
        
        defaultBg01.image = UIImage(named: "Wall2.jpg")
        //   defaultBg01.image = UIImage(contentsOfFile: "ooxx")
        defaultBg02.image = UIImage(named: "myNigger.jpg")
        defaultBg03.image = UIImage(named: "whiteboard-303145_960_720")
        defaultBg04.image = UIImage(named: "Sky.jpg")
        photosBg.image = UIImage(named: "Photos")
        takeAPhoto.image = UIImage(named: "takePhoto")
        
        
        
        defaultBg01.layer.cornerRadius = 10.0
        defaultBg01.layer.masksToBounds = true
        
        defaultBg02.layer.cornerRadius = 10.0
        defaultBg02.layer.masksToBounds = true

        defaultBg03.layer.cornerRadius = 10.0
        defaultBg03.layer.masksToBounds = true

        defaultBg04.layer.cornerRadius = 10.0
        defaultBg04.layer.masksToBounds = true

        photosBg.layer.cornerRadius = 10.0
        photosBg.layer.masksToBounds = true

        takeAPhoto.layer.cornerRadius = 10.0
        takeAPhoto.layer.masksToBounds = true
        
        defaultBg01.isUserInteractionEnabled = true
        defaultBg02.isUserInteractionEnabled = true
        defaultBg03.isUserInteractionEnabled = true
        defaultBg04.isUserInteractionEnabled = true
        photosBg.isUserInteractionEnabled = true
        takeAPhoto.isUserInteractionEnabled = true
        
        defaultBg01.addGestureRecognizer(tapDefault01)
        defaultBg02.addGestureRecognizer(tapDefault02)
        defaultBg03.addGestureRecognizer(tapDefault03)
        defaultBg04.addGestureRecognizer(tapDefault04)
        photosBg.addGestureRecognizer(tapGetPhotos)
        takeAPhoto.addGestureRecognizer(tapTakePhoto)
        
        
        
        self.view.addSubview(defaultBg01)
        self.view.addSubview(defaultBg02)
        self.view.addSubview(defaultBg03)
        self.view.addSubview(defaultBg04)
        self.view.addSubview(photosBg)
        self.view.addSubview(takeAPhoto)
        
        
        
        
           }
    
    func getDefault01Bg(){
        bgImage = UIImage(named: "Wall2.jpg")
        
        NotificationCenter.default.post(name: sendBgImageNN, object: nil, userInfo: ["myBg":bgImage!])
        
        print("get the default bg pic!")
        
        
        navigationController?.popViewController(animated: true)

        
        //        let nextVC = storyboard?.instantiateViewController(withIdentifier:"BoardSettingVC") as! BoardSettingVC
//               dismiss(animated: true, completion: nil)


    }
    func getDefault02Bg(){
        bgImage = UIImage(named: "myNigger.jpg")
        NotificationCenter.default.post(name: sendBgImageNN, object: nil, userInfo: ["myBg":bgImage!])
        print("get the default bg pic!")
        navigationController?.popViewController(animated: true)

    }

    func getDefault03Bg(){
        bgImage = UIImage(named: "whiteboard-303145_960_720")
        NotificationCenter.default.post(name: sendBgImageNN, object: nil, userInfo: ["myBg":bgImage!])
        print("get the default bg pic!")
        
        navigationController?.popViewController(animated: true)

    }

    func getDefault04Bg(){
        bgImage = UIImage(named: "Sky.jpg")
        NotificationCenter.default.post(name: sendBgImageNN, object: nil, userInfo: ["myBg":bgImage!])
        print("get the default bg pic!")
        navigationController?.popViewController(animated: true)
    }

    func getPhotosBg(){
        self.addPictureBtn()
        print("get the bg pic from photos!")
        navigationController?.popViewController(animated: true)
    }
    func takeBgPhoto(){
        self.takePictureBtn()
        print("Take the photo for bg!")
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    // MARK: Add photo from photos
    
    func addPictureBtn() {
        let checkDeviceAccesse = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        if (checkDeviceAccesse){
            
            let importImage = UIImagePickerController()
            importImage.sourceType = .photoLibrary
            importImage.delegate = self
            importImage.allowsEditing = true
            
            present(importImage, animated: true, completion: nil)
        }
        else{
            print("Your photoLibrary are unvailable")
        }
    }
    
    // MARK: Take photo
    
    func takePictureBtn() {
        let checkDeviceAccesse = UIImagePickerController.isSourceTypeAvailable(.camera)
        if (checkDeviceAccesse){
            
            photographer = UIImagePickerController()
            photographer.sourceType = .camera
            photographer.cameraDevice = .rear
            photographer.allowsEditing = true
            photographer.delegate = self
            
            present(photographer, animated: true, completion: nil)
        }
        else{
            print("Your camera are unvailable")
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        NotificationCenter.default.post(name: sendBgImageNN, object: nil, userInfo: ["myBg":imageX])
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
