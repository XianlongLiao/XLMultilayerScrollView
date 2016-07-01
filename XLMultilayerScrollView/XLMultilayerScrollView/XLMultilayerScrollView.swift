//
//  XLMultilayerScrollView.swift
//  XLMultilayerScrollView
//
//  Created by 先龙 廖 on 16/7/1.
//  Copyright © 2016年 先龙 廖. All rights reserved.
//

import UIKit

class XLMultilayerScrollView: UIScrollView, UIScrollViewDelegate {

    var topHeaderView: UIView? {
        didSet {
            self.setupTopHeaderView()
        }
    }
    
        /// 默认是nil， 如果传入值则会创建XLSegmentControl
    var segmentItems: Array<String>? {
        didSet {
            self.createSegmentControl()
        }
    }
    
    private var segment: XLSegmentControl? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeMyselfOfConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     初始化自己的配置
     */
    private func initializeMyselfOfConfig() -> Void {
        self.delegate = self
        self.backgroundColor = UIColor.whiteColor()
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceVertical = true
        self.alwaysBounceHorizontal = false
    }
    
    /**
     设置headerView的初始化位置
     */
    private func setupTopHeaderView() -> Void {
        var _frame: CGRect = topHeaderView!.frame
        _frame.origin.x = 0
        _frame.origin.y = 0
        topHeaderView!.frame = _frame
        self.addSubview(topHeaderView!)
    }
    
    /**
     创建分段控制器
     */
    private func createSegmentControl() -> Void {
        segment = XLSegmentControl(frame: CGRectMake(0, 0, self.frame.width, 40))
        segment!.items = segmentItems!
        segment!.redLineWidth = 60
        segment!.animationStyle = .Stretch
        self.addSubview(segment!)
        if let s = segment {
            s.frame.origin.y = topHeaderView!.frame.height
        }
    }
    
    
}
