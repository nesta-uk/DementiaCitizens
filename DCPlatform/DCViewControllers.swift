//
//  DCViewControllers.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 09/03/2016.
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

class NavigationController: UINavigationController {

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }

}

class DCViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.dementiaCitizensBackground()
    self.navigationController?.navigationBar.isTranslucent = false
    if self.navigationController?.visibleViewController != self.navigationController?.viewControllers[0] {
      let image = UIImage.find("back-button" )
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backButtonPressed))
      self.navigationItem.leftBarButtonItem?.tintColor = UIColor.dementiaCitizensBlue()
    }
  }

  func backButtonPressed(_ sender: UIButton) {
    _ = navigationController?.popViewController(animated: true)
  }

  func createLink(_ text: String, action: Selector) -> UILabel {
    let linkText = UILabel()
    linkText.setContentHuggingPriority(251, for: .vertical)
    linkText.numberOfLines = 0
    linkText.textColor = UIColor.dementiaCitizensBlue()
    linkText.textAlignment = .center
    let underlinedLink = NSAttributedString(string: text, attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
    linkText.attributedText = underlinedLink
    linkText.isUserInteractionEnabled = true
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: action)
    linkText.addGestureRecognizer(gestureRecognizer)
    return linkText
  }

  func createNextButton(_ text: String, image: String, action: Selector, font: UIFont = UIFont.dcButtonText) -> UIButton {
    let nextButton = NextButton(type: .system)
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    nextButton.setTitle(text, for: UIControlState())
    nextButton.titleLabel?.font = font
    nextButton.addTarget(self, action: action, for: .touchUpInside)
    nextButton.titleLabel?.adjustsFontSizeToFitWidth = true
    nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    nextButton.setImage(UIImage.find(image), for: UIControlState())

    return nextButton
  }

  func createChoiceButton(_ text: String, action: Selector) -> UIButton {
    let button = ChoiceButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = UIFont.dcButtonText
    button.addTarget(self, action: action, for: .touchUpInside)
    button.setTitle(text, for: UIControlState())
    button.layoutMargins = UIEdgeInsets(top: 8.0, left: 20, bottom: 8, right: 20)
    button.titleLabel?.adjustsFontSizeToFitWidth = true

    return button
  }

  func createInstructionLabel(_ text: String) -> UILabel {
    let instructionTextView = UILabel()
    instructionTextView.setContentHuggingPriority(251, for: .vertical)
    instructionTextView.translatesAutoresizingMaskIntoConstraints = false
    instructionTextView.font = UIFont.dcBody
    instructionTextView.numberOfLines = 0
    instructionTextView.minimumScaleFactor = 0.5
    instructionTextView.adjustsFontSizeToFitWidth = true
    instructionTextView.lineBreakMode = .byClipping
    instructionTextView.textAlignment = .center
    instructionTextView.layoutMargins = UIEdgeInsets(top: 8.0, left: 20, bottom: 8, right: 20)
    instructionTextView.textColor = UIColor.dementiaCitizensBlack()
    instructionTextView.text = text

    return instructionTextView
  }

  func createCaptionLabel(_ text: String) -> UILabel {
    let captionLabel = UILabel()
    captionLabel.text = text
    captionLabel.font = UIFont.dcCaption
    captionLabel.textColor = UIColor.black.withAlphaComponent(0.6)
    captionLabel.textAlignment = .center
    captionLabel.numberOfLines = 0
    captionLabel.lineBreakMode = .byWordWrapping

    return captionLabel
  }

  func createInputView(_ prompt: String, inputs: UIView) -> UIView {
    let promptLabel = createInstructionLabel(prompt)

    let innerStack = UIStackView(arrangedSubviews: [promptLabel, inputs])
    innerStack.axis = .vertical
    innerStack.distribution = .equalSpacing
    innerStack.spacing = 24
    innerStack.translatesAutoresizingMaskIntoConstraints = false

    let outerStack = UIStackView(arrangedSubviews: [innerStack])
    outerStack.axis = .horizontal
    outerStack.alignment = .leading
    outerStack.distribution = .fill
    outerStack.translatesAutoresizingMaskIntoConstraints = false

    return outerStack
  }

  func createInputWithCaptionView(_ prompt: String, inputs: UIView, caption: String) -> UIView {
    let promptLabel = createInstructionLabel(prompt)
    let captionLabel = createCaptionLabel(caption)

    let innerStack = UIStackView(arrangedSubviews: [promptLabel, inputs, captionLabel])
    innerStack.axis = .vertical
    innerStack.distribution = .equalSpacing
    innerStack.spacing = 24
    innerStack.translatesAutoresizingMaskIntoConstraints = false

    let outerStack = UIStackView(arrangedSubviews: [innerStack])
    outerStack.axis = .horizontal
    outerStack.alignment = .leading
    outerStack.distribution = .fill
    outerStack.translatesAutoresizingMaskIntoConstraints = false

    return outerStack
  }

  func createFeedbackInputView(_ prompt: String, inputs: UIView, name: String) -> UIView {
    let promptLabel = createHeaderLabel(prompt)
    let nameLabel = createInstructionLabel("\(name)'s experience")

    let innerStack = UIStackView(arrangedSubviews: [nameLabel, promptLabel, inputs])
    innerStack.axis = .vertical
    innerStack.distribution = .equalSpacing
    innerStack.spacing = 24
    innerStack.translatesAutoresizingMaskIntoConstraints = false

    let outerStack = UIStackView(arrangedSubviews: [innerStack])
    outerStack.axis = .horizontal
    outerStack.alignment = .leading
    outerStack.distribution = .fill
    outerStack.translatesAutoresizingMaskIntoConstraints = false

    return outerStack
  }

  func createHeaderImage(_ image: UIImage) -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.setContentHuggingPriority(249, for: .vertical)
    imageView.setContentCompressionResistancePriority(749, for: .vertical)
    imageView.contentMode = .scaleAspectFit
    imageView.image = image

    return imageView
  }

  func createTopStackView(_ arrangedSubviews: [UIView]) -> UIStackView {
    let topView = UIStackView(arrangedSubviews:arrangedSubviews)
    topView.translatesAutoresizingMaskIntoConstraints = false
    topView.axis = .vertical
    topView.distribution = .fill
    topView.alignment = .center
    topView.spacing = 8

    return topView
  }

  func createTitleTopStackView(_ arrangedSubviews: [UIView]) -> UIStackView {
    let topView = UIStackView(arrangedSubviews:arrangedSubviews)
    topView.translatesAutoresizingMaskIntoConstraints = false
    topView.axis = .vertical
    topView.distribution = .fill
    topView.alignment = .center
    topView.spacing = 16

    return topView
  }

  func createHeaderLabel(_ text: String) -> UILabel {
    let instructionTextView = UILabel()
    instructionTextView.setContentHuggingPriority(251, for: .vertical)
    instructionTextView.translatesAutoresizingMaskIntoConstraints = false
    instructionTextView.font = UIFont.dcHeader
    instructionTextView.numberOfLines = 0
    instructionTextView.minimumScaleFactor = 0.5
    instructionTextView.adjustsFontSizeToFitWidth = true
    instructionTextView.textAlignment = .center
    instructionTextView.layoutMargins = UIEdgeInsets(top: 8.0, left: 20, bottom: 8, right: 20)
    instructionTextView.textColor = UIColor.dementiaCitizensBlack()
    instructionTextView.text = text

    return instructionTextView
  }

  func createImageWithText(_ text: String, image: UIImage?) -> UIStackView {

    var views = [UIView]()

    if let image = image {
      let imageView = createHeaderImage(image)
      views.append(imageView)
    }

    let instructionTextView = createInstructionLabel(text)
    views.append(instructionTextView)

    return createTopStackView(views)
  }

}

class PageViewController: UIPageViewController {
}

class TableViewController: UITableViewController {
}

class CollectionViewController: UICollectionViewController {
}
