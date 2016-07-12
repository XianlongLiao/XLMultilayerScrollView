//
//  XLSegmentControl.swift
//  XLMultilayerScrollView
//
//  Created by 先龙 廖 on 16/7/1.
//  Copyright © 2016年 先龙 廖. All rights reserved.
//

import UIKit

enum AnimationStyle: Int {
    case Liner
//    case Stretch
}

protocol XLSegmentControlDelegate: class {
    func selectedWithIndex(idx: Int, withObject: XLSegmentControl)
}

class XLSegmentControl: UIView {
    struct Tag {
        static let buttonBaseTag = 300
        static let titleBaseTag = 400
    }
    
    weak var delegate: XLSegmentControlDelegate?
    var animationStyle: AnimationStyle = .Liner
    var enabledBlurEffect: Bool = false {
        didSet {
            self.blurView!.hidden = !self.enabledBlurEffect
            if self.blurView!.hidden == false {
                self.backgroundColor = UIColor.clearColor()
            }else {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    /// 当前选择的Index
    var currentSelectedIndex: Int {
        return self.selectedIndex
    }
    private var selectedIndex: Int = 0
    private var preSelectedIndex: Int = 0
    private var itemWidth: CGFloat = 0
    private var labelItems: Array<UILabel> = Array() //titleLabel items
    private var titleNormalColorComponents: [Int] = [0, 0, 0]
    private var titleSelectColorComponents: [Int] = [133, 133, 133]
    private var clicked: Bool = false
    private var bottomLineView: UIView?
    private var bottomRedLine: UIImageView?
    private var blurView: UIVisualEffectView?
    
    
    /// 是否启用下方的红线 默认为启用
    var enabledBottomLine: Bool = true {
        didSet {
            self.createBttomLine()
        }
    }
    /// 下方红线的长度，不设置的话，为0的话自适应
    var redLineWidth: CGFloat = 0 {
        didSet {
            if self.enabledBottomLine == true {
                self.bottomRedLine!.frame.size.width = redLineWidth
                self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - redLineWidth) / 2
            }
        }
    }
    
    
    /// 分段的title
    var items: Array<String> = Array() {
        didSet {
            self.createSubButtons()
        }
    }
    
    /// title默认颜色
    var titleNormalColor: UIColor = UIColor.blackColor() {
        didSet {
            self.labelItems.forEach { (b) in
                if b.tag != (Tag.titleBaseTag + self.selectedIndex) {
                    b.textColor = titleNormalColor
                }
            }
            titleNormalColorComponents = titleNormalColor.rgb()
        }
    }
    
    /// title选中的颜色
    var titleSelectColor: UIColor = UIColor.redColor() {
        didSet {
            let b = self.labelItems[self.selectedIndex]
            b.textColor = titleSelectColor
            titleSelectColorComponents = titleSelectColor.rgb()
        }
    }
    
    /// title的字体
    var font: UIFont = UIFont.systemFontOfSize(15) {
        didSet {
            self.labelItems.forEach { (b) in
                b.font = font
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeMyselfConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeMyselfConfig() -> Void {
        self.backgroundColor = UIColor.whiteColor()
        titleNormalColorComponents = titleNormalColor.rgb()
        titleSelectColorComponents = titleSelectColor.rgb()
        blurView = UIVisualEffectView(frame: self.bounds)
        let effect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        blurView!.effect = effect
        blurView!.frame = self.bounds
        self.addSubview(blurView!)
        blurView!.hidden = true
    }
    
    private func createSubButtons() -> Void {
        itemWidth = self.frame.width / CGFloat(items.count)
        for i in 0...(items.count - 1) {
            let item = items[i]
            let btn = UIButton(type: .Custom)
            btn.frame.size.width = itemWidth
            btn.frame.size.height = self.frame.height
            btn.frame.origin.y = 0
            btn.frame.origin.x = itemWidth * CGFloat(i)
            btn.tag = Tag.buttonBaseTag + i
            btn.addTarget(self, action: #selector(clickActionWithSelectedBtn(_:)),
                          forControlEvents: .TouchUpInside)
            self.addSubview(btn)
            
            let titleLabel = UILabel()
            titleLabel.text = item
            titleLabel.font = self.font
            titleLabel.textColor = self.titleNormalColor
            titleLabel.sizeToFit()
            titleLabel.frame.origin.x = (btn.frame.width - titleLabel.frame.width) / 2
            titleLabel.frame.origin.y = (btn.frame.height - titleLabel.frame.height) / 2
            titleLabel.tag = Tag.titleBaseTag + i
            btn.addSubview(titleLabel)
            labelItems.append(titleLabel)
        }
        self.createBttomLine()
        self.selectedItem(Index: 0, animate: false)
    }
    
    func clickActionWithSelectedBtn(sender: AnyObject) -> Void {
        let btn = sender as! UIButton
        let idx = btn.tag - Tag.buttonBaseTag
        if idx != selectedIndex {
            clicked = true
            self.selectedItem(Index: idx, animate: true)
        }
    }
    
    func selectedItem(Index idx: Int, animate: Bool) -> Void {
        selectedIndex = idx
        if let d = delegate {
            d.selectedWithIndex(selectedIndex, withObject: self)
        }
        self.selectItemFrom(Index: selectedIndex)
        if enabledBottomLine == true && animate == true {
            self.selectedBottomLineMoveTo(Index: selectedIndex)
        }
    }
    
    //MARK: 点击按钮 - item title变色
    private func selectItemFrom(Index idx: Int) {
        labelItems.forEach { (b) in
            if b.tag != (Tag.titleBaseTag + self.selectedIndex) {
                b.textColor = titleNormalColor
            }else {
                b.textColor = titleSelectColor
            }
        }
    }
    
    //MARK: 点击按钮 - item line 移动
    private func selectedBottomLineMoveTo(Index idx: Int) -> Void {
        /**
         平移 Liner
         */
        func animationLiner() {
            let selectLabel = self.labelItems[idx]
            UIView.animateWithDuration(0.35,
                                       animations: { [unowned self] in
                                        self.bottomLineView!.frame.origin.x = self.itemWidth * CGFloat(idx)
                                        if self.redLineWidth == 0 {
                                            self.bottomRedLine!.frame.size.width = selectLabel.frame.width
                                            self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
                                        }
            }) {[unowned self] (complete) in
                self.clicked = false
                self.preSelectedIndex = self.selectedIndex
            }
        }
        /**
         拉伸 Stretch
         */
        func animationStretch() {
            let selectLabel = self.labelItems[idx]
            let offsetIdx = selectedIndex > preSelectedIndex ? preSelectedIndex : selectedIndex
            let interval: CGFloat = CGFloat(fabsf(Float(selectedIndex) - Float(preSelectedIndex)))
            UIView.animateWithDuration(0.3,
                                       animations: { [unowned self] in
                                        self.bottomLineView!.frame.size.width += self.itemWidth * interval
                                        self.bottomLineView!.frame.origin.x = self.itemWidth * CGFloat(offsetIdx)
                                        if self.redLineWidth == 0 {
                                            self.bottomRedLine!.frame.size.width = selectLabel.frame.width
                                            self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
                                        }else {
                                            self.bottomRedLine!.frame.size.width += self.itemWidth * interval
                                            self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
                                        }
            }) {[unowned self] (complete) in
                UIView.animateWithDuration(0.2,
                                           animations: {
                                            self.bottomLineView!.frame.size.width = self.itemWidth
                                            self.bottomLineView!.frame.origin.x = self.itemWidth * CGFloat(idx)
                                            if self.redLineWidth == 0 {
                                                self.bottomRedLine!.frame.size.width = selectLabel.frame.width
                                                self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
                                            }else {
                                                self.bottomRedLine!.frame.size.width = self.redLineWidth
                                                self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
                                            }
                    }, completion: { (complete) in
                        self.clicked = false
                        self.preSelectedIndex = self.selectedIndex
                })
            }
        }
        
        if animationStyle == .Liner {
            animationLiner()
        }
//        else if animationStyle == .Stretch {
//            animationStretch()
//        }
    }
    
    /**
     根据scroll view的content offset进行移动
     
     - parameter offset:      scrollView.contentOffset
     */
    func moveItemPointFrom(ContentOffset offset: CGPoint) -> Void {
        if clicked == false {
            let offsetX = offset.x * (itemWidth / self.frame.size.width) //红线应该移动到的位置
            let sT = Int(offset.x / self.frame.size.width)
            if sT < 0 || sT > labelItems.count - 1 {
                return
            }
            let itemLabel = labelItems[sT]
            let percent = (offsetX - itemWidth * CGFloat(sT)) / itemWidth
            self.changeColorFor(Item: itemLabel, redPercent: Float(1.0 - percent))
            if sT + 1 > labelItems.count - 1 || Int(offsetX) % Int(itemWidth) == 0 {
                return;
            }
            let preItemLabel = labelItems[sT + 1]
            self.changeColorFor(Item: preItemLabel, redPercent: Float(percent))
            
            if animationStyle == .Liner {
                self.bottomLineView!.frame.origin.x = offsetX
            }
//            else if animationStyle == .Stretch {
//                let isLeft = self.isSlideToLeftFrom(ContentOffset: offset)
//                if isLeft {
//                    self.bottomLineView!.frame.size.width = itemWidth + (offsetX - itemWidth * CGFloat(sT))
//                    self.bottomRedLine!.frame.size.width = redLineWidth + (offsetX - itemWidth * CGFloat(sT))
//                    self.bottomLineView!.frame.origin.x = CGFloat(sT) * self.itemWidth
//                    self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
//                }else {
//                    self.bottomLineView!.frame.origin.x = offsetX
//                    self.bottomLineView!.frame.size.width = (itemWidth + itemWidth * CGFloat(sT + 1)) - offsetX
//                    //                    self.bottomRedLine!.frame.size.width = redLineWidth + (offsetX - itemWidth * CGFloat(sT))
//                    //                    self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
//                }
//            }
        }
    }
    
    func moveItemPointEndFrom(Page page: Int) -> Void {
        self.selectedItem(Index: page, animate: false)
        if animationStyle == .Liner {
            self.bottomLineView!.frame.origin.x = CGFloat(self.selectedIndex) * itemWidth
            self.preSelectedIndex = self.selectedIndex
        }
//        else if animationStyle == .Stretch {
//            UIView.animateWithDuration(0.2, animations: {
//                self.bottomLineView!.frame.size.width = self.itemWidth
//                self.bottomRedLine!.frame.size.width = self.redLineWidth
//                self.bottomLineView!.frame.origin.x = CGFloat(self.selectedIndex) * self.itemWidth
//                self.bottomRedLine!.frame.origin.x = (self.bottomLineView!.frame.width - self.bottomRedLine!.frame.width) / 2
//                
//                }, completion: { (complete) in
//                    self.preSelectedIndex = self.selectedIndex
//            })
//        }
    }
    
    private func changeColorFor(Item label: UILabel, redPercent: Float) -> Void {
        let r = UIColor.lerp(redPercent, min: Float(titleNormalColorComponents[0]), max: Float(titleSelectColorComponents[0]))
        let g = UIColor.lerp(redPercent, min: Float(titleNormalColorComponents[1]), max: Float(titleSelectColorComponents[1]))
        let b = UIColor.lerp(redPercent, min: Float(titleNormalColorComponents[2]), max: Float(titleSelectColorComponents[2]))
        label.textColor = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
    
    //MARK: 创建下方红线
    private func createBttomLine() -> Void {
        if enabledBottomLine == true && labelItems.count != 0 {
            let itemLabel = labelItems.first
            
            bottomLineView = UIView(frame: CGRectMake(CGFloat(selectedIndex) * itemWidth, self.frame.height - 2, itemWidth, 2))
            bottomLineView!.backgroundColor = UIColor.clearColor()
            self.addSubview(bottomLineView!)
            
            let lineWidth = redLineWidth == 0 ? itemLabel!.frame.width : redLineWidth
            bottomRedLine = UIImageView(frame: CGRectMake((itemWidth - lineWidth) / 2, 0, lineWidth, 2))
            bottomRedLine!.backgroundColor = titleSelectColor
            bottomRedLine!.layer.cornerRadius = 1
            bottomLineView!.addSubview(bottomRedLine!)
        }else {
            if let bottomLine = bottomLineView {
                bottomLine.removeFromSuperview()
            }
            if let redLine = bottomRedLine {
                redLine.removeFromSuperview()
            }
        }
    }
    
    
    func isSlideToLeftFrom(ContentOffset offset: CGPoint) -> Bool {
        struct STATIC {
            static var newX: CGFloat = 0
            static var oldX:  CGFloat = 0
        }
        var ret = false
        STATIC.newX = offset.x
        ret = STATIC.newX > STATIC.oldX
        STATIC.oldX = STATIC.newX
        return ret
    }
}

extension UIColor {
    
    func rgb() -> [Int] {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            return [iRed, iGreen, iBlue, iAlpha]
        } else {
            // Could not extract RGBA components:
            return [0, 0, 0, 0]
        }
    }
    
    class func lerp(percent: Float, min: Float, max: Float) -> Float {
        var result = min
        result = min + percent * (max - min)
        return result
    }
}
