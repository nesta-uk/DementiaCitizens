//
//  YesNoVC.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 19/05/2016.
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

import Foundation
import UIKit

enum YesNoAnswer {
  case yes
  case nope
}

class YesNoVC: DCViewController {

  var yesButton: UIButton!
  var noButton: UIButton!
  var nextButton: UIButton!

  var correctAnswer = YesNoAnswer.yes
  var prompt: String?

  var completion: ((Bool) -> Void)?

  @IBAction func handleNext(_ sender: UIButton) {
    if yesButton.isSelected {
      completion?(correctAnswer == .yes)
    } else if noButton.isSelected {
      completion?(correctAnswer == .nope)
    }
  }

  @IBAction func yesButtonTapped(_ sender: UIButton) {
    yesButton.isSelected = true
    noButton.isSelected = false
    nextButton.isEnabled = true
  }

  @IBAction func noButtonTapped(_ sender: UIButton) {
    yesButton.isSelected = false
    noButton.isSelected = true
    nextButton.isEnabled = true
  }

  override func loadView() {
    super.loadView()
    if let prompt = prompt {

      yesButton = createChoiceButton("Yes", action: #selector(YesNoVC.yesButtonTapped(_:)))
      noButton = createChoiceButton("No", action: #selector(YesNoVC.noButtonTapped(_:)))

      let buttonView = UIStackView(arrangedSubviews: [yesButton, noButton])

      buttonView.translatesAutoresizingMaskIntoConstraints = false
      buttonView.alignment = .center
      buttonView.distribution = .equalSpacing
      buttonView.spacing = 16
      buttonView.axis = .horizontal

      let inputs = createInputView(prompt, inputs: buttonView)

      nextButton = createNextButton("Next", image: "next", action: #selector(YesNoVC.handleNext(_:)))
      nextButton.isEnabled = false

      let container = ConsentContainerView(topView: inputs, bottomView: nextButton)

      self.view.addSubview(container)

      NSLayoutConstraint.activate([
        nextButton.heightAnchor.constraint(equalToConstant: 76),
        nextButton.widthAnchor.constraint(equalToConstant: 288),
        yesButton.heightAnchor.constraint(equalToConstant: 76),
        noButton.heightAnchor.constraint(equalToConstant: 76),
        yesButton.widthAnchor.constraint(equalTo: noButton.widthAnchor),
      ])
    }
  }
}
