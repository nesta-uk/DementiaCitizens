//
//  SurveyIntroVC.swift
//  DCPlatform
//
//  Created by James Godwin on 24/05/2016.
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

class SurveyIntroVC: DCViewController {

  var completion: (() -> Void)?

  var introduction: String!
  var currentSurveyTitle: String!
  var buttonTitle: String = "Next"
  var personToAnswer = PersonToAnswer.principal
  var imageName = "placeholder"

  var canCancel: Bool = false

  init(canCancel: Bool = false) {
    super.init(nibName: nil, bundle: nil)
    self.canCancel = canCancel
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @IBAction func nextTapped(_ sender: AnyObject) {
    completion?()
  }

  @IBAction func whyTapped(_ sender: AnyObject) {
    let popUpVC = ConsentPopOver()
    popUpVC.modalPresentationStyle = .overCurrentContext
    self.present(popUpVC, animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if canCancel {
    let image = UIImage.find("cancel-consent" )
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(cancelled))
      self.navigationItem.rightBarButtonItem?.tintColor = UIColor.dementiaCitizensBlue()
    }
  }

  func cancelled(_ sender: UIButton) {
    navigationController?.dismiss(animated: true, completion: nil)
  }

  override func loadView() {
    super.loadView()

    self.navigationController?.navigationBar.barTintColor = UIColor.dementiaCitizensBackground()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.dementiaCitizensBlack()]

    var views = [UIView]()

    if let image = UIImage.find(imageName) {
      let imageView = createHeaderImage(image)
      views.append(imageView)
    }

    switch personToAnswer {
      case .principal:
        if let principalName = ApplicationState.sharedInstance.principalName {
          let headerText = createHeaderLabel("\(currentSurveyTitle!) for \(principalName)")
          views.append(headerText)
        }
      case .carer:
        if let carerName = ApplicationState.sharedInstance.carerName {
          let headerText = createHeaderLabel("\(currentSurveyTitle!) for \(carerName)")
          views.append(headerText)
        }
    }

    let instructionTextView = createInstructionLabel(introduction)
    views.append(instructionTextView)

    let consentButton = UIButton()
    consentButton.setTitle("Why am I being asked these questions?", for: UIControlState())
    consentButton.titleLabel?.font = UIFont.dcBody
    consentButton.setTitleColor(UIColor.dementiaCitizensBlue(), for: UIControlState())
    consentButton.addTarget(self, action: #selector(SurveyIntroVC.whyTapped(_:)), for: .touchUpInside)
    consentButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    consentButton.titleLabel?.textAlignment = NSTextAlignment.center
    views.append(consentButton)

    let topView = createTitleTopStackView(views)

    let nextButton = createNextButton(buttonTitle, image: "next", action: #selector(SurveyIntroVC.nextTapped(_:)))

    let container = ConsentContainerView(topView: topView, bottomView: nextButton)
    self.view.addSubview(container)

    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalToConstant: 76),
      nextButton.widthAnchor.constraint(equalToConstant: 288),
    ])

    consentButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8)

  }
}

class SurveyEndVC: DCViewController {

  var completion: (() -> Void)?

  var introduction: String!
  var currentSurveyTitle: String!
  var buttonTitle: String = "Next"

  @IBAction func nextTapped(_ sender: AnyObject) {
    completion?()
  }

  override func loadView() {
    super.loadView()

    self.navigationController?.navigationBar.barTintColor = UIColor.dementiaCitizensBackground()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.dementiaCitizensBlack()]

    var views = [UIView]()

    if let image = UIImage.find("done") {
      let imageView = createHeaderImage(image)
      views.append(imageView)
    }

    let instructionTextView = createInstructionLabel(introduction)
    views.append(instructionTextView)

    let topView = createTopStackView(views)

    let nextButton = createNextButton(buttonTitle, image: "finish", action: #selector(SurveyEndVC.nextTapped(_:)))

    let container = ConsentContainerView(topView: topView, bottomView: nextButton)
    self.view.addSubview(container)

    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalToConstant: 76),
      nextButton.widthAnchor.constraint(equalToConstant: 288),
    ])

  }
}

class SurveyInstructionVC: DCViewController {

  var completion: (() -> Void)?

  var introduction: String!
  var buttonTitle: String = "Next"
  var imageName: String = "instruction"

  @IBAction func nextTapped(_ sender: AnyObject) {
    completion?()
  }

  override func loadView() {
    super.loadView()

    var views = [UIView]()

    if let image = UIImage.find(imageName) {
      let imageView = createHeaderImage(image)
      views.append(imageView)
    }

    let instructionTextView = createInstructionLabel(introduction)
    views.append(instructionTextView)

    let topView = createTopStackView(views)

    let nextButton = createNextButton(buttonTitle, image:"next", action: #selector(SurveyIntroVC.nextTapped(_:)))

    let container = ConsentContainerView(topView: topView, bottomView: nextButton)
    self.view.addSubview(container)

    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalToConstant: 76),
      nextButton.widthAnchor.constraint(equalToConstant: 288),
    ])
  }
}

class ConsentPopOver: DCViewController {
  var tap: UIGestureRecognizer!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.clear

    let margins = self.view.layoutMarginsGuide

    let popView = UIView()
    popView.translatesAutoresizingMaskIntoConstraints = false
    popView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    popView.isOpaque = false

    self.view.addSubview(popView)

    NSLayoutConstraint.activate([
      popView.topAnchor.constraint(equalTo: margins.topAnchor),
      popView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
      popView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      popView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ])

    let dialogView = UIView()
    dialogView.translatesAutoresizingMaskIntoConstraints = false
    dialogView.backgroundColor = UIColor.dementiaCitizensBackground()
    dialogView.layer.cornerRadius = 5
    dialogView.layer.masksToBounds = true

    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 30

    let consentLabel = UILabel()
    consentLabel.translatesAutoresizingMaskIntoConstraints = false
    let appName = DCApplication.sharedApplication.name
    consentLabel.text = "You are participating in the Dementia Citizens \(appName) Study. The information in these questionnaires is collected by Dementia Citizens and used in the study, to try to improve dementia care. You are free to leave the study at anytime, just stop using the app."
    consentLabel.lineBreakMode = .byWordWrapping
    consentLabel.numberOfLines = 0
    consentLabel.textColor = UIColor.dementiaCitizensBlack()

    let okayButton = createChoiceButton("Close", action: #selector(ConsentPopOver.handleOkay(_:)))
    okayButton.translatesAutoresizingMaskIntoConstraints = false
    okayButton.titleLabel?.font = UIFont.dcBody

    stackView.addArrangedSubview(consentLabel)
    stackView.addArrangedSubview(okayButton)

    dialogView.addSubview(stackView)
    popView.addSubview(dialogView)

    NSLayoutConstraint.activate([
      dialogView.leadingAnchor.constraint(equalTo: popView.leadingAnchor, constant: 16),
      dialogView.trailingAnchor.constraint(equalTo: popView.trailingAnchor, constant: -16),
      dialogView.centerYAnchor.constraint(equalTo: popView.centerYAnchor),
      stackView.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -16),
      stackView.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -16),
    ])

    tap = UITapGestureRecognizer(target: self, action: #selector(ConsentPopOver.handleTap(_:)))
    self.view.addGestureRecognizer(tap)
  }

  func handleTap(_ sender: UIGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func handleOkay(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
}
