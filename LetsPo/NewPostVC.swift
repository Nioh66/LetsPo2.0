//
//  NewPostVC.swift
//  LetsPo
//
//  Created by Pin Liao on 2017/7/18.
//  Copyright © 2017年 Walker. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class NewPostVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate ,UICollectionViewDelegate ,UICollectionViewDataSource ,LocationManagerDelegate{
    private var collectionViewLayout : PostsLinearFlowLayout!
//    private var dataSource: Array<Int>!
    private var pageWidth : CGFloat{
        return  self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    
    private var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }
    var animationsCount = 0
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
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
    
    let locationManager = LocationManager()
    var boardLat = Double()
    var boardLon = Double()

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
        
        //self.configureDataSource()
        self.configureCollectionView()
        self.configurePageControl()

        locationManager.delegate = self
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        //let documnetPath = documentPaths[0] as! String
        print(documentPaths)
        
       
        myTextView.frame = CGRect(x: 0, y: 0, width: thePost.frame.size.width, height: thePost.frame.size.height*0.8)
        thePost.clipsToBounds = true
       
        DispatchQueue.main.async {
        self.thePost.addSubview(self.myTextView)
  
               }
        
        //        myTextView.setNeedsDisplay()
        //        myScrollView.addSubview(myTextView)
       
        
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
        super.viewWillAppear(animated)

        locationManager.startUpdate()
        
        myTextView.isEditable = true

        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.topItem?.title = "定位便貼"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdate()
    }
    
    func reset(notification:Notification) {
       
        
        thePost.giveMeFreshNewNote()
        myTextView.giveMeFreshNewNoteText()
        imageForCell.removeAll()
        self.collectionView.reloadData()

    }

    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let newPostSegue = segue.destination as! BoardSettingVC
        newPostSegue.thePost = thePost
        
        
        
        //這個uiview are who?
        UIView.animate(withDuration: 0.1) {
           self.myTextView.isEditable = false
            
           self.myTextView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            let resizeNote = self.thePost.resizeNote(targetWidth: 300, targetHeight: 300, x: 0, y: 0, textView: self.myTextView)
            newPostSegue.resizeNote = resizeNote
            
        }
        
        
        
        self.saveNoteData()
        newPostSegue.allNoteData = allNoteData
        newPostSegue.boardLat = boardLat
        newPostSegue.boardLon = boardLon
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
        collectionView.reloadData()
    //    myTextView.addImageInText(image: imageX, NoteView: thePost)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: Collectionview delegate method ----------------
    
    
    
    
    func configureCollectionView() {
        self.collectionView.register(UINib.init(nibName: "AllPostsImageCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.collectionViewLayout = PostsLinearFlowLayout.configureLayout(collectionView: self.collectionView, itemSize: CGSize.init(width: 180, height: 180), minimumLineSpacing: 0)
    }
    
//    func configureDataSource ()  {
//        self.dataSource = [Int]()
//        for i in 0..<imageForCell.count{
//            self.dataSource.append(i)
//        }
//    }
    
    func configurePageControl() {
        self.pageControl.numberOfPages = imageForCell.count
    }
    
    private func scrollToPage(page: Int, animated: Bool) {
        self.collectionView.isUserInteractionEnabled = false
        self.animationsCount += 1
        let pageOffset = CGFloat(page) * self.pageWidth - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPoint(x: pageOffset, y: 0), animated: true)
        self.pageControl.currentPage = page
        //        self.configureButtons()
    }
    // MARK: collectionView datasource method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageForCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AllPostsImageCell
        cell.postImageV.layer.cornerRadius = 10.0
        cell.postImageV.layer.masksToBounds = true
        cell.postImageV.image = imageForCell[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking {
            return
        }
        
        let selectedPage = indexPath.row;
        
        if selectedPage == self.pageControl.currentPage {
            //可加popview
            NSLog("Did select center item")
        }
        else {
            
            //          self.scrollToPage(page: selectedPage, animated: true)
        }
        
    }
    
    // MARK: collectionView delegate method
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if ((self.animationsCount - 1) == 0) {
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(self.contentOffset / self.pageWidth)
        //       self.configurebtn
        
    }


    
    
    //----------------
    
       // MARK : Location method
   
    func locationManager(updatedUserLocation coordinate: CLLocation) {
        print("1111")
        let boardPosition = coordinate
        boardLat = boardPosition.coordinate.latitude
        boardLon = boardPosition.coordinate.longitude
        print("Lat:\(boardLat)Lon:\(boardLon)")
    }
    func locationManager(userDidExitRegion region: CLRegion) {
        print("Exit \(region.identifier)")
        
    }
    
    func locationManager(userDidEnterRegion region: CLRegion) {
        print("Enter \(region.identifier)")
        
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

    
