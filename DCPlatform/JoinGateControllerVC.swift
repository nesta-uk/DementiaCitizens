//
//  JoinGateControllerVC.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 23/06/2016.
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

class JoinGateController: DCViewController {
  var completion: ((Bool) -> Void)?

  @IBAction func yesButtonTapped(_ sender: UIButton) {
    completion?(true)
  }

  @IBAction func noButtonTapped(_ sender: UIButton) {
    let message = "Are you sure you want to quit the study sign up? If you quit now, " +
      "we won’t be able to use your information for dementia research. " +
    "There is no way to rejoin once you quit."
    let check = UIAlertController(title: "Quit study?", message: message, preferredStyle: .alert)
    let no = UIAlertAction(title: "No, carry on", style: .cancel) { _ in }
    let yes = UIAlertAction(title: "Yes, quit joining", style: .default) { _ in
      self.completion?(false)
    }
    check.addAction(no)
    check.addAction(yes)
    self.present(check, animated: true, completion: nil)
  }

  override func loadView() {
    super.loadView()
    let image = UIImage.find("consent-participant-type")
    let topView = createImageWithText("To check your eligibility to take part in the research," +
      " we want to ask you a few questions. If you're taking part in a pair," +
      " make sure both people in your pair are present before answering these.", image: image)

    let yesButton = createNextButton("Check eligibility", image: "next", action: #selector(JoinGateController.yesButtonTapped(_:)))
    let noButton = createNextButton("Don't take part in the study", image: "next", action: #selector(JoinGateController.noButtonTapped(_:)))

    let bottomView = UIStackView(arrangedSubviews: [yesButton, noButton])

    bottomView.translatesAutoresizingMaskIntoConstraints = false
    bottomView.alignment = .center
    bottomView.distribution = .fillEqually
    bottomView.spacing = 13
    bottomView.axis = .vertical

    let container = ConsentContainerView(topView: topView, bottomView: bottomView)

    self.view.addSubview(container)

    NSLayoutConstraint.activate([
      yesButton.heightAnchor.constraint(equalToConstant: 76),
      yesButton.widthAnchor.constraint(equalToConstant: 288),
      noButton.heightAnchor.constraint(equalTo: yesButton.heightAnchor),
      noButton.widthAnchor.constraint(equalTo: yesButton.widthAnchor),
    ])
  }
}
