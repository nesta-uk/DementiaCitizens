//
//  GetSessionTypeVC.swift
//  DCPlatform
//
//  Created by James Godwin on 01/07/2016.
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

public enum DCSessionType: String {
  case Single
  case WithCarer
}

class GetSessionTypeVC: DCViewController {
  var completion: ((DCSessionType) -> Void)?

  var singleButton: UIButton!
  var withCarerButton: UIButton!
  var nextButton: UIButton!

  @IBAction func handleNext(_ sender: AnyObject) {
    if singleButton.isSelected {
      completion?(.Single)
    } else if withCarerButton.isSelected {
      completion?(.WithCarer)
    }
  }

  @IBAction func genderTapped(_ sender: UIButton) {
    if sender.isSelected == false {
      if sender == singleButton {
        singleButton.isSelected = true
        withCarerButton.isSelected = false
      } else {
        singleButton.isSelected = false
        withCarerButton.isSelected = true
      }
      nextButton.isEnabled = true
    }
  }

  override func loadView() {
    super.loadView()

    if let principalName = ApplicationState.sharedInstance.principalName {
      if let carerName = ApplicationState.sharedInstance.carerName {

      singleButton = createChoiceButton("No", action: #selector(GetSessionTypeVC.genderTapped(_:)))
      withCarerButton = createChoiceButton("Yes", action: #selector(GetSessionTypeVC.genderTapped(_:)))

      let buttonView = UIStackView(arrangedSubviews: [singleButton, withCarerButton])

      buttonView.translatesAutoresizingMaskIntoConstraints = false
      buttonView.alignment = .center
      buttonView.distribution = .equalSpacing
      buttonView.spacing = 16
      buttonView.axis = .horizontal

      let prompt = "\(principalName), were you with \(carerName) when you last used this app?"

      let inputs = createInputView(prompt, inputs: buttonView)

      nextButton = createNextButton("Next", image: "next", action: #selector(GetSessionTypeVC.handleNext(_:)))
      nextButton.isEnabled = false

      let container = ConsentContainerView(topView: inputs, bottomView: nextButton)

      self.view.addSubview(container)

      NSLayoutConstraint.activate([
        nextButton.heightAnchor.constraint(equalToConstant: 76),
        nextButton.widthAnchor.constraint(equalToConstant: 288),
        singleButton.heightAnchor.constraint(equalToConstant: 76),
        withCarerButton.heightAnchor.constraint(equalToConstant: 76),
        singleButton.widthAnchor.constraint(equalTo: withCarerButton.widthAnchor),
      ])
      }
    }
  }
}
