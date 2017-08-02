//
//  SelfNewPostVC.swift
//  LetsPo
//
//  Created by Pin Liao on 24/07/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class SelfNewPostVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate ,UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource{
    
    
    
    @IBOutlet weak var selfNoteCollectionV: UICollectionView!
    @IBOutlet weak var theSelfPost: Note!
    @IBOutlet weak var showCellImage: UIImageView!
   
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
    var bgImage = UIImage()
    var allNoteData = [String:Any]()
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: resetNote, object: nil)

        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        //let documnetPath = documentPaths[0] as! String
        print(documentPaths)
        
        
        showCellImage.layer.cornerRadius = 10.0
        showCellImage.layer.masksToBounds = true
        
        myTextView.frame = CGRect(x: 0, y: 0, width: theSelfPost.frame.size.width, height: theSelfPost.frame.size.height*0.8)
        theSelfPost.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tap)
        
        let functionBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        functionBar.barStyle = .default
        
        var itemsArray = [UIBarButtonItem]()
        
        let keyboardBtn = UIBarButtonItem.init(barButtonSystemItem: .bookmarks, target: self, action: #selector(changeToKeyboard))
        let changeFCBtn = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(changeFontColor))
        let changeFsBtn = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(changeFontSize))
        let changeBgCBtn = UIBarButtonItem.init(barButtonSystemItem: .compose, target: self, action: #selector(changeBackgroundColor))
        let addFromPhotosBtn = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(addPictureBtn))
        let takePicBtn = UIBarButtonItem.init(barButtonSystemItem: .camera, target: self, action: #selector(takePictureBtn))
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        
        DispatchQueue.main.async {
            let collectBgcolor = UIColor(cgColor: self.theSelfPost.shapeLayer.fillColor!)
            self.selfNoteCollectionV.backgroundColor = collectBgcolor
            
            self.theSelfPost.addSubview(self.myTextView)
            self.theSelfPost.addSubview(self.selfNoteCollectionV)

            
        }
    }
    
    func reset(notification:Notification) {
        
        
        theSelfPost.giveMeFreshNewNote()
        myTextView.giveMeFreshNewNoteText()
        self.selfNoteCollectionV.backgroundColor = UIColor(red: 253.0/255.0,green: 237.0/255.0,blue: 166.0/255.0,alpha: 1.0)

//        let noteVC = storyboard?.instantiateViewController(withIdentifier: "SelfNewPostVC")
//        self.present(noteVC!, animated: false, completion: nil)
//        self.dismiss(animated: false, completion: nil)
//
    }
    
    
    // MARK: Perpare segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let dragSegue = segue.destination as! SelfDragVC
 //       newPostSegue.thePost = theSelfPost
        
        let resizeNote = theSelfPost.resizeNote(targetWidth: 300, targetHeight: 300, x: 0, y: 0)
        dragSegue.resizeNote = resizeNote
        
        self.saveNoteData()
        dragSegue.allNoteData = allNoteData
        dragSegue.bgImage = bgImage
        
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
        
        ftColorInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250)
        ftColorInputView.backgroundColor = UIColor.darkGray
        myTextView.inputView = ftColorInputView
        
        let buttonWidth = (ftColorInputView.frame.size.width)/5
        let buttonHeight = (ftColorInputView.frame.size.height)/2
        
        
        let red =
            MyButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Red",
                     tag: 111,
                     bgColor: UIColor.red)
        red.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let green =
            MyButton(frame: CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Green",
                     tag: 112,
                     bgColor: UIColor.green)
        green.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let blue =
            MyButton(frame: CGRect(x: buttonWidth*2, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "blue",
                     tag: 113,
                     bgColor: UIColor.blue)
        blue.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let cyan =
            MyButton(frame: CGRect(x: buttonWidth*3, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Cyan",
                     tag: 114,
                     bgColor: UIColor.cyan)
        cyan.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let yellow =
            MyButton(frame: CGRect(x: buttonWidth*4, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Yellow",
                     tag: 115,
                     bgColor: UIColor.yellow)
        yellow.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let brown =
            MyButton(frame: CGRect(x: 0, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "Brown",
                     tag: 116,
                     bgColor: UIColor.brown)
        brown.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let gray =
            MyButton(frame: CGRect(x: buttonWidth, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "Gray",
                     tag: 117,
                     bgColor: UIColor.gray)
        gray.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let LightGray =
            MyButton(frame: CGRect(x: buttonWidth*2, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "LGray",
                     tag: 118,
                     bgColor: UIColor.lightGray)
        LightGray.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let white =
            MyButton(frame: CGRect(x: buttonWidth*3, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "White",
                     tag: 119,
                     bgColor: UIColor.white)
        white.addTarget(self, action:#selector(changeFcBtn(button:)), for: .touchUpInside)
        let black =
            MyButton(frame: CGRect(x: buttonWidth*4, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "Black",
                     tag: 120,
                     bgColor: UIColor.black)
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
        
        fontSizeInputview.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250)
        fontSizeInputview.backgroundColor = UIColor.lightGray
        myTextView.inputView = fontSizeInputview
        
        let fontSlider = UISlider()
        fontSlider.frame = CGRect(x: 15, y: ((fontSizeInputview.frame.height)/2)-30, width: fontSizeInputview.frame.size.width - 30, height: 30)
        fontSlider.value = Float(fontSizeData)
        fontSlider.maximumValue = 120
        fontSlider.minimumValue = 1
        fontSlider.tintColor = UIColor.black
        fontSlider.thumbTintColor = UIColor.white
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
        BgColorInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250)
        BgColorInputView.backgroundColor = UIColor.darkGray
        myTextView.inputView = BgColorInputView
        
        let buttonWidth = (BgColorInputView.frame.size.width)/5
        let buttonHeight = (BgColorInputView.frame.size.height)/2
        
        
        let red =
            MyButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Red",
                     tag: 101,
                     bgColor: UIColor.red)
        red.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let green =
            MyButton(frame: CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Green",
                     tag: 102,
                     bgColor: UIColor.green)
        green.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let blue =
            MyButton(frame: CGRect(x: buttonWidth*2, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "blue",
                     tag: 103,
                     bgColor: UIColor.blue)
        blue.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let cyan =
            MyButton(frame: CGRect(x: buttonWidth*3, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Cyan",
                     tag: 104,
                     bgColor: UIColor.cyan)
        cyan.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let original =
            MyButton(frame: CGRect(x: buttonWidth*4, y: 0, width: buttonWidth, height: buttonHeight),
                     title: "Original",
                     tag: 105,
                     bgColor: posterColor)
        original.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let brown =
            MyButton(frame: CGRect(x: 0, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "Brown",
                     tag: 106,
                     bgColor: UIColor.brown)
        brown.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let gray =
            MyButton(frame: CGRect(x: buttonWidth, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "Gray",
                     tag: 107,
                     bgColor: UIColor.gray)
        gray.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let LightGray =
            MyButton(frame: CGRect(x: buttonWidth*2, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "LGray",
                     tag: 108,
                     bgColor: UIColor.lightGray)
        LightGray.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let white =
            MyButton(frame: CGRect(x: buttonWidth*3, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "White",
                     tag: 109,
                     bgColor: UIColor.white)
        white.addTarget(self, action:#selector(changeBgBtn(button:)), for: .touchUpInside)
        let black =
            MyButton(frame: CGRect(x: buttonWidth*4, y: buttonHeight, width: buttonWidth, height: buttonHeight),
                     title: "Black",
                     tag: 110,
                     bgColor: UIColor.black)
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
        theSelfPost.changeBgColor(button: button)
        let collectBgcolor = UIColor(cgColor: theSelfPost.shapeLayer.fillColor!)
        selfNoteCollectionV.backgroundColor = collectBgcolor
        
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
        selfNoteCollectionV.reloadData()
        //    myTextView.addImageInText(image: imageX, NoteView: thePost)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: Collectionview delegate method
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageForCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelfNoteImageCell
        
        
        cell.selfNoteImageV.image = imageForCell[indexPath.row]
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
        
        let noteBgColor = selfNoteDataManager.transformColorToData(targetColor: theSelfPost.uploadcolor)
        
        allNoteData = ["selfNoteContent":noteContent ?? "",
                       "selfNoteBgColor":noteBgColor,
                       "selfNoteFontColor":noteFontColor ,
                       "selfNoteFontSize":noteFontSize,
                       "selfNoteImage":noteImage]
    }
    
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}


