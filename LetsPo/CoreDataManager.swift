//
//  CoreDataManager.swift
//  PLCoreDataManager
//
//  Created by Pin Liao on 2017/7/14.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
import CoreData


class CoreDataManager<ItemType>: NSObject ,NSFetchedResultsControllerDelegate{
    
    var targetModelName:String
    var targetDBfilename:String
    var targetDBPathURL:URL?
    var targetSortKey:String
    var targetEntityName:String
    var saveCompletion:SaveCompletion?
    
    init(initWithModel modelName:String,
         dbFileName:String,
         dbPathURL:URL?,
         sortKey:String,
         entityName:String){
        
        //        super.init()
        //Keep parameters as variables
        targetModelName = modelName
        targetDBfilename = dbFileName
        targetDBPathURL = dbPathURL
        targetSortKey = sortKey
        targetEntityName = entityName
        
        //Use Document as default place to store db file
        if(dbPathURL == nil){
            targetDBPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
    
    
    
    
    func createItem() -> ItemType {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: targetEntityName, into: self.managedObjectContext) as! ItemType
        
        return newItem
    }
    
    func deleteItem(item:NSManagedObject) {
        self.managedObjectContext.delete(item)
    }
    
    
    func itemWithIndex(index:NSInteger) -> ItemType {
        let indexPath = IndexPath(row: index, section: 0)
        
        return self.fetchedResultsController.object(at: indexPath) as! ItemType
        
        
    }
    
    
    func searchField(field:String,forKeyword keyword:String) -> [NSFetchRequestResult]{
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: targetEntityName)
        let format = String(format: "%@ contains[cd] %%@", field)
        let predicate = NSPredicate(format: format, keyword)
        request.predicate = predicate
        var result = [NSFetchRequestResult]()
        do {
            result = try self.managedObjectContext.fetch(request)
        } catch  {
            print("erro")
        }
        return result
    }
    
    // "%@ contains[cd] %%@" ％％＠ 將％％合成％ contains[cd]不區分大小寫
    
    func count() -> Int{
        let sectionInfo = self.fetchedResultsController.sections![0] //一維先由section改為0
        return sectionInfo.numberOfObjects
        
    }
    
    
    
    
    
    //Mark - Core Data stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        //xcddata是原始碼 XCode Compile後會變momd
        let modelURL = Bundle.main.url(forResource: self.targetModelName, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let storeURL = self.targetDBPathURL?.appendingPathComponent(self.targetDBfilename)
        
        //Error setting
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    typealias SaveCompletion = (_ success: Bool) -> ()
    
    func saveContexWithCompletion(completion: @escaping SaveCompletion) {
        
        
        saveCompletion = completion
        print("Start to save!!!")
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                print("save end ")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                print("Save failure!!!!!")
                abort()
            }
        }else{
            completion(true)
            saveCompletion = nil
        }
        
    }//method
    
    // MARK: - Fetched results controller
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: targetEntityName, in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.批次輸量
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: targetSortKey, ascending: false)//ascending決定排序方向A->Z
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: targetEntityName)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController as NSFetchedResultsController<NSFetchRequestResult>
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    
    
    
    
    //掌握存檔完成時間點 使用它時存擋已完成
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // In the simplest, most efficient, case, reload the table view.
        if let completion = saveCompletion{
            completion(true)
            saveCompletion = nil
        }
        //        if saveCompletion != nil {
        //            saveCompletion!(true)
        //            saveCompletion = nil
        //        }
        
    }
}



// Transform UIImage to NSData and store in Json
extension CoreDataManager{
    
    func transformImageTOJson(images:[UIImage]) -> NSData?{
        
        var imageWithPath = [String:Any]()
        //        var jsonContent:String = ""
        
        for (index,image) in images.enumerated(){
            let hashFileName = String(format: "image_%d.jpg", image.hash)
            guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first  else{
                print("Transform failure!!!!!!")
                return nil
            }
            let finalPath = documentURL.appendingPathComponent(hashFileName)
            if !FileManager.default.fileExists(atPath: finalPath.path){
                guard let imageData = UIImageJPEGRepresentation(image, 1.0) as NSData? else{
                    print("Image transform failure!!!!!!")
                    return nil
                }
                imageData.write(to: finalPath, atomically: true)
                
                imageWithPath.updateValue("\(hashFileName)", forKey: "Image\(index)")
                
                //               jsonContent += "image\(index):\(hashFileName),"
                
            }else{
                imageWithPath.updateValue("\(hashFileName)", forKey: "Image\(index)")
                print("File already exist!")
            }
        }
        print("asdmkasdkmlasmdalm\(imageWithPath)")
        
        guard let imageJSONData = try? JSONSerialization.data(withJSONObject: imageWithPath, options: .prettyPrinted) as NSData else{
            print("Json transform failure!!!")
            return nil
        }
        //        Fake JSON
        //        jsonContent = jsonContent.substring(to: jsonContent.index(before: jsonContent.endIndex))
        //        let jsonBegin = "{"
        //        let jsonEnd = "}"
        //        let finalJson = jsonContent
        
        return imageJSONData
    }
    
    
    
    func transformDataToImage(imageJSONData: NSData) -> [UIImage]? {
        
        var album = [UIImage]()
        //Transform data to JSON dictionary
        guard let json = try? JSONSerialization.jsonObject(with: imageJSONData as Data),
            let myAlbum = json as? [String: Any] else{
                print("imageJSONData transform to result failure!!!!!")
                return nil
        }
        print("--\(json)--")
        print(myAlbum)
        //Get URL
        for index in 0 ..< myAlbum.count {
            guard let stringPath = myAlbum["Image\(index)"] as? String
                else {
                    print("------String transform to URL failure------")
                    return nil
            }
            print("-------\(stringPath)------")
            
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            if let dirPath = paths.first{
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(stringPath)
                let image    = UIImage(contentsOfFile: imageURL.path)
                album.append(image!)
                // Do whatever you want with the image
            }
            //..
            
        }
        return album
    }
    
    
    func reverseColorDataToColor(data: NSData) -> UIColor {
        
        // Transform NSData to UIColor
        var components = [CGFloat](repeating:0, count: 4)
        let length = MemoryLayout.size(ofValue: components)
        
        data.getBytes(&components, length: length * components.count)
        let color = UIColor(red: components[0],
                            green: components[1],
                            blue: components[2],
                            alpha: components[3])
        print("reverse-----\(color)")
        return color
    }
    
    
    
    func transformColorToData(targetColor:UIColor) -> NSData {
        
        let color = targetColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let components:[CGFloat] = [red, green, blue, alpha]
        
        let colorData = NSData(bytes: components,
                               length: MemoryLayout.size(ofValue: components)*components.count)
        return colorData
    }
    
    
    
}



//for index in 0 ..< myAlbum.count {
//    guard let stringPath = myAlbum["Image\(index)"] as? String,
//        let finalPath = URL(string: stringPath)?.path else {
//            print("------String transform to URL failure------")
//            return nil
//    }
//    print("-------\(stringPath)------")
//
//    print("===========\(finalPath)=========")
//
//    //..
//    guard let img = UIImage(contentsOfFile: finalPath)
//        else{
//            print("===========Data turn image failure=========")
//            
//            return nil
//    }
//    
//    album.append(img)
//}
//return album
//}
