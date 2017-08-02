//
//  NewPostVC.swift
//  LetsPo
//
//  Created by Pin Liao on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit


class NewPostVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate ,UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource{

    
    @IBOutlet weak var noteCollectionView: UICollectionView!
    
    @IBOutlet weak var showCellImage: UIImageView!
    @IBOutlet weak var thePost: Note!
    var fontSizeData:Double = 14.0
    
    var myTextView = NoteText()
    var textContainer = NSTextContainer()

    var imageForCell = [UIImage]()
    let cellSpace:CGFloat = 1
    
    var myInputView : UIView?
    var keyboardHeight:CGFloat? = nil
    var photographer = UIImagePickerController()
    var imageFactory = MyPhoto()
    let resetNote = Notification.Name("resetNote")

    var allNoteData = [String:Any]()
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: resetNote,
                                                  object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        //let documnetPath = documentPaths[0] as! String
        print(documentPaths)
        
        
        showCellImage.layer.cornerRadius = 10.0
        showCellImage.layer.masksToBounds = true
        
        myTextView.frame = CGRect(x: 0, y: 0, width: thePost.frame.size.width, height: thePost.frame.size.height*0.8)
        thePost.clipsToBounds = true
       
        DispatchQueue.main.async {
        self.thePost.addSubview(self.myTextView)
        let collectBgcolor = UIColor(cgColor: self.thePost.shapeLayer.fillColor!)
        self.noteCollectionView.backgroundColor = collectBgcolor

        self.thePost.addSubview(self.noteCollectionView)
        }
        
        //        myTextView.setNeedsDisplay()
        //        myScrollView.addSubview(myTextView)
        if imageForCell.count == 1{
            showCellImage.image = imageForCell[0]
        }
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tap)
        
        let functionBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        functionBar.barStyle = .default
        functionBar.barTintColor = UIColor.white
        functionBar.tintColor = UIColor.darkGray
        
        var itemsArray = [UIBarButtonItem]()
        
        let keyboardBtn = UIBarButtonItem(image: UIImage(named: "hide-keyboard"), style: .plain, target: self, action: #selector(changeToKeyboard))
        let changeFCBtn = UIBarButtonItem(image: UIImage(named: "paint-brush-2"), style: .plain, target: self, action: #selector(changeFontColor))
        let changeBgCBtn = UIBarButtonItem(image: UIImage(named: "paint-brush-3"), style: .plain, target: self, action: #selector(changeBackgroundColor))
        let changeFsBtn = UIBarButtonItem(image: UIImage(named: "fontSize"), style: .plain, target: self, action: #selector(changeFontSize))
        let addFromPhotosBtn = UIBarButtonItem(image: UIImage(named: "picture-2"), style: .plain, target: self, action: #selector(addPictureBtn))
        let takePicBtn = UIBarButtonItem(image: UIImage(named: "shutter"), style: .plain, target: self, action: #selector(takePictureBtn))
        
//        let keyboardBtn = UIBarButtonItem.init(barButtonSystemItem: .bookmarks, target: self, action: #selector(changeToKeyboard))
//        let changeFCBtn = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(changeFontColor))
//        let changeFsBtn = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(changeFontSize))
//        let changeBgCBtn = UIBarButtonItem.init(barButtonSystemItem: .compose, target: self, action: #selector(changeBackgroundColor))
//        let addFromPhotosBtn = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(addPictureBtn))
//        let takePicBtn = UIBarButtonItem.init(barButtonSystemItem: .camera, target: self, action: #selector(takePictureBtn))
        
        itemsArray.append(keyboardBtn)
        itemsArray.append(changeFCBtn)
        itemsArray.append(changeFsBtn)
        itemsArray.append(changeBgCBtn)
        itemsArray.append(addFromPhotosBtn)
        itemsArray.append(takePicBtn)
        
        functionBar.items = itemsArray
        functionBar.sizeToFit()
        //       functionBar.tintColor = UIColor.red  案件顏色
        
        functionBar.setItems(itemsArray, animated: true)
        
        myTextView.inputAccessoryView = functionBar
        self.setKeyboardObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(reset),
                                               name: resetNote,
                                               object: nil)
        

    }
 
    func reset(notification:Notification) {
       
        
        thePost.giveMeFreshNewNote()
        myTextView.giveMeFreshNewNoteText()
        self.noteCollectionView.backgroundColor = UIColor(red: 253.0/255.0,green: 237.0/255.0,blue: 166.0/255.0,alpha: 1.0)

        
//        let noteVC = storyboard?.instantiateViewController(withIdentifier: "NewPost")
//        self.present(noteVC!, animated: false, completion: nil)
//        self.dismiss(animated: false, completion: nil)
//    
    }

    
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        let newPostSegue = segue.destination as! BoardSettingVC
        newPostSegue.thePost = thePost

        let resizeNote = thePost.resizeNote(targetWidth: 300, targetHeight: 300, x: 0, y: 0)
        newPostSegue.resizeNote = resizeNote
        
        self.saveNoteData()
        newPostSegue.allNoteData = allNoteData
        
    }
    
    
    func setKeyboardObserver() {
        
        //      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: ncName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
      }
   
    func keyboardWillShow(kbNotification:Notification) {
        
        guard let kbInfo:[AnyHashable:Any] = kbNotification.userInfo,
            let keyboardSize:CGSize = (kbInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
            else {
                print("XXXXX")
                return
        }
        keyboardHeight = keyboardSize.height
        //        let insets:UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        //      print(keyboardHeight)
        NotificationCenter.default.post(name: .UIKeyboardWillShow, object: nil, userInfo: nil)
        
    }
    
    
    
    // MARK: Change back to keyboard
    
    func changeToKeyboard() {
        //    myInputView = nil
        myTextView.inputView = nil
        
        myTextView.reloadInputViews()
    }
    
    // MARK: Change textfont color
    
    
    func changeFontColor() {
        myInputView = nil
        
        myInputView = UIView()
        guard let ftColorInputView = myInputView
            else {
                return
        }
        
        ftColorInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 258)
        ftColorInputView.backgroundColor = UIColor.darkGray
        myTextView.inputView = ftColorInputView
        
        let buttonWidth = (ftColorInputView.frame.size.width)/5
        let buttonHeight = (ftColorInputView.frame.size.height)/2
        
        
        let red =
            MyButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 111,
                     bgColor: UIColor.red,imageStr:"colors_2")
        red.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let green =
            MyButton(frame: CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 112,
                     bgColor: UIColor.green,imageStr:"colors_2")
        green.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let blue =
            MyButton(frame: CGRect(x: buttonWidth*2, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 113,
                     bgColor: UIColor.blue,imageStr:"colors_2")
        blue.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let cyan =
            MyButton(frame: CGRect(x: buttonWidth*3, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 114,
                     bgColor: UIColor.cyan,imageStr:"colors_2")
        cyan.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let yellow =
            MyButton(frame: CGRect(x: buttonWidth*4, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 115,
                     bgColor: UIColor.yellow,imageStr:"colors_2")
        yellow.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let brown =
            MyButton(frame: CGRect(x: 0, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 116,
                     bgColor: UIColor.brown,imageStr:"colors_2")
        brown.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let gray =
            MyButton(frame: CGRect(x: buttonWidth, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 117,
                     bgColor: UIColor.gray,imageStr:"colors_2")
        gray.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let LightGray =
            MyButton(frame: CGRect(x: buttonWidth*2, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 118,
                     bgColor: UIColor.lightGray,imageStr:"colors_2")
        LightGray.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let white =
            MyButton(frame: CGRect(x: buttonWidth*3, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 119,
                     bgColor: UIColor.white,imageStr:"colors_2")
        white.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let black =
            MyButton(frame: CGRect(x: buttonWidth*4, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 120,
                     bgColor: UIColor.black,imageStr:"colors_2")
        black.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        
        ftColorInputView.addSubview(red)
        ftColorInputView.addSubview(green)
        ftColorInputView.addSubview(blue)
        ftColorInputView.addSubview(cyan)
        ftColorInputView.addSubview(yellow)
        ftColorInputView.addSubview(brown)
        ftColorInputView.addSubview(gray)
        ftColorInputView.addSubview(LightGray)
        ftColorInputView.addSubview(white)
        ftColorInputView.addSubview(black)
        ftColorInputView.becomeFirstResponder()
        myTextView.reloadInputViews()
    }
    
    func changeFcBtn(button:UIButton) {
        myTextView.changeFontColor(tag: button.tag)
    }
    
    
    // MARK: Change font size
    func changeFontSize() {
        
        myInputView = nil
        
        myInputView = UIView()
        guard let fontSizeInputview = myInputView
            else {
                return
        }
        
        fontSizeInputview.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 258)
        fontSizeInputview.backgroundColor = UIColor.white
        myTextView.inputView = fontSizeInputview
        
        let fontSlider = UISlider()
        fontSlider.frame = CGRect(x: 15, y: ((fontSizeInputview.frame.height)/2)-30, width: fontSizeInputview.frame.size.width - 30, height: 30)
        fontSlider.value = Float(fontSizeData)
        fontSlider.maximumValue = 120
        fontSlider.minimumValue = 14
        fontSlider.tintColor = UIColor.darkGray
        fontSlider.thumbTintColor = UIColor.ownColor
        fontSlider.addTarget(self, action: #selector(changeFSSlider(slider:)), for: .valueChanged)
        fontSizeInputview.addSubview(fontSlider)
        fontSizeInputview.becomeFirstResponder()
        myTextView.reloadInputViews()
        
        
    }
    
    func changeFSSlider(slider:UISlider) {
        let sliderValue = CGFloat(slider.value)
        myTextView.font = UIFont.boldSystemFont(ofSize: sliderValue)
        fontSizeData = Double(sliderValue)
    }
    
    
    
    // MARK: Change post background color
    
    func changeBackgroundColor() {
        let posterColor = UIColor(red: 253.0/255.0, green: 237.0/255.0, blue: 166.0/255.0, alpha: 1.0)
        
        myInputView = nil
        
        myInputView = UIView()
        guard let BgColorInputView = myInputView
            else {
                return
        }
        BgColorInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 258)
        BgColorInputView.backgroundColor = UIColor.darkGray
        myTextView.inputView = BgColorInputView
        
        let buttonWidth = (BgColorInputView.frame.size.width)/5
        let buttonHeight = (BgColorInputView.frame.size.height)/2
        
        
        let red =
            MyButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 101,
                     bgColor: UIColor.darkBlueC,imageStr:"color_3")
        red.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let green =
            MyButton(frame: CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 102,
                     bgColor: UIColor.darkGreenC,imageStr:"color_3")
        green.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let blue =
            MyButton(frame: CGRect(x: buttonWidth*2, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 103,
                     bgColor: UIColor.lightGreenC,imageStr:"color_3")
        blue.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let cyan =
            MyButton(frame: CGRect(x: buttonWidth*3, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 104,
                     bgColor: UIColor.posterColor,imageStr:"color_3")
        cyan.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let original =
            MyButton(frame: CGRect(x: buttonWidth*4, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 105,
                     bgColor: UIColor.orangeC,imageStr:"color_3")
        original.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let brown =
            MyButton(frame: CGRect(x: 0, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 106,
                     bgColor: UIColor.darkRedC,imageStr:"color_3")
        brown.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let gray =
            MyButton(frame: CGRect(x: buttonWidth, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 107,
                     bgColor: UIColor.darkGreyC,imageStr:"color_3")
        gray.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let LightGray =
            MyButton(frame: CGRect(x: buttonWidth*2, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 108,
                     bgColor: UIColor.lightGreyC,imageStr:"color_3")
        LightGray.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let white =
            MyButton(frame: CGRect(x: buttonWidth*3, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 109,
                     bgColor: UIColor.skinC,imageStr:"color_3")
        white.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let black =
            MyButton(frame: CGRect(x: buttonWidth*4, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "",
                     tag: 110,
                     bgColor: UIColor.darkSkinC,imageStr:"color_3")
        black.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        
        BgColorInputView.addSubview(red)
        BgColorInputView.addSubview(green)
        BgColorInputView.addSubview(blue)
        BgColorInputView.addSubview(cyan)
        BgColorInputView.addSubview(original)
        BgColorInputView.addSubview(brown)
        BgColorInputView.addSubview(gray)
        BgColorInputView.addSubview(LightGray)
        BgColorInputView.addSubview(white)
        BgColorInputView.addSubview(black)
        BgColorInputView.becomeFirstResponder()
        myTextView.reloadInputViews()
    }
    
    
    func changeBgBtn(button:UIButton) {
        thePost.changeBgColor(button: button)
        let collectBgcolor = UIColor(cgColor: thePost.shapeLayer.fillColor!)
        noteCollectionView.backgroundColor = collectBgcolor

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
    
    // MARK: HideKeyboard
    func hideKeyboard(tapG:UITapGestureRecognizer){
        // self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.myTextView.resignFirstResponder()
        }
        
    }
    
    
    // MARK: Photo method
    
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
        
       // UIImageWriteToSavedPhotosAlbum(imageX, self, #selector(saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        
        imageForCell.append(imageX)
        noteCollectionView.reloadData()
    //    myTextView.addImageInText(image: imageX, NoteView: thePost)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: Collectionview delegate method
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageForCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NoteImageCell
        
        
        cell.noteImage.image = imageForCell[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showCellImage.image = imageForCell[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = collectionView.frame.size.height
        let cellSize = CGSize(width: length, height: length)
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpace
    }
    
    // MARK: Save note data

    func saveNoteData() {
        
        allNoteData.removeAll()
        
        let noteContent = myTextView.text


        
        
        
        guard let fontColor = myTextView.textColor
        else {
            return
        }
        let textColorData = NSKeyedArchiver.archivedData(withRootObject: fontColor ) as NSData
        let noteFontColor = textColorData
        let noteFontSize = fontSizeData
        let noteImage = imageForCell
        
        let noteBgColor = noteDataManager.transformColorToData(targetColor: thePost.uploadcolor)

        allNoteData = ["noteContent":noteContent ?? "",
                       "noteBgColor":noteBgColor,
                       "noteFontColor":noteFontColor ,
                       "noteFontSize":noteFontSize,
                        "noteImage":noteImage]
          }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}

    
