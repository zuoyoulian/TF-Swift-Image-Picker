//
//  TFBigImageViewControllr.swift
//  TF-Swift-Image-Picker
//
//  Created by 左建军 on 16/7/4.
//  Copyright © 2016年 lanou. All rights reserved.
//

import UIKit
import AssetsLibrary


// 在大图页选择的信息回调给列表页
typealias SelectImg = (NSInteger) -> ()

class TFBigImageViewControllr: UIViewController, UIScrollViewDelegate {
    
    var imagePickerVC : TFImagePickerViewController!
    
    var currentPageIndex : NSInteger!
    var allPhotos : NSArray!
    
    var selectImg : SelectImg!
    
    var scrollView : UIScrollView!
    var contentViews : NSMutableArray!
    var selButton : UIButton?
    var numOfSelectLabel : UILabel?
    var finishButton : UIButton?
    var options : NSDictionary?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // 创建上导航栏
    func creatNavigationBarView() {
        let navigationBarView = UIView(frame: CGRectMake(0, 0, ScreenWidth, NavigationBarHeight + StateBarHeight))
        navigationBarView.tag = 4001
        navigationBarView.backgroundColor = UIColor.blackColor();
        navigationBarView.alpha = 0.5;
        // 通过参数修改设置
        let bigNavigationBarOptions = self.options!["bigNavigationBarOptions"]
        if bigNavigationBarOptions != nil && (bigNavigationBarOptions?.isKindOfClass(NSDictionary))! {
            // 修改背景颜色
            if bigNavigationBarOptions!["backgroundColor"] != nil {
               navigationBarView.backgroundColor = bigNavigationBarOptions!["backgroundColor"] as? UIColor
            }
            // 修改透明度
            if bigNavigationBarOptions!["alpha"] != nil {
                let alpha = bigNavigationBarOptions!["alpha"] as! NSNumber
                navigationBarView.alpha = CGFloat(alpha.floatValue)
            }
        }
        
        // 返回按钮
        let backButton = UIButton(type: UIButtonType.RoundedRect)
        backButton.bounds = CGRectMake(0, 0, 40, 40)
        backButton.center = CGPointMake(30, navigationBarView.center.y)
        let rnBundle = NSBundle(path : NSBundle.mainBundle().pathForResource("RNImage", ofType: "bundle")!)
        let backPath = rnBundle?.pathForResource("image_back", ofType: "png", inDirectory : "images")
        backButton.setBackgroundImage(UIImage(contentsOfFile : backPath!), forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(self.backAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        navigationBarView.addSubview(backButton)
        
        // 选择按钮
        self.selButton = UIButton(type : UIButtonType.RoundedRect)
        self.selButton!.bounds = CGRectMake(0, 0, 40, 40)
        self.selButton!.center = CGPointMake(ScreenWidth - self.selButton!.bounds.size.width/2 - 10, navigationBarView.center.y)
        self.selButton?.addTarget(self, action: #selector(self.setSelectFlag(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        navigationBarView.addSubview(self.selButton!)
        
        self.view.addSubview(navigationBarView)
    }
    // 创建完成状态栏
    func creatFinishBarView() {
        // 下导航背景视图
        let finishView = UIView(frame: CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49))
        finishView.tag = 4002
        
        // 显示选择个数的label
        self.numOfSelectLabel = UILabel(frame: CGRectMake(finishView.bounds.size.width - 80, (49 - 20)/2, 20, 20))
        self.numOfSelectLabel!.text = "\(self.imagePickerVC.currentNumOfSelection)"
        self.numOfSelectLabel!.hidden = self.imagePickerVC.currentNumOfSelection > 0 ? false : true
        self.numOfSelectLabel!.textAlignment = NSTextAlignment.Center
        self.numOfSelectLabel!.layer.masksToBounds = true
        self.numOfSelectLabel!.layer.cornerRadius = 10
        finishView.addSubview(self.numOfSelectLabel!)
        
        // 完成按钮
        self.finishButton = UIButton(type: UIButtonType.RoundedRect)
        self.finishButton!.frame = CGRectMake(finishView.bounds.size.width - 60, (49 - 40)/2, 50, 40)
        self.finishButton!.setTitle("完成", forState: UIControlState.Normal)
        // 完成按钮的初始状态赋值
        if (self.imagePickerVC.currentNumOfSelection == 0) {
            self.finishButton!.enabled = false
            self.finishButton!.alpha = 0.5
        }
        finishView.addSubview(self.finishButton!)
        
        // 设置默认值
        finishView.backgroundColor = UIColor.blackColor()
        finishView.alpha = 0.5
        self.numOfSelectLabel!.textColor = UIColor.whiteColor()
        self.numOfSelectLabel!.backgroundColor = UIColor.greenColor()
        self.finishButton?.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        // 通过参数修改设置
        let bigFinishBarOptions = self.options!["bigFinishBarOptions"]
        if bigFinishBarOptions != nil && (bigFinishBarOptions?.isKindOfClass(NSDictionary))! {
            // 修改背景色
            if bigFinishBarOptions!["backgroundColor"] != nil {
                finishView.backgroundColor = bigFinishBarOptions!["backgroundColor"] as? UIColor
            }
            // 修改透明度
            if bigFinishBarOptions!["alpha"] != nil {
                finishView.alpha = CGFloat((bigFinishBarOptions!["alpha"] as! NSNumber).floatValue)
            }
            // 修改label字体颜色
            if bigFinishBarOptions!["titleColor"] != nil {
                self.numOfSelectLabel!.textColor = bigFinishBarOptions!["titleColor"] as? UIColor
            }
            // 修改按钮title颜色 和 label背景颜色
            if bigFinishBarOptions!["tintColor"] != nil {
                self.finishButton?.setTitleColor(bigFinishBarOptions!["tintColor"] as? UIColor, forState: UIControlState.Normal)
                self.numOfSelectLabel!.backgroundColor = bigFinishBarOptions!["tintColor"] as? UIColor;
            }
        }
        self.view.addSubview(finishView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBarHidden = true
        
        self.options = self.imagePickerVC.options
        
        // 创建最下面的滚动视图
        self.scrollView = UIScrollView(frame : UIScreen.mainScreen().bounds)
        self.scrollView.contentSize = CGSizeMake(3 * ScreenWidth, ScreenHeight)
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(ScreenWidth, 0)
        self.scrollView.pagingEnabled = true
        self.scrollView.bounces = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        
        self.creatNavigationBarView()
        self.creatFinishBarView()
        
        // 设置滚动视图数据，创建内容
        self.setScrollViewContentDataSource()
        self.configContentViews()
    }
    
//  按钮方法
    // 返回按钮
    func backAction(button : UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // 完成按钮
    func finishAction(button : UIButton) {
        self.imagePickerVC.finishAction(nil)
    }
    // 选择按钮
    func setSelectFlag(button : UIButton) {
        var flag : Bool
        let photoDic = self.allPhotos[self.currentPageIndex] as! NSDictionary
        if photoDic["flag"]?.intValue == 0 {
            if self.imagePickerVC.currentNumOfSelection >= self.imagePickerVC.maxNumOfSelection {
                self.selectMaxNum()
                return
            }
            photoDic.setValue("1", forKey: "flag")
            flag = true
        } else {
            photoDic.setValue("0", forKey: "flag")
            flag = false
        }
        
        // 回调让当前选择的位置对应的cell刷新
        self.selectImg(self.currentPageIndex)
        
        // 发送照片做选择的通知，通知带有两个参数：flag是否被选中，index被选照片的位置
        NSNotificationCenter.defaultCenter().postNotificationName(ImagePickerSelectFinishNotification, object: nil, userInfo: ["flag" : flag, "index" : self.currentPageIndex])
        
        self.changeState()
    }
    
    // 选择到最大个数时弹出提示框
    func selectMaxNum() {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title : nil,
                                          message : "您最多只能选择\(self.imagePickerVC.maxNumOfSelection)张照片",
                                          preferredStyle : UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
            
        }
    }
    
    // 修改视图显示状态
    func changeState() {
        let photoDic = self.allPhotos[self.currentPageIndex] as! NSDictionary
        
        let rnBundle = NSBundle(path : NSBundle.mainBundle().pathForResource("RNImage", ofType: "bundle")!)
        if photoDic["flag"]?.integerValue == 0 {
            let unselectPath = rnBundle?.pathForResource("image_unselect", ofType: "png", inDirectory : "images")
            self.selButton?.setBackgroundImage(UIImage(contentsOfFile : unselectPath!), forState: UIControlState.Normal)
        } else {
            let selectPath = rnBundle?.pathForResource("image_select", ofType: "png", inDirectory : "images")
            self.selButton?.setBackgroundImage(UIImage(contentsOfFile : selectPath!), forState: UIControlState.Normal)
        }
        
        self.finishButton!.enabled = self.imagePickerVC.currentNumOfSelection > 0 ? true : false
        self.finishButton!.alpha = self.imagePickerVC.currentNumOfSelection > 0 ? 1 : 0.5
        self.numOfSelectLabel!.text = "\(self.imagePickerVC.currentNumOfSelection)"
        self.numOfSelectLabel!.hidden = self.imagePickerVC.currentNumOfSelection > 0 ? false : true
    }
    
//  滚动视图配置
    // 根据当前位置获取对应数组中的位置
    func getNextPageIndex(currentPageIndex : NSInteger) -> NSInteger {
        if(currentPageIndex == -1) {
            return self.allPhotos.count - 1;
        } else if (currentPageIndex == self.allPhotos.count) {
            return 0;
        } else {
            return currentPageIndex;
        }
    }
    
    // 设置滚动视图内容
    func setScrollViewContentDataSource() {
        if (self.contentViews == nil) {
            self.contentViews = NSMutableArray()
        }
        self.contentViews.removeAllObjects()
        
        let beforePageIndex = self.getNextPageIndex(self.currentPageIndex - 1)
        let afterPageIndex =  self.getNextPageIndex(self.currentPageIndex + 1)
        self.contentViews.addObject(self.allPhotos[beforePageIndex])
        self.contentViews.addObject(self.allPhotos[currentPageIndex])
        self.contentViews.addObject(self.allPhotos[afterPageIndex])
    }
    
    // 滚动视图赋值
    func configContentViews() {
        // 获取数据
        self.setScrollViewContentDataSource()
        
        var counter : Int = 0
        
        for content in self.contentViews {
            let result = content["result"] as! ALAsset
            let img = UIImage(CGImage : result.aspectRatioThumbnail().takeUnretainedValue())
            
            // 创建滚动视图对象，目的是放大缩小
            var imgScrollView = self.scrollView.viewWithTag(1000 + counter)
            if imgScrollView == nil {
                imgScrollView = UIScrollView()
            }
            imgScrollView!.tag = 1000 + counter
            (imgScrollView as! UIScrollView).maximumZoomScale = 2
            (imgScrollView as! UIScrollView).minimumZoomScale = 1
            (imgScrollView as! UIScrollView).showsHorizontalScrollIndicator = false
            (imgScrollView as! UIScrollView).showsVerticalScrollIndicator = false;
            (imgScrollView as! UIScrollView).delegate = self;
            
            // 创建图片视图
            var contentView = imgScrollView?.viewWithTag(2000 + counter)
            if contentView == nil {
                contentView = UIImageView()
            }
            contentView!.tag = 2000 + counter;
            (contentView as! UIImageView).image = img;
            
            // 设置视图大小
            imgScrollView!.frame = CGRectMake(ScreenWidth * CGFloat(counter), 0, ScreenWidth, ScreenHeight)
            let scale = img.size.height / img.size.width;
            contentView!.center = CGPointMake(ScreenWidth*0.5, ScreenHeight * 0.5);
            contentView!.bounds = CGRectMake(0, 0, ScreenWidth, ScreenWidth * scale);
            
            imgScrollView?.addSubview(contentView!)
            self.scrollView.addSubview(imgScrollView!)
            counter += 1
        }
        // 每次当前显示页是第二页，也就是tag为1001和2001的视图
        self.scrollView.setContentOffset(CGPointMake(ScreenWidth, 0), animated: false)
        
        // 修改状态
        self.changeState()
    }
    
    // 第一次加载，第一张图高清
    override func viewDidAppear(animated: Bool) {
        let contentView = self.scrollView.viewWithTag(2001) as! UIImageView
        let result = self.contentViews[1]["result"] as! ALAsset
        let fullImg = UIImage(CGImage : result.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        contentView.image = fullImg
    }
    // 滑动过程中，当停止时当前页加载高清图
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let contentView = self.scrollView.viewWithTag(2001) as! UIImageView
        let result = self.contentViews[1]["result"] as! ALAsset
        let fullImg = UIImage(CGImage : result.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        contentView.image = fullImg
    }
    
//  scrollView的回调
    // 返回缩放对象
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if (!(scrollView == self.scrollView)) {
            return scrollView.viewWithTag(2001)
        } else {
            return nil;
        }
    }
    func scrollViewDidEndZooming(scrollView: UIScrollView,
                                   withView view: UIView?,
                                            atScale scale: CGFloat) {
        if !(scrollView == self.scrollView) {
            UIView.animateWithDuration(0.1, animations: { 
                if scale > 1 {
                    if (ScreenHeight < scrollView.contentSize.height) {
                        view!.frame = CGRectMake(view!.frame.origin.x, 0, view!.frame.size.width, view!.frame.size.height)
                    } else {
                        view!.center = CGPointMake(scrollView.frame.size.width * 0.5, scrollView.frame.size.height * 0.5)
                    }
                } else {
                    view!.center = CGPointMake(scrollView.frame.size.width * 0.5, scrollView.frame.size.height * 0.5)

                }
            })
        }
    }
    
    // 滚动翻页
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView == self.scrollView) {
            let contentOffsetX = scrollView.contentOffset.x;
            if contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame)) {
                self.currentPageIndex = self.getNextPageIndex(self.currentPageIndex + 1)
                for view in scrollView.subviews {
                    if view.isKindOfClass(UIScrollView) {
                        (view as! UIScrollView).zoomScale = 1;
                    }
                }
                self.configContentViews()
            }
            if(contentOffsetX <= 0) {
                self.currentPageIndex = self.getNextPageIndex(self.currentPageIndex - 1)
                for view in scrollView.subviews {
                    if view.isKindOfClass(UIScrollView) {
                        (view as! UIScrollView).zoomScale = 1;
                    }
                }
                self.configContentViews()
            }
        }
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
