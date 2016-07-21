//
//  ViewController.swift
//  TF-Swift-Image-Picker
//
//  Created by 左建军 on 16/7/2.
//  Copyright © 2016年 lanou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var button : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.button = UIButton(type: UIButtonType.RoundedRect)
        self.button.frame = CGRectMake(0, 0, 100, 100)
        self.button.center = self.view.center
        self.button.setTitle("选取照片", forState: UIControlState.Normal)
        self.button.addTarget(self, action: #selector(self.selectPhotos(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
    }
    
    func selectPhotos(button : UIButton) {
        let imgPickVC = TFImagePickerViewController()
        imgPickVC.selectFinish = {(NSDictionary) -> ()
            in
            
        }
        imgPickVC.options = [
            "maxNumOfSelect": 2,  // 照片最大选取数
            "quality": 0.5,  // 照片压缩率，按照像素压缩
            "maxWidth": 600,  // 最大尺寸宽度
            "maxHeight": 600, // 最大尺寸高度
            "listNavigationBarOptions":[ // 缩略图页面，上导航条的设置项
                "backgroundColor":UIColor.blackColor(),  // 上导航栏的背景颜色，默认为纯黑色
                "alpha":0.8,  // 设置上导航视图的透明度，默认为0.8
                "titleColor":UIColor.whiteColor()  // 设置上导航栏上的字体的颜色，默认是纯白色
            ],
            "listFinishBarOptions":[ // 缩略图页面，完成状态栏设置项
                "backgroundColor":UIColor.lightGrayColor(), // 完成状态栏背景颜色，默认浅灰色
                "tintColor":UIColor.greenColor(),  //状态栏上完成按钮和文本框背景颜色， 默认纯绿色
                "titleColor":UIColor.whiteColor()  // 显示选择个数的文本颜色，默认纯白色
            ],
            "bigNavigationBarOptions":[  // 大图页面，上导航条设置项
                "backgroundColor":UIColor.blackColor(),  // 上导航栏的背景颜色，默认为纯黑色
                "alpha":0.5,  // 设置上导航视图的透明度，默认为0.5
            ],
            "bigFinishBarOptions":[  // 大图页面，完成状态栏设置项
                "backgroundColor":UIColor.blackColor(),  // 完成状态栏背景颜色，默认为纯黑色
                "alpha":0.5,  // 设置状态栏的透明度，默认为0.5
                "tintColor":UIColor.greenColor(),  //状态栏上完成按钮和文本框背景颜色， 默认纯绿色
                "titleColor":UIColor.whiteColor()  // 显示选择个数的文本颜色，默认纯白色
            ],
            "storageOptions": [  // 存储的设置项
                "skipBackup": true,  // 默认true表示跳过备份到iCloud和iTunes,一般应用中不包含用户的数据的文件无须备份
                "path":"savePhotoPath" // 创建存储的文件夹路径，图片保存在沙盒caches下的文件夹名称
            ]
        ];
        
        imgPickVC.selectFinish = {(res : NSDictionary) in
            if res["numOfSelect"]?.integerValue > 0 {
                print(res)
                let results = res["results"] as! NSArray
                let result = results[0] as! NSDictionary
                let nsd = NSData(contentsOfURL:result["uri"] as! NSURL)
                
                let image : UIImage! = UIImage(data:nsd!)
                self.button.setBackgroundImage(image, forState: UIControlState.Normal)
            }
        };
        
        let nav = UINavigationController(rootViewController : imgPickVC)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }


}

