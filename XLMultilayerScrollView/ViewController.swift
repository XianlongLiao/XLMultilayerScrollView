//
//  ViewController.swift
//  XLMultilayerScrollView
//
//  Created by 先龙 廖 on 16/7/1.
//  Copyright © 2016年 先龙 廖. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var views: Array<UIView> = Array()
        let colors = [UIColor.purpleColor(), UIColor.orangeColor(), UIColor.lightGrayColor(), UIColor.brownColor()]
        for i in 0...3 {
            let sv = UIScrollView()
            sv.contentSize = CGSizeMake(0, 1000)
            sv.backgroundColor = colors[i]
//            sv.bounces = false
            views.append(sv)
        }
        
        let sv = XLMultilayerScrollView(frame: self.view.bounds)
        self.view.addSubview(sv)
        
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 180))
        headerView.backgroundColor = UIColor.redColor()
        sv.topHeaderView = headerView
        sv.backgroundColor = UIColor.lightGrayColor()
        sv.contentSize = CGSizeMake(sv.frame.width, sv.frame.height + headerView.frame.height)
        sv.segmentItems = ["主页", "组合", "文章", "帖子"]
        sv.itemViews = views
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

