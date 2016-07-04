//
//  XLMultilayerScrollView.swift
//  XLMultilayerScrollView
//
//  Created by 先龙 廖 on 16/7/1.
//  Copyright © 2016年 先龙 廖. All rights reserved.
//

import UIKit

class XLMultilayerScrollView: UIScrollView, UIScrollViewDelegate, XLSegmentControlDelegate {
    
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
    
    var itemViews: Array<UIView>? {
        didSet {
            self.configItemVies()
        }
    }
    
    /// 分段选择器
    private var segment: XLSegmentControl? = nil
    private var contentCurrentView: UIView? = nil
    /// 左右滑动的SV
    private lazy var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView(frame: self.bounds)
        contentScrollView.delegate = self
        contentScrollView.bounces = false
        contentScrollView.pagingEnabled = true
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.showsVerticalScrollIndicator = false
        return contentScrollView
    }()
    
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
        //        self.bounces = false
        self.alwaysBounceVertical = true
        self.alwaysBounceHorizontal = false
        self.addSubview(contentScrollView)
        
        //test coding
        contentScrollView.backgroundColor = UIColor.blueColor()
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
        contentScrollView.frame.origin.y = CGRectGetMaxY(_frame)
        if let s = segment {
            s.frame.origin.y = topHeaderView!.frame.height
            contentScrollView.frame.origin.y = CGRectGetMaxY(s.frame)
        }
    }
    
    /**
     创建分段控制器
     */
    private func createSegmentControl() -> Void {
        segment = XLSegmentControl(frame: CGRectMake(0, 0, self.frame.width, 40))
        segment!.delegate = self
        segment!.items = segmentItems!
        segment!.redLineWidth = 60
        segment!.animationStyle = .Liner
        self.addSubview(segment!)
        if let t = topHeaderView {
            segment!.frame.origin.y = t.frame.height
        }
        contentScrollView.frame.origin.y = CGRectGetMaxY(segment!.frame)
    }
    
    /**
     配置外部传入的item views
     */
    private func configItemVies() -> Void {
        var index: Int = 0
        self.itemViews?.forEach({[unowned self] (itemView) in
            itemView.frame = self.contentScrollView.bounds
            itemView.frame.origin.x = CGRectGetWidth(self.contentScrollView.frame) * CGFloat(index)
            self.contentScrollView.addSubview(itemView)
            if itemView is UIScrollView || itemView is UITableView {
                let sv = itemView as! UIScrollView
                sv.delegate = self
                //                self.contentScrollView.panGestureRecognizer.requireGestureRecognizerToFail(sv.panGestureRecognizer)
            }
            index += 1
            })
        contentScrollView.contentSize = CGSizeMake(CGFloat(itemViews!.count) * CGRectGetWidth(contentScrollView.frame), 0)
        contentCurrentView = itemViews!.first
    }
    
    //MARK: XLSegmentControlDelegate
    func selectedWithIndex(idx: Int, withObject: XLSegmentControl) {
        contentScrollView.setContentOffset(CGPointMake(CGFloat(idx) * contentScrollView.frame.width, 0), animated: true)
        if let views = itemViews {
            contentCurrentView = views[idx]
        }
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            segment?.moveItemPointFrom(ContentOffset: scrollView.contentOffset)
        }else if (scrollView == contentCurrentView) {
            if let topView = topHeaderView {
                if (self.contentOffset.y < CGRectGetHeight(topView.frame) || scrollView.contentOffset.y < 0) {
                    scrollView.delegate = nil
                    self.delegate = nil
                    var contentOffsetPoint = self.contentOffset
                    contentOffsetPoint.y = contentOffsetPoint.y + scrollView.contentOffset.y//(scrollView.contentOffset.y < 0 ? scrollView.contentOffset.y / 2 : )
                    scrollView.contentOffset = CGPointZero
                    self.contentOffset = contentOffsetPoint
                    scrollView.delegate = self
                    self.delegate = self
                    if self.contentOffset.y < 0 {
                        self.contentOffset = CGPointZero
                    }
                }else if (self.contentOffset.y > CGRectGetHeight(topView.frame)) {
                    self.delegate = nil
                    self.contentOffset = CGPointMake(self.contentOffset.x, CGRectGetHeight(topView.frame))
                    self.delegate = self
                }
            }
        }
    }
    
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if self.contentOffset.y < -self.contentInset.top {
//            self.delegate = nil
//            self.setContentOffset(CGPointMake(0, -self.contentInset.top), animated: true)
//            self.delegate = nil
//        }
//    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
            segment?.moveItemPointEndFrom(Page: page)
        }
//        if self.contentOffset.y < -self.contentInset.top {
//            self.delegate = nil
//            self.setContentOffset(CGPointMake(0, -self.contentInset.top), animated: true)
//            self.delegate = nil
//        }
    }
}
