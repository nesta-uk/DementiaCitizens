//
//  GetParticipantTypeVC.swift
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

public enum DCParticipantType: String {
  case Single
  case WithCarer
  case Neither
}

class GetParticipantTypeVC: DCViewController {

    var completion: ((DCParticipantType) -> Void)?

    @IBAction func handleDualConsent(_ sender: AnyObject) {
        completion?(.WithCarer)
    }

    @IBAction func handleSingleConsent(_ sender: AnyObject) {
      completion?(.Single)
    }

  override func loadView() {
    super.loadView()
    let image = UIImage.find("consent-participant-type")
    let topView = createImageWithText("You can use this app as a pair or by yourself. How will you use this app?", image: image)

    let single = createNextButton("By myself", image: "single", action: #selector(GetParticipantTypeVC.handleSingleConsent(_:)))
    let dual = createNextButton("As a pair", image: "with-carer", action: #selector(GetParticipantTypeVC.handleDualConsent(_:)))
    let bottomView = UIStackView(arrangedSubviews: [dual, single])

    bottomView.translatesAutoresizingMaskIntoConstraints = false
    bottomView.alignment = .center
    bottomView.distribution = .fillEqually
    bottomView.spacing = 13
    bottomView.axis = .vertical

    let container = ConsentContainerView(topView: topView, bottomView: bottomView)

    self.view.addSubview(container)

    NSLayoutConstraint.activate([
      single.heightAnchor.constraint(equalToConstant: 76),
      single.widthAnchor.constraint(equalToConstant: 288),
      dual.heightAnchor.constraint(equalTo: single.heightAnchor),
      dual.widthAnchor.constraint(equalTo: single.widthAnchor),
    ])

  }
}
