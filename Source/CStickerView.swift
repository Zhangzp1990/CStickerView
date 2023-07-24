//
//  CStickerView.swift
//
//  Created by zhangzp on 2022/3/15.
//

import Foundation
import UIKit
 
@objc protocol CStickerViewDelegate: AnyObject {
    /// 贴纸点击事件
    @objc optional func stickerViewDidTap(sticker: CStickerView)
    /// 贴纸关闭事件
    @objc optional func stickerViewDidClose(sticker: CStickerView)
    /// 贴纸移动事件
    @objc optional func stickerViewMoveEvent(sticker: CStickerView)
    /// 贴纸旋转事件
    @objc optional func stickerViewRotateEvent(sticker: CStickerView)
    /// 贴纸缩放事件
    @objc optional func stickerViewScaleEvent(sticker: CStickerView)
    /// 单指旋转事件
    @objc optional func stickerViewSingleFingerEvent(sticker: CStickerView)
}

class CStickerView: UIView {
    public var minScale: CGFloat = 0.5
    public var maxScale: CGFloat = 5.0
    
    private var beganLocation: CGPoint = .zero
    private let defaultImageSize: CGFloat = 22
    
    public var delegate: CStickerViewDelegate?
    
    /// 当前缩放值
    private var currentScale: CGFloat = 1.0 {
        didSet {
            self.processDistortion()
        }
    }
    
    /// 边框颜色
    public var borderColor: UIColor = UIColor(r: 247, g: 216, b: 188) {
        didSet {
            self.borderLayer.strokeColor = borderColor.cgColor
        }
    }
    
    /// 关闭Image
    public var closeImage: UIImage? = UIImage(named: "deleteImage") {
        didSet {
            self.closeView.image = closeImage
        }
    }
    
    /// 旋转Image
    public var rotateImage: UIImage? = UIImage(named: "rotateImage") {
        didSet {
            self.rotateView.image = rotateImage
        }
    }
    
    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = self.contentView.bounds
        layer.lineWidth = 2.0
        layer.lineJoin = .round
        layer.fillColor = nil
        layer.strokeColor = borderColor.cgColor
        layer.lineDashPattern = [5.0, 3.0]
        layer.allowsEdgeAntialiasing = true
        layer.path = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: 2.0).cgPath
        return layer
    }()
    
    private lazy var closeView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = closeImage
        imageView.frame = CGRect(x: 0, y: 0, width: defaultImageSize, height: defaultImageSize)
        return imageView
    }()
    
    private lazy var rotateView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = rotateImage
        imageView.frame = CGRect(
            x: self.frame.width - defaultImageSize,
            y: self.frame.height - defaultImageSize,
            width: defaultImageSize,
            height: defaultImageSize
        )
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var contentView: UIView = {
        let content = UIView()
        content.frame = CGRect(
            x: defaultImageSize / 2.0,
            y: defaultImageSize / 2.0,
            width: self.frame.width - defaultImageSize,
            height: self.frame.height - defaultImageSize
        )
        return content
    }()
    
    private var containedView: UIView?
    
    public init(frame: CGRect, view: UIView) {
        super.init(frame: frame)
        setupView(view)
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(_ view: UIView) {
        containedView = view
        contentView.layer.addSublayer(borderLayer)
        addSubview(contentView)
        addSubview(closeView)
        addSubview(rotateView)
        view.frame = contentView.bounds
        contentView.addSubview(view)
    }
    
    private func addGesture() {
        /// 拖动手势
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(gesture:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        self.contentView.addGestureRecognizer(panGesture)
        
        /// 捏合手势
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchAction(gesture:)))
        pinchGesture.delegate = self
        self.contentView.addGestureRecognizer(pinchGesture)
        
        /// 旋转手势
        let rotateGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(rotateAction(gesture:)))
        rotateGesture.delegate = self
        self.contentView.addGestureRecognizer(rotateGesture)
        
        /// 单指旋转
        let singleFingerGesture = UIPanGestureRecognizer(target: self, action: #selector(singleFingerAction(gesture:)))
        singleFingerGesture.delegate = self
        rotateView.addGestureRecognizer(singleFingerGesture)
        
        /// 单击手势
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeAction(gesture:)))
        closeTapGesture.delegate = self
        closeView.addGestureRecognizer(closeTapGesture)
        
        let contentTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentTapAction(gesture:)))
        contentTapGesture.delegate = self
        contentView.addGestureRecognizer(contentTapGesture)
    }
    
    /// 文字放大后的失真处理
    private func processDistortion() {
        if let textlabel = containedView as? UILabel {
            let scaleFactor = max(self.currentScale, 1.0)
            textlabel.contentScaleFactor = scaleFactor
        }
    }
    
    /// 需要根据缩放旋转重新reload删除和旋转视图
    private func reloadViewFrame() {
        let originalCenter = self.contentView.center.applying(self.contentView.transform.inverted())
        
        self.closeView.center = CGPoint(
            x: originalCenter.x - self.contentView.bounds.size.width / 2.0,
            y: originalCenter.y - self.contentView.bounds.size.height / 2.0
        ).applying(self.contentView.transform)
        
        
        self.rotateView.center = CGPoint(
            x: originalCenter.x + self.contentView.bounds.size.width / 2.0,
            y: originalCenter.y + self.contentView.bounds.size.height / 2.0
        ).applying(self.contentView.transform)
    }
    
    func GetPointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}

extension CStickerView {
    @objc func closeAction(gesture: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.stickerViewDidClose?(sticker: self)
        }
        self.removeFromSuperview()
    }
    
    @objc func contentTapAction(gesture: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.stickerViewDidTap?(sticker: self)
        }
    }
    
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.superview)
        
        if let delegate = self.delegate {
            delegate.stickerViewMoveEvent?(sticker: self)
        }
    }
    
    @objc func pinchAction(gesture: UIPinchGestureRecognizer) {
        let newScale = gesture.scale * self.currentScale
        
        guard newScale > minScale && newScale < maxScale else {
            return
        }
        self.currentScale = newScale
        self.contentView.transform = self.contentView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1;
        
        self.reloadViewFrame()
        
        if let delegate = self.delegate {
            delegate.stickerViewScaleEvent?(sticker: self)
        }
    }
    
    @objc func rotateAction(gesture: UIRotationGestureRecognizer) {
        self.contentView.transform = self.contentView.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
        self.reloadViewFrame()
        
        if let delegate = self.delegate {
            delegate.stickerViewRotateEvent?(sticker: self)
        }
    }
    
    @objc func singleFingerAction(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            self.beganLocation = gesture.location(in: self.contentView.superview)
        } else if gesture.state == .changed {
            let location = gesture.location(in: self.contentView.superview)
            let prevLocation = self.beganLocation
            self.beganLocation = location
            let beganCenter = self.contentView.center
            
            /// 计算拖动时的scale
            let currRadius = GetPointDistance(p1: location, p2: self.contentView.center)
            let prevRadius = GetPointDistance(p1: prevLocation, p2: self.contentView.center)
            let scale = CGFloat(currRadius / prevRadius)
            
            /// 计算拖动时的rotation
            let currRotation = atan2f(
                Float((location.y - beganCenter.y)),
                Float((location.x - beganCenter.x))
            )
            let prevRotation = atan2f(
                Float((prevLocation.y - beganCenter.y)),
                Float((prevLocation.x - beganCenter.x))
            )
            let rotation = CGFloat(currRotation - prevRotation)
            
            let newScale = scale * self.currentScale
            guard newScale > minScale && newScale < maxScale else {
                return
            }
            self.currentScale = newScale
            
            self.contentView.transform = self.contentView.transform.scaledBy(x: scale, y: scale)
            self.contentView.transform = self.contentView.transform.rotated(by: rotation)
        }
        
        reloadViewFrame()

        if let delegate = self.delegate {
            delegate.stickerViewSingleFingerEvent?(sticker: self)
        }
    }
}

extension CStickerView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !self.isHidden && self.alpha >= 1.0 else {
            return super.hitTest(point, with: event)
        }

        if self.closeView.point(inside: self.convert(point, to: self.closeView), with: event) {
            return self.closeView
        }

        if self.rotateView.point(inside: self.convert(point, to: self.rotateView), with: event) {
            return self.rotateView
        }
        
        if self.contentView.point(inside: self.convert(point, to: self.contentView), with: event) {
            return self.contentView
        }
        
        return super.hitTest(point, with: event)
    }
}

extension CStickerView: UIGestureRecognizerDelegate {
    /// 多手势冲突
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
