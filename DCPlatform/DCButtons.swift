//
//  DCButtons.swift
//  DCPlatform
//
//  Created by James Godwin on 16/03/2016.
//  Copyright (c) 2016 Nesta (http://www.nesta.org.uk/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public extension UIButton {

  public var buttonShadowColour: UIColor {
    return UIColor(red: 13/255, green: 71/255, blue: 72/255, alpha: 1)
  }

  public var buttonShadowColourDisabled: UIColor {
    return UIColor(red: 137/255, green: 137/255, blue: 137/255, alpha: 1)
  }

  public var buttonMainColour: UIColor {
    return UIColor.dementiaCitizensBlue()
  }

  public var buttonMainColourDisabled: UIColor {
    return UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
  }

  public var buttonTitleColour: UIColor {
    return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
  }

  public var buttonSelectedColour: UIColor {
    return UIColor.dementiaCitizensBlue()
  }

}

@IBDesignable open class NextButton: UIButton {

  let mainButton = CAShapeLayer()

  override open func layoutSubviews() {
    super.layoutSubviews()
    self.setupViews()
    self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.setImage(UIImage.find("next"), for: UIControlState())
    self.layer.addSublayer(mainButton)
    setUpMetrics()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setImage(UIImage.find("next"), for: UIControlState())
    self.layer.addSublayer(mainButton)
    setUpMetrics()
  }

  func setUpMetrics() {
    self.layer.cornerRadius = 10
    self.setTitleColor(buttonTitleColour, for: UIControlState())
    self.titleLabel?.font = UIFont.dcButtonText
  }

  func setupViews() {
    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 10.0, right: -2.5)
    self.imageView?.tintColor = UIColor.white
    self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2.5, bottom: 10.0, right: 10.0)
    self.imageView?.contentMode = .scaleAspectFit
    self.imageView?.layer.zPosition = 5

    let widthOfButton = self.frame.size.width
    let heightOfButton = self.frame.size.height
    let mainButtonPath = CGRect(x: 5, y: 0, width: widthOfButton - 10, height: heightOfButton - 5)
    mainButton.path = UIBezierPath(roundedRect: mainButtonPath, cornerRadius: 10).cgPath

    switch self.state {
    case UIControlState.disabled :
        self.backgroundColor = buttonShadowColourDisabled
        mainButton.fillColor = buttonMainColourDisabled.cgColor
    case UIControlState() :
        self.backgroundColor = buttonShadowColour
        mainButton.fillColor = buttonMainColour.cgColor
    default : break
    }

    let buttonMask = CAShapeLayer()
    let buttonPath = CGRect(x: 5, y: 0, width: widthOfButton - 10, height: heightOfButton)
    let maskPath = UIBezierPath(roundedRect: buttonPath, cornerRadius: 10)
    buttonMask.frame = self.layer.bounds
    buttonMask.path = maskPath.cgPath
    self.layer.mask = buttonMask
  }

  override open var intrinsicContentSize: CGSize {
    return CGSize(width: 288, height: 76)
  }

}

@IBDesignable class ChoiceButton: UIButton {

  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupViews()
  }

  func setupViews() {

    switch self.state {
    case UIControlState(): self.backgroundColor = UIColor.clear
    case UIControlState.selected: self.backgroundColor = buttonSelectedColour
    default: break
    }

    self.tintColor = UIColor.clear
    self.layer.cornerRadius = 14
    self.layer.borderWidth = 3.0
    self.layer.borderColor = buttonMainColour.cgColor
    self.setTitleColor(buttonMainColour, for: UIControlState())
    self.setTitleColor(UIColor.white, for: UIControlState.selected)
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 256, height: 40)
  }
}

class LinkButton: UIButton {
  var url: URL?
}

@IBDesignable
open class StandardButton: UIButton {

  @IBInspectable var buttonColor: UIColor = UIColor.black {
    didSet {
      layer.borderColor = buttonColor.cgColor
      imageView?.tintColor = buttonColor
      setTitleColor(buttonColor, for: UIControlState())
    }
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    self.imageView!.contentMode = .scaleAspectFit
    self.layer.cornerRadius = 10
    self.layer.borderWidth = 3.0
    self.titleLabel?.font = UIFont.dcButtonText
  }

  override open var intrinsicContentSize: CGSize {
    return CGSize(width: 286, height: 40)
  }
}

@IBDesignable
class MediumButton: StandardButton {

  @IBInspectable var selectedButtonColor: UIColor? {
    didSet {
      if let buttonColor = selectedButtonColor {
        setTitleColor(buttonColor, for: .selected)
      }
    }
  }

  override var isSelected: Bool {
     didSet {
      let color = isSelected ? (selectedButtonColor ?? buttonColor) : buttonColor
      layer.borderColor = color.cgColor
      imageView?.tintColor = color
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if self.imageView!.image != nil {
      let widthOfButton = self.frame.size.width
      self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -90, bottom: 0.0, right: 0.0)
      self.imageEdgeInsets = UIEdgeInsets(top: 15.0, left: widthOfButton - 60, bottom: 15.0, right: 15.0)
    }
  }
}

@IBDesignable
class PlayButton: MediumButton {
  var progress: CGFloat = 0.0 {
    didSet {
      progressLayer.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width * progress, height: self.bounds.height))
      setNeedsDisplay()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addProgressLayer()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    addProgressLayer()
  }

  var progressLayer: CALayer!

  func addProgressLayer() {
    progressLayer = CALayer()
    progressLayer.backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
    if let imageView = self.imageView {
      self.layer.insertSublayer(progressLayer, below: imageView.layer)
    } else {
      self.layer.insertSublayer(progressLayer, at: 0)
    }
  }

  override var isSelected: Bool {
    didSet {
      if !isSelected {
        progressLayer.isHidden = true
      } else {
        progressLayer.isHidden = false
      }
      progress = 0.0
    }
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    progressLayer.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width * progress, height: self.bounds.height))
    progressLayer.cornerRadius = self.layer.cornerRadius
  }
}
