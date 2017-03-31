//
//  GetGenderVC.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 17/03/2016.
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

class GetGenderVC: DCViewController {

  var maleButton: UIButton!
  var femaleButton: UIButton!

  var nextButton: UIButton!

  var prompt: String?

  var completion: ((Gender) -> Void)?

  @IBAction func handleNext(_ sender: UIButton) {
    if maleButton.isSelected {
        completion?(.Male)
    } else if femaleButton.isSelected {
        completion?(.Female)
    }
  }

  @IBAction func genderTapped(_ sender: UIButton) {

    if sender.isSelected == false {
      if sender == maleButton {
        maleButton.isSelected = true
        femaleButton.isSelected = false
      } else {
        maleButton.isSelected = false
        femaleButton.isSelected = true
      }
      nextButton.isEnabled = true
    }
  }

  override func loadView() {
    super.loadView()
    if let prompt = prompt {

      maleButton = createChoiceButton("Male", action: #selector(GetGenderVC.genderTapped(_:)))
      femaleButton = createChoiceButton("Female", action: #selector(GetGenderVC.genderTapped(_:)))

      let buttonView = UIStackView(arrangedSubviews: [femaleButton, maleButton])

      buttonView.translatesAutoresizingMaskIntoConstraints = false
      buttonView.alignment = .center
      buttonView.distribution = .equalSpacing
      buttonView.spacing = 16
      buttonView.axis = .horizontal

      let inputs = createInputView(prompt, inputs: buttonView)

      nextButton = createNextButton("Next", image: "next", action: #selector(GetGenderVC.handleNext(_:)))
      nextButton.isEnabled = false

      let container = ConsentContainerView(topView: inputs, bottomView: nextButton)

      self.view.addSubview(container)

      NSLayoutConstraint.activate([
        nextButton.heightAnchor.constraint(equalToConstant: 76),
        nextButton.widthAnchor.constraint(equalToConstant: 288),
        maleButton.heightAnchor.constraint(equalToConstant: 76),
        femaleButton.heightAnchor.constraint(equalToConstant: 76),
        maleButton.widthAnchor.constraint(equalTo: femaleButton.widthAnchor),
      ])
    }
  }
}
