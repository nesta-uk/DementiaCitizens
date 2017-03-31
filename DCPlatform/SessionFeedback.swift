//
//  SessionFeedback.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 16/03/2016.
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

class SessionFeedbackVC: DCViewController {

  var nextButton: UIButton!

  var feedback: PostSessionFeedback!
  var questionIdx: Int = 0

  var buttons: [UIButton]?

  var completion: ((PostSessionFeedback) -> Void)?

  var rating: Int = 0 {
    didSet {
      if let buttons = buttons {
        for (indx, button) in buttons.enumerated() {
          if indx + 1 == rating {
            button.isSelected = true
          } else {
            button.isSelected = false
          }
        }
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let backButton = UIImage.find("back-button" )
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButton, style: .plain, target: self, action: #selector(SessionFeedbackVC.dismiss(_:)))
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.dementiaCitizensBlue()
  }

  func dismiss(_ sender: AnyObject) {
    _ = self.navigationController?.popViewController(animated: true)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let questionResponse = feedback.questions[questionIdx]

    switch questionResponse.answer {
    case .answered(let value):
      rating = value
    default:
      rating = 0
    }

    self.title = "Question \(questionIdx+1) of \(feedback.questions.count)"
  }

  @IBAction func nextTapped(_ sender: AnyObject) {
    completion?(feedback)
  }

  @IBAction func buttonPressed(_ sender: AnyObject) {
    if let button = sender as? UIButton,
      let buttons = buttons,
      let buttonIndex = buttons.index(of: button) {
      rating = buttonIndex + 1
      let questionResponse = feedback.questions[questionIdx]
      questionResponse.answer = .answered(value: rating)
      nextButton.isEnabled = questionResponse.complete
    }
  }

  override func loadView() {
    super.loadView()

    func createFaceButton(_ idx: Int) -> UIButton {
      let button = UIButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setImage(UIImage.find("lickert-\(idx)"), for: UIControlState())
      button.setImage(UIImage.find("lickert-\(idx)-selected"), for: .selected)
      button.setImage(UIImage.find("lickert-\(idx)-selected"), for: .highlighted)

      button.addConstraint(button.heightAnchor.constraint(equalToConstant: 52))
      button.addConstraint(button.widthAnchor.constraint(equalToConstant: 52))
      button.addTarget(self, action: #selector(SessionFeedbackVC.buttonPressed(_:)), for: .touchUpInside)
      return button
    }

    buttons = [
      createFaceButton(0),
      createFaceButton(1),
      createFaceButton(2),
      createFaceButton(3),
      createFaceButton(4),
    ]

    let buttonStrip = UIStackView(arrangedSubviews: buttons!)
    buttonStrip.axis = .horizontal
    buttonStrip.distribution = .equalSpacing
    buttonStrip.alignment = .center
    buttonStrip.spacing = 8
    let questionResponse = feedback.questions[questionIdx]

    let leftLabel = createInstructionLabel(questionResponse.likertScale.0)
    leftLabel.textAlignment = .left
    leftLabel.textColor = UIColor.dementiaCitizensBlue()
    let rightLabel = createInstructionLabel(questionResponse.likertScale.1)
    rightLabel.textAlignment = .right
    rightLabel.textColor = UIColor.dementiaCitizensBlue()

    let labels = UIStackView(arrangedSubviews: [leftLabel, rightLabel])

    let faces = UIStackView(arrangedSubviews: [buttonStrip, labels])
    faces.axis = .vertical
    faces.distribution = .equalSpacing
    faces.translatesAutoresizingMaskIntoConstraints = false

    let promptView = UIView()
    promptView.translatesAutoresizingMaskIntoConstraints = false

    var name = ""

    switch feedback.questions[questionIdx].personToAnswer {
    case .principal:
      if let principalName = ApplicationState.sharedInstance.principalName {
        name = principalName
      }
    case .carer:
      if let carerName = ApplicationState.sharedInstance.carerName {
        name = carerName
      }
    }

    let inputs = createFeedbackInputView(questionResponse.text, inputs: faces, name: name)

    nextButton = createNextButton("Next", image: "next", action: #selector(SessionFeedbackVC.nextTapped(_:)))
    nextButton.isEnabled = questionResponse.complete
    if questionIdx == feedback.questions.count - 1 {
      nextButton.setTitle("Done", for: UIControlState())
    }

    let container = ConsentContainerView(topView: inputs, bottomView: nextButton)

    self.view.addSubview(container)

    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalToConstant: 76),
      nextButton.widthAnchor.constraint(equalToConstant: 288),
    ])
  }
}
