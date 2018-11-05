//
//  SJStepper.swift
//  SJStepper
//
//  Created by 승진김 on 2018. 11. 4..
//  Copyright © 2018년 seungjin. All rights reserved.
//

import UIKit

class SJStepper: UIView {
    
    //MARK:- Property
    
    private var _minValue: Int = 0 // 최소값
    private var _maxValue: Int = 999 // 최대값
    private var _currentValue: Int = 0 // 현재값
    private var countLabelCenter: CGPoint!
    public var isSlideGesture: Bool = false
    public var isVibrateAnimation: Bool = false
    
    
    //시작값
    public var startValue = 1 {
        didSet {
            countLabel.text = String(startValue)
        }
    }
    
    public var maxValue: Int {
        get {
            return _maxValue
        }
        set {
            _maxValue = newValue
        }
    }
    
    public var minValue: Int {
        get {
            return _minValue
        }
        set {
            _minValue = newValue
        }
    }
    
    public var currentValue: Int {
        return startValue
    }
    
    public let minusButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: UIControlState.normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(minusButtonhandle(sender:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpHandle), for: .touchUpInside)
        return button
    }()
    
    public let plusButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: UIControlState.normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(plusButtonhandle(sender:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpHandle), for: .touchUpInside)
        return button
    }()
    
    public let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    
    //MARK:- Function
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupStepper()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStepper()
    }
    
    override public func layoutSubviews() {
        
        let buttonsWidth = bounds.size.width * ( 0.5 / 2)
        let labelWidth = bounds.size.width * 0.5
        minusButton.frame = CGRect(x: 0, y: 0, width: buttonsWidth, height: bounds.size.height)
        countLabel.frame = CGRect(x: buttonsWidth, y: 0, width: labelWidth, height: bounds.size.height)
        plusButton.frame = CGRect(x: labelWidth + buttonsWidth, y: 0, width: buttonsWidth, height: bounds.size.height)
        
        countLabelCenter = countLabel.center
    }
    
    convenience init(minusTitle: String? = nil, plusTitle: String? = nil) {
        self.init()
        
        initStepper(minusTitle: minusTitle, plusTitle: plusTitle)
    }
    
    convenience init(minusNormalImage: String,
                     minusHighlightedImage: String? = nil,
                     plusNormalImage: String,
                     plusHighlightedImage: String? = nil) {
        
        self.init()
        
        initStepper(minusNormalImage: minusNormalImage, minusHighlightedImage: minusHighlightedImage, plusNormalImage: plusNormalImage, plusHighlightedImage: plusHighlightedImage)
    }
    
    fileprivate func initStepper(minusTitle: String?, plusTitle: String?) {
        minusButton.setTitle(minusTitle, for: .normal)
        plusButton.setTitle(plusTitle, for: .normal)
    }
    
    fileprivate func initStepper(minusNormalImage: String,
                                 minusHighlightedImage: String?,
                                 plusNormalImage: String,
                                 plusHighlightedImage: String?) {
        
        minusButton.setImage(UIImage(named: minusNormalImage), for: .normal)
        minusButton.setImage(UIImage(named: minusHighlightedImage ?? ""), for: .highlighted)
        plusButton.setImage(UIImage(named: plusNormalImage), for: .normal)
        plusButton.setImage(UIImage(named: plusHighlightedImage ?? ""), for: .highlighted)
        
    }
    
    private func setupStepper() {
        [minusButton, countLabel, plusButton].forEach {
            addSubview($0)
        }
        
        setupGuesture()
    }
    
    //MARK:- Button Event
    @objc private func minusButtonhandle(sender: UIButton) {
        if startValue > minValue {
            startValue -= 1
            changeValueToSlide(slideLength: -slideLength)
        }
    }
    
    @objc private func plusButtonhandle(sender: UIButton) {
        if startValue < maxValue {
            startValue += 1
            changeValueToSlide(slideLength: slideLength)
        }
    }
    
    @objc private func buttonTouchUpHandle() {
        slideLengthToOriginPostion()
    }
    
    //MARK:- Slide Animation
    private var slideLength: CGFloat = 5
    private var slideDuration: TimeInterval = TimeInterval(0.1)
    
    private func changeValueToSlide(slideLength: CGFloat) {
        guard isVibrateAnimation == true else { return }
        
        UIView.animate(withDuration: slideDuration) {
            self.countLabel.center.x += slideLength
        }
    }
    
    private func slideLengthToOriginPostion() {
        if countLabel.center != countLabelCenter {
            UIView.animate(withDuration: slideDuration) {
                self.countLabel.center = self.countLabelCenter
            }
        }
    }
    
    //MARK:- Gesture
    private func setupGuesture() {
        let valueChangeGesture = UIPanGestureRecognizer(target: self, action: #selector(valueChangeGestureHandle(gesture:)))
        valueChangeGesture.maximumNumberOfTouches = 1
        countLabel.isUserInteractionEnabled = true
        countLabel.addGestureRecognizer(valueChangeGesture)
    }
    
    @objc private func valueChangeGestureHandle(gesture: UIPanGestureRecognizer) {
        guard isSlideGesture == true else { return }
        
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: countLabel)
            let leftGesture = countLabelCenter.x - slideLength
            let rightGesture = countLabelCenter.x + slideLength
            countLabel.center.x = max(leftGesture, min(rightGesture, countLabel.center.x + translation.x))
            
            if countLabel.center.x == leftGesture {
                if startValue > minValue {
                    self.startValue -= 1
                }
            } else if countLabel.center.x == rightGesture {
                if startValue < maxValue {
                    self.startValue += 1
                }
            }
            
            gesture.setTranslation(CGPoint.zero, in: countLabel)
        case .ended:
            slideLengthToOriginPostion()
        default:
            break
        }
    }
    
    
}
