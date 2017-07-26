//
//  MyPhoto.swift
//  NoteSharer
//
//  Created by Pin Liao on 2017/7/10.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import Photos
enum phototypetest{
    case xx
    case yy
    case zz
    case x1,x2,x3,x4
}

class MyPhoto:NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    
    // MARK: Add photo from photos
    
//    func addPictureBtn(viewcontroller:UIViewController ) {
//        let checkDeviceAccesse = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
//        if (checkDeviceAccesse){
//            
//            let importImage = UIImagePickerController()
//            importImage.sourceType = .photoLibrary
//            importImage.delegate = viewcontroller as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
//            importImage.allowsEditing = true
//            
//           viewcontroller.present(importImage, animated: true, completion: nil)
//        }
//        else{
//            print("Your photoLibrary are unvailable")
//        }
//    }
    
    
    func checkCameraStatus(CameraStae:UIView) {
        
    }
    
    func launchImagePicker(sourceType:UIImagePickerControllerSourceType ,VC:UIViewController){
        if (UIImagePickerController.isSourceTypeAvailable(sourceType) == false) {
            return
        }
       let myPicker = UIImagePickerController()
        myPicker.sourceType = sourceType
        myPicker.mediaTypes = [String(kUTTypeImage),String(kUTTypeMovie)]
        myPicker.delegate = self
       VC.present(myPicker, animated: true, completion: nil)
    }
    
    func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let saveAlert = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "OK", style: .default))
 //           self.present(saveAlert, animated: true)
        } else {
            let saveAlert = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            saveAlert.addAction(UIAlertAction(title: "OK", style: .default))
 //           self.present(saveAlert, animated: true)
        }
    }

    
    
    func resizeFromImage(input:UIImage) -> UIImage? {
        let maxLength:CGFloat = 1024.0
        let targetSize:CGSize
        var finalImage:UIImage?
        
        if(input.size.width <= maxLength && input.size.height <= maxLength){
            targetSize = input.size
            finalImage = input
        }else{
            if(input.size.width >= input.size.height){
                let ratio = input.size.width / maxLength
                targetSize = CGSize(width: maxLength, height: input.size.height/ratio)
            }else{
                let ratio = input.size.height / maxLength
                targetSize = CGSize(width: input.size.width/ratio, height: maxLength)
            }
        }
        
        UIGraphicsBeginImageContext(targetSize)
        input.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        guard let x = UIGraphicsGetImageFromCurrentImageContext()
            else{
                print("Fail to resize image")
                return nil
        }
        finalImage = x
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
}

       //Fixed photo capture direction

    extension UIImage {
        
        
        /// fix orientation
        public class func fixOrientation(ofImage image: UIImage) -> UIImage {
            guard image.imageOrientation != .up else {
                return image
            }
            var transform = CGAffineTransform.identity
            switch image.imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: image.size.width, y: image.size.height)
                transform = transform.rotated(by: CGFloat.pi)
                break
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0)
                transform = transform.rotated(by: CGFloat.pi/2)
                break
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: image.size.height)
                transform = transform.rotated(by: -CGFloat.pi/2)
                break
            default:
                break
            }
            
            switch image.imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: image.size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
                break
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: image.size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
                break
            default:
                break
            }
            
            guard let cgImage = image.cgImage else {
                return image
            }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: Int(cgImage.bitsPerComponent), bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
                return image
            }
            context.concatenate(transform)
            switch image.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
                break
            default:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                break
            }
            
            if let cgImg = context.makeImage() {
                return UIImage(cgImage: cgImg)
            }
            
            return image
        }

}
