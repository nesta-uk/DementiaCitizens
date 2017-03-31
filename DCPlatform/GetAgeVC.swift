//
//  GetAgeVC.swift
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

class GetAgeVC: DCViewController, UIPickerViewDataSource, UIPickerViewDelegate {

  var agePicker: UIPickerView!

  let maximumAge = 120
  let minimumAge = 18

  var completion: ((Int) -> Void)?

  var prompt: String!

  override func viewDidLoad() {
    super.viewDidLoad()
    agePicker.dataSource = self
    agePicker.delegate = self
    agePicker.selectRow((maximumAge-minimumAge)/2, inComponent: 0, animated: false)
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return maximumAge - minimumAge + 1
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "\(row + minimumAge)"
  }

  @IBAction func handleNext(_ sender: UIButton) {
    completion?(agePicker.selectedRow(inComponent: 0) + minimumAge)
  }

  override func loadView() {
    super.loadView()

    if let prompt = prompt {
      agePicker = UIPickerView()

      let inputs = createInputView(prompt, inputs: agePicker)

      let nextButton = createNextButton("Next", image: "next", action: #selector(GetAgeVC.handleNext(_:)))

      let container = ConsentContainerView(topView: inputs, bottomView: nextButton)

      self.view.addSubview(container)

      NSLayoutConstraint.activate([
        nextButton.heightAnchor.constraint(equalToConstant: 76),
        nextButton.widthAnchor.constraint(equalToConstant: 288),
      ])
    }
  }
}
