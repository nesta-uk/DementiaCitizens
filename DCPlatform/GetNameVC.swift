//
//  GetNameVC.swift
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

class GetNameVC: DCViewController, UITextFieldDelegate {

  var calmColor: UIColor?
  var name: String?
  var completion: ((String) -> Void)?
  var prompt: String?

  var nameField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.nameField.delegate = self
    calmColor = self.nameField.backgroundColor
    if let name = name {
      self.nameField.text = name
    }
  }

  @IBAction func handleNext(_ sender: AnyObject) {
    nameField.resignFirstResponder()

    if let text = nameField.text, !text.isEmpty {
      completion?(text)
    } else {
      makeTextFieldAngry()
      nameField.becomeFirstResponder()
    }
  }

  func makeTextFieldAngry() {
    nameField.backgroundColor = UIColor.yellow
    UIView.animate(withDuration: 0.7, animations: { [unowned self] in
      if let field = self.nameField, let calmColor = self.calmColor {
        field.backgroundColor = calmColor
      }
      })
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let text = nameField.text, !text.isEmpty {
      nameField.resignFirstResponder()
      return true
    } else {
      makeTextFieldAngry()
      return false
    }
  }

  override func loadView() {
    super.loadView()

    if let prompt = prompt {
      nameField = ConsentTextField()
      nameField.placeholder = "Your First Name"
      nameField.translatesAutoresizingMaskIntoConstraints = false
      nameField.setContentHuggingPriority(251, for: .horizontal)
      nameField.setContentHuggingPriority(251, for: .vertical)
      nameField.textAlignment = .center
      nameField.adjustsFontSizeToFitWidth = false
      nameField.font = UIFont.dcInput
      nameField.minimumFontSize = 17
      nameField.returnKeyType = .done
      nameField.backgroundColor = UIColor.dementiaCitizensBlue()
      nameField.font = UIFont.dcInput
      nameField.autocapitalizationType = .words

      let nameCaption = "Your name won’t be shared in the study and is only used to personalise this app."
      let inputs = createInputWithCaptionView(prompt, inputs: nameField, caption: nameCaption)

      let nextButton = createNextButton("Next", image:"next", action: #selector(GetNameVC.handleNext(_:)))

      let container = ConsentContainerView(topView: inputs, bottomView: nextButton)

      self.view.addSubview(container)

      NSLayoutConstraint.activate([
        nextButton.heightAnchor.constraint(equalToConstant: 76),
        nextButton.widthAnchor.constraint(equalToConstant: 288),
      ])
    }
  }
}
