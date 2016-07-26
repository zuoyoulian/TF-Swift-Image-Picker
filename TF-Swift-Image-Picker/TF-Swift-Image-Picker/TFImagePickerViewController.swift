//
//  TFImagePickerViewController.swift
//  TF-Swift-Image-Picker
//
//  Created by 左建军 on 16/7/2.
//  Copyright © 2016年 lanou. All rights reserved.
//

import UIKit
import AssetsLibrary


typealias SelectFinish = (NSDictionary) -> ()

class TFImagePickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var maxNumOfSelection : NSInteger!
    var currentNumOfSelection = 0
    var imagesArray = NSMutableArray()
    var indexArray = NSMutableArray()
    
    var options : NSDictionary?
    var collectionView : UICollectionView!
    var numOfSelectLabel : UILabel!
    var finishButton : UIButton!
    
    var selectFinish : SelectFinish!
    
    var assetsLibrary : ALAssetsLibrary!
    
    //  析构造函数
    deinit {
        // 注销消息中心
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImagePickerSelectFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImagePickerSelectMaxNumNotification, object: self)
    }
    
    
    //  获取照片的方法
    func getImageFromLibrary() -> Void {
        // 获取相册访问权限的状态值
        let authorizationStatus = ALAssetsLibrary.authorizationStatus()
        // 没有访问照片的权限
        if authorizationStatus == ALAuthorizationStatus.Restricted || authorizationStatus == ALAuthorizationStatus.Denied  {
            self.selectFinish(["dednied" : true]);
            return;
        }
        
        // 创建资源库对象
        self.assetsLibrary = ALAssetsLibrary();
        self.assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { (group, stop) in
            // 获取所有照片
            if group == nil {
                return
            }
            group.setAssetsFilter(ALAssetsFilter.allPhotos())
            
            group.enumerateAssetsUsingBlock({ (result, index, stop) in
                // 获取到结果
                if (result != nil) {
                    // 缩略图存在
                    if result.thumbnail() != nil {
                        let dic = NSMutableDictionary()
                        dic.setObject("0", forKey: "flag")
                        dic.setObject(result, forKey: "result")
                        self.imagesArray.addObject(dic)
                    }
                    
                    // 获取到最后一张图片
                    if index + 1 == group.numberOfAssets() {
                        // 刷新UI
                        dispatch_async(dispatch_get_main_queue(), {
                            // 刷新
                            self.collectionView.reloadData();
                            // 滚到最后
                            let indexPath = NSIndexPath(forRow: index, inSection : 0);
                            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition:UICollectionViewScrollPosition.None, animated: false)
                        })
                    }
                } else {
                    if self.imagesArray.count > 0 {
                        return;
                    }
                    // 相册中没有图片
                    self.showAlertViewWithMessage("您的照片库中没有照片")
                }
            })
            
            }) { (error) in
                // 将错误信息返回
                
        }
    }
    
//  创建子视图
    //  创建导航栏视图
    func creatNavigationBarView()  {
        // 背景视图
        let navigationBarView = UIView(frame : CGRectMake(0, 0, CGFloat(ScreenWidth), CGFloat(NavigationBarHeight + StateBarHeight)))
        
        // 标题栏
        let titleLabel = UILabel()
        titleLabel.center = CGPointMake(CGFloat(navigationBarView.center.x), CGFloat(navigationBarView.center.y + CGFloat(StateBarHeight/2)))
        titleLabel.bounds = CGRectMake(0, 0, 200, 40);
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.systemFontOfSize(CGFloat(20))
        titleLabel.text = "相册"
        navigationBarView.addSubview(titleLabel)
        
        // 取消按钮
        let cancelButton = UIButton(type : UIButtonType.RoundedRect)
        cancelButton.frame = CGRectMake(ScreenWidth - 50, titleLabel.center.y - 15, 40, 30);
        cancelButton.setTitle("取消", forState: UIControlState.Normal)
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(CGFloat(17))
        cancelButton.addTarget(self, action: #selector(self.cancelAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        navigationBarView.addSubview(cancelButton);
        
        // 设置视图默认值
        navigationBarView.backgroundColor = UIColor.blackColor()
        navigationBarView.alpha = 0.8
        titleLabel.textColor = UIColor.whiteColor()
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        // 通过参数修改视图设置
        let listNavigationBarOptions = self.options?.objectForKey("listNavigationBarOptions")
        if listNavigationBarOptions != nil && (listNavigationBarOptions?.isKindOfClass(NSDictionary))!  {
            // 设置背景颜色
            if ((listNavigationBarOptions?.objectForKey("backgroundColor")) != nil) {
                navigationBarView.backgroundColor = listNavigationBarOptions?.objectForKey("backgroundColor") as? UIColor
            }
            // 设置透明度
            if (listNavigationBarOptions?.objectForKey("alpha")) != nil {
                let alpha = listNavigationBarOptions?.objectForKey("alpha") as! NSNumber
                navigationBarView.alpha = CGFloat(alpha.floatValue)
            }
            // 修改button和标题字体颜色
            if ((listNavigationBarOptions?.objectForKey("titleColor")) != nil) {
                titleLabel.textColor = listNavigationBarOptions?.objectForKey("titleColor") as? UIColor
               cancelButton.setTitleColor(listNavigationBarOptions?.objectForKey("titleColor") as? UIColor, forState: UIControlState.Normal)
            }
        }
        
        self.view.addSubview(navigationBarView);
    }
    
    //  创建缩略图列表视图
    func creatImageListView() {
        // 创建flowlayout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemSize = CGSizeMake(ScreenWidth/4-6, ScreenWidth/4)
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        layout.sectionInset = UIEdgeInsetsMake(2, 5, 0, 5)
        
        // 创建视图对象
        self.collectionView = UICollectionView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight - TabBarHeight), collectionViewLayout : layout)
        self.collectionView.contentInset = UIEdgeInsetsMake(NavigationBarHeight, 0, 0, 0)
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // 注册cell
        self.collectionView.registerClass(TFImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: "ImagePickerCollectionViewCell")
        
        self.view.addSubview(self.collectionView)
    }
    
    //  创建底部完成状态栏视图
    func creatFinishBarView() {
        // 状态栏背景视图
        let finishView = UIView(frame : CGRectMake(0, ScreenHeight - TabBarHeight, ScreenWidth, TabBarHeight))
        
        // 显示选择个数的label
        self.numOfSelectLabel = UILabel(frame : CGRectMake(finishView.bounds.size.width - 80, (TabBarHeight - 20)/2, 20, 20))
        self.numOfSelectLabel.hidden = true  // 初始化时没有选中任何照片，隐藏
        self.numOfSelectLabel.textAlignment = NSTextAlignment.Center;
        self.numOfSelectLabel.layer.masksToBounds = true;
        self.numOfSelectLabel.layer.cornerRadius = 10;
        finishView.addSubview(self.numOfSelectLabel)
        
        // 完成按钮
        self.finishButton = UIButton(type : UIButtonType.RoundedRect)
        finishButton.frame = CGRectMake(finishView.bounds.size.width - 60, (TabBarHeight - 40)/2, 50, 40)
        self.finishButton.setTitle("完成", forState: UIControlState.Normal)
        self.finishButton.addTarget(self, action:#selector(self.finishAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.finishButton.enabled = false
        self.finishButton.alpha = 0.5
        finishView.addSubview(self.finishButton)
        
        
        // 默认状态设置
        finishView.backgroundColor = UIColor.lightGrayColor()
        self.numOfSelectLabel.textColor = UIColor.whiteColor()
        self.numOfSelectLabel.backgroundColor = UIColor.greenColor()
        self.finishButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        
        // 通过参数修改设置
        
        
        self.view.addSubview(finishView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
        self.maxNumOfSelection = self.options?.objectForKey("maxNumOfSelect")?.integerValue
        
        self.creatImageListView()
        self.creatNavigationBarView()
        self.creatFinishBarView()
        
        self.getImageFromLibrary()
        
        // 注册消息
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.selectFinish(_:)), name: ImagePickerSelectFinishNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.selectMaxNum(_:)), name: ImagePickerSelectMaxNumNotification, object: nil)
    }
    
//  显示提示框的方法
    func showAlertViewWithMessage(message : String) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title : nil,
                                          message : message,
                                          preferredStyle : UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
            
        }
    }
    
//  选到最大个数消息方法
    func selectMaxNum(notification : NSNotification) {
        self.showAlertViewWithMessage("您最多只能选择\(self.maxNumOfSelection)张照片")
    }
//  选择消息方法
    func selectFinish(notification : NSNotification) {
        let userInfo : NSDictionary = notification.userInfo!
        // 表示选中照片
        if ((userInfo.objectForKey("flag")?.boolValue) == true) {
            // 选中的个数＋1
            self.currentNumOfSelection += 1
            // 将选中的位置添加到位置数组中
            self.indexArray.addObject(userInfo.objectForKey("index")!)
        } else {  // 表示取消选中
            // 选中个数－1
            self.currentNumOfSelection -= 1
            // 将位置从数组中移除
            self.indexArray.removeObject(userInfo.objectForKey("index")!)
        }
        
        // 修改视图的状态
        self.finishButton.enabled = self.currentNumOfSelection > 0 ? true : false
        self.finishButton.alpha = self.currentNumOfSelection > 0 ? 1 : 0.5
        self.numOfSelectLabel.text = "\(self.currentNumOfSelection)"
        self.numOfSelectLabel.hidden = self.currentNumOfSelection > 0 ? false : true
    }
    
//  按钮方法
    //  取消按钮的方法
    func cancelAction(button : UIButton)  {
        self.selectFinish(["didCancel" : true])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 完成按钮方法
    func finishAction(button : UIButton?) {
        let results = NSMutableArray(capacity : 0)
        
        for index in self.indexArray {
            // 获取图片信息
            let content : NSDictionary = self.imagesArray.objectAtIndex(index.integerValue) as! NSDictionary
            let response = NSMutableDictionary()
            let assertRepresentation = (content.objectForKey("result") as! ALAsset).defaultRepresentation()
            var img = UIImage(CGImage : (assertRepresentation.fullScreenImage().takeUnretainedValue()))
            
            // 压缩图片信息
            var maxWidth = img.size.width
            var maxHeight = img.size.height
            if self.options != nil && (self.options!.valueForKey("maxWidth") != nil) {
                maxWidth = self.options!.valueForKey("maxWidth") as! CGFloat
            }
            if self.options != nil && (self.options!.valueForKey("maxHeight") != nil) {
                maxHeight = self.options!.valueForKey("maxHeight") as! CGFloat
            }
            // 按最大宽高来压缩
            img = self.downscaleImageIfNecessary(img, maxWidth: maxWidth, maxHeight: maxHeight)
            // 按像素率压缩
            let data : NSData
            if self.options != nil {
                data = UIImageJPEGRepresentation(img, CGFloat((self.options?.valueForKey("quality")?.floatValue)!))!
            } else {
                data = UIImageJPEGRepresentation(img, 1)!
            }
            
            // 将图片保存到沙盒中
            let path = self.saveImageAtPathWithName((assertRepresentation?.filename)!())
            if path == "" {
                return
            }
            data.writeToFile(path as String, atomically: true)
            let fileURL = NSURL.fileURLWithPath(path)
            
            // 封装返回数据
//            response.setObject(fileURL.absoluteString, forKey: "uri")
            response.setObject(fileURL, forKey: "uri")
            response.setObject(img.size.width, forKey: "width")
            response.setObject(img.size.height, forKey: "height")
            
            // 获取文件大小
            var fileSizeValue : AnyObject?
            do {
                try fileURL.getResourceValue(&fileSizeValue, forKey: NSURLFileSizeKey)
                  response.setObject(fileSizeValue!, forKey: "fileSize")
            } catch {
                
            }
            
            let storageOptions = self.options!.objectForKey("storageOptions")
            if storageOptions != nil && (storageOptions?.isKindOfClass(NSDictionary))! {
                if ((storageOptions!["skipBackup"]) as! NSNumber).boolValue  {
                    // 跳过备份到icloud itunes
                    self.addSkipBackupAttributeToItemAtPath(path)
                }
            }
            
            results.addObject(response)
        }
        // 选择完成，将数据返回
        self.selectFinish(["numOfSelect" : self.currentNumOfSelection, "results" : results])
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
    
    
//  跳过备份方法
    func addSkipBackupAttributeToItemAtPath(filePathString : String) -> Bool {
        let URL = NSURL.fileURLWithPath(filePathString)
        if (NSFileManager.defaultManager()).fileExistsAtPath(URL.path!) {
            do {
                try URL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
                return true
            } catch {
                return false
            }
            
        } else {
            return false
        }
    }
    
    
//  图片路径
    func saveImageAtPathWithName(fileName : String) -> String {
        var path : String!
        
        let storageOptions = self.options!.objectForKey("storageOptions")
        if storageOptions != nil && (storageOptions?.isKindOfClass(NSDictionary))! {
            // 获取cache
            let cache = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray).lastObject
            path = cache?.stringByAppendingString(fileName)
            if storageOptions!["path"] != nil {
                let newPath = cache?.stringByAppendingPathComponent(storageOptions!["path"] as! String)
                if !(NSFileManager.defaultManager().fileExistsAtPath(newPath!)) {
                    do {
                        try NSFileManager.defaultManager().createDirectoryAtPath(newPath!, withIntermediateDirectories: true, attributes: nil)
                    } catch _{
                        return ""
                    }
                }
                path = (newPath! as NSString).stringByAppendingPathComponent(fileName)
            }
        } else {
            path = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(fileName)
        }
        
        return path;
    }
    
    
//  压缩图片的方法
    func downscaleImageIfNecessary(image : UIImage, maxWidth : CGFloat, maxHeight : CGFloat) -> UIImage {
        var newImage = image;
        
        if image.size.height <= maxHeight && image.size.width <= maxWidth {
            return newImage
        }
        
        var scaledSize = CGSizeMake(image.size.width, image.size.height)
        if maxWidth < scaledSize.width {
            scaledSize = CGSizeMake(maxWidth, (maxWidth / scaledSize.width) * scaledSize.height);
        }
        if (maxHeight < scaledSize.height) {
            scaledSize = CGSizeMake((maxHeight / scaledSize.height) * scaledSize.width, maxHeight);
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }

    
//  UICollectionView协议方法
    // 返回多少个item
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesArray.count
    }
    // 返回cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImagePickerCollectionViewCell", forIndexPath: indexPath) as! TFImagePickerCollectionViewCell
        cell.creatSubviewsWithDic(self.imagesArray[indexPath.row] as! NSDictionary)
        cell.imagePickerVC = self
        return cell
    }
    // 点击cell的方法
    func collectionView(collectionView: UICollectionView,
                          didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let bigImageVC = TFBigImageViewControllr()
        bigImageVC.imagePickerVC = self
        bigImageVC.currentPageIndex = indexPath.row
        bigImageVC.allPhotos = self.imagesArray
        
        bigImageVC.selectImg = { (currentIndex : NSInteger) in
            collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow : currentIndex as Int, inSection : 0)])
        };
        
        self.navigationController?.pushViewController(bigImageVC, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


class TFImagePickerCollectionViewCell: UICollectionViewCell {
    
    var imagePickerVC : TFImagePickerViewController?
    
    var contentDic : NSDictionary?
    
    var imgView : UIImageView?
    var selButton : UIButton?
    
    //  创建cell子视图
    internal func creatSubviewsWithDic(contentDic : NSDictionary) {
        self.contentDic = contentDic
        
        // 创建imageView
        if self.imgView == nil {
            self.imgView = UIImageView(frame: self.contentView.bounds)
            self.contentView.addSubview(self.imgView!)
        }
        // 获取缩略图，给imageView赋值
        let result = contentDic.objectForKey("result") as! ALAsset
        
        self.imgView!.image = UIImage(CGImage : result.thumbnail().takeUnretainedValue())
        
        // 创建button
        if self.selButton == nil {
            self.selButton = UIButton(type : UIButtonType.RoundedRect)
            self.selButton?.frame = CGRectMake(self.contentView.frame.size.width - 30, 0, 30, 30);
            self.selButton?.addTarget(self, action: #selector(self.setSelectFlag(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.contentView.addSubview(self.selButton!)
        }
        // cell复用，修改按钮图标
        self.changeButtonImg()
    }
    
    // 选择按钮的方法
    func setSelectFlag(button : UIButton) {
        var flag : Bool;
        
        // 照片未被选择，点击后修改成选中状态
        if (self.contentDic?.objectForKey("flag"))?.integerValue == 0 {
            // 如果选中的个数大于等于最大选择个数，照片不能再被选中
            if self.imagePickerVC?.currentNumOfSelection >= self.imagePickerVC?.maxNumOfSelection {
                // 发送选择最大个数消息
                NSNotificationCenter.defaultCenter().postNotificationName(ImagePickerSelectMaxNumNotification, object: nil)
                return
            }
            self.contentDic!.setValue("1", forKey: "flag")
            flag = true
        } else {
            self.contentDic?.setValue("0", forKey: "flag")
            flag = false
        }
        
        // 修改选择按钮的状态
        self.changeButtonImg()
        
        // 发送照片做选择的通知，通知带有两个参数：flag是否被选中，index被选照片的位置
        let index = self.imagePickerVC?.collectionView.indexPathForCell(self)
        NSNotificationCenter.defaultCenter().postNotificationName(ImagePickerSelectFinishNotification, object: nil, userInfo: ["flag" : flag, "index" : (index?.row)!])
    }
    
    // 修改选择按钮
    func changeButtonImg() {
        let rnBundle = NSBundle(path : NSBundle.mainBundle().pathForResource("RNImage", ofType: "bundle")!)
        // 未选中，改成选中
        if (self.contentDic?.objectForKey("flag"))?.integerValue == 0 {
            let unselectPath = rnBundle?.pathForResource("image_unselect", ofType: "png", inDirectory : "images")
            self.selButton?.setBackgroundImage(UIImage(contentsOfFile : unselectPath!), forState: UIControlState.Normal)
        } else {
            let selectPath = rnBundle?.pathForResource("image_select", ofType: "png", inDirectory : "images")
            self.selButton?.setBackgroundImage(UIImage(contentsOfFile : selectPath!), forState: UIControlState.Normal)
        }
    }
}






