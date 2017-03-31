//
//  ReviewConsent.swift
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

extension Date {
  var formatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/M/yyyy"
    return formatter.string(from: self)
  }
}

open class ConsentCheckBoxButton: UIButton {

}

class ConsentStepView: UIView {

  var title: UILabel = {
    let title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = UIFont.dcSubHeader
    title.textColor = UIColor.dementiaCitizensBlack()
    title.numberOfLines = 0
    return title
  }()

  var text: UILabel = {
    let text = UILabel()
    text.translatesAutoresizingMaskIntoConstraints = false
    text.font = UIFont.dcBodySmall
    text.textColor = UIColor.dementiaCitizensBlack()
    text.numberOfLines = 0
    return text
  }()

  var border: UIView = {
    let border = UIView()
    border.backgroundColor = UIColor(white: 0.70, alpha: 1.0)
    border.translatesAutoresizingMaskIntoConstraints = false
    return border
  }()

  var consentButton: UIButton = {
    let button = ChoiceButton()
    button.titleLabel?.font = UIFont.dcBodySmall
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  var carerConsentButton: UIButton = {
    let button = ChoiceButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.alignment = .fill
    stackView.spacing = 16.0
    return stackView
  }()

  let titleStack: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.spacing = 16.0
    return stackView
  }()

  var icon: UIImageView = {
    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFit
    return iconView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  init(titleString: String, textString: String, principal: Person, carer: Person?) {
    super.init(frame: CGRect.zero)
    self.backgroundColor = UIColor.dementiaCitizensBackground()

    self.title.text = titleString
    self.text.text = textString

    titleStack.addArrangedSubview(icon)
    titleStack.addArrangedSubview(title)

    NSLayoutConstraint.activate([
      icon.heightAnchor.constraint(equalToConstant: 50.0),
      icon.widthAnchor.constraint(equalToConstant: 50.0),
    ])

    stackView.addArrangedSubview(titleStack)
    stackView.addArrangedSubview(text)
    stackView.addArrangedSubview(consentButton)

    if let carer = carer {
      carerConsentButton.setTitle("\(carer.name!) agrees", for: UIControlState())
      carerConsentButton.setTitle("\(carer.name!) agreed", for: .selected)

      consentButton.setTitle("\(principal.name!) agrees", for: UIControlState())
      consentButton.setTitle("\(principal.name!) agreed", for: .selected)

      stackView.addArrangedSubview(carerConsentButton)

    } else {
      consentButton.setTitle("Agree", for: UIControlState())
      consentButton.setTitle("Agreed", for: .selected)
    }

    self.addSubview(stackView)
    self.addSubview(self.border)

    let margins = self.layoutMarginsGuide
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 16.0),
      stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 16.0),
      margins.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16.0),
      margins.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24.0),
      border.heightAnchor.constraint(equalToConstant: 6.0),
      border.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      border.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      border.widthAnchor.constraint(equalTo: self.widthAnchor),
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func addArrangedSubview(_ view: UIView) {
    stackView.insertArrangedSubview(view, at: 2)
  }
}

func loadConsentReviewSteps() -> [InformationScreen] {
  var screens = [InformationScreen]()

  if let url = Bundle.main.url(forResource: "ConsentReview", withExtension: "json"),
    let data = try? Data(contentsOf: url),
    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers),
    let screenArray = json as? NSArray {

    for obj in (screenArray as? [[String:Any]])! {
      // swiftlint:disable force_cast
      let title = obj["title"] as! String
      let text = obj["text"] as! String
      // swiftlint:disable force_cast
      let icon = obj["icon"] as? String

      let screen = InformationScreen(title: title, text: text)

      screen.icon = icon

      if let links = obj["links"] as? [[String:Any]] {
        for linkobj in links {
          if let linkText = linkobj["linkText"] as? String, let link = linkobj["link"] as? String {
            screen.links.append((link: link, linkText: linkText))
          }
        }
      }
      screens.append(screen)
    }
  }
  return screens
}

class ReviewConsentVC: DCViewController {

  var reviewSteps: [InformationScreen] = loadConsentReviewSteps()
  var stackOfReviewBoxes: UIStackView!
  var carerConsent: UIStackView!
  var continueButton: UIButton!
  var scrollView: UIScrollView!

  var carerLabel: UILabel!
  var carerInstructions: UILabel!

  var principalLabel: UILabel!
  var principalInstructions: UILabel!

  var completion: ((Bool) -> Void)?

  var consent: Consent?

  func getButtonsInView(_ view: UIView) -> [UIButton] {
    var buttonArray = [UIButton]()

    for subview in view.subviews {
      buttonArray += getButtonsInView(subview)

      if let subview = subview as? ChoiceButton {
        buttonArray.append(subview)
      }
    }

    return buttonArray
  }

  func linkClicked(_ sender: UIButton) {
    if let button = sender as? LinkButton,
      let url = button.url {
      UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
  }

  var buttons: [UIButton]!

  var currentStepIndex: Int = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.dementiaCitizensDarkBackground()
    showStep()

    let image = UIImage.find("cancel-consent")
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(cancelled))
    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.dementiaCitizensBlue()
  }

  func showStep() {
    insertReviewStep(currentStepIndex)

    buttons = getButtonsInView(stackOfReviewBoxes)
    for button in buttons {
      if !button.isSelected {
        button.addTarget(self, action: #selector(ReviewConsentVC.buttonSelected(_:)), for: .touchUpInside)
      }
    }
  }

  var currentHeight: CGFloat = 0

  func buttonSelected(_ sender: UIButton) {
    if !sender.isSelected {
      sender.isSelected = true
      let selectedButtons = buttons.filter({ button -> Bool in
        return button.isSelected
      })
      let allticked = (selectedButtons.count == buttons.count)
      if continueButton != nil {
        continueButton.isEnabled = allticked
      }

      if allticked {
        currentStepIndex += 1
        if currentStepIndex == reviewSteps.count {
          insertFinalButtons()
        } else {
          showStep()
        }
        currentHeight = scrollView.contentSize.height
        self.perform(#selector(ReviewConsentVC.scrollToBottom), with: nil, afterDelay: 0.1)
      }

    }
  }

  func scrollToBottom() {
    let offset = min(scrollView.contentSize.height - scrollView.bounds.size.height, currentHeight - 16)
    if offset > 0 {
      scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  @IBAction func continuePressed(_ sender: AnyObject) {
    self.completion?(true)
  }

  @IBAction func cancelled(_ sender: AnyObject) {
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

  func insertReviewStep(_ currentStepIndex: Int) {
    guard let consent = consent else { return }

    let screen = reviewSteps[currentStepIndex]

    let (title, text, icon) = (screen.title, screen.text, screen.icon)
    let view = ConsentStepView(titleString: title, textString: text, principal: consent.principal, carer: consent.carer)

    for screenLink in screen.links {
      if let url = URL(string: screenLink.link) {
        let button = LinkButton(type: .system)

        let title = NSAttributedString(string: screenLink.linkText, attributes:[
          NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
          NSForegroundColorAttributeName: UIColor.dementiaCitizensBlue(),
          NSFontAttributeName: UIFont.dcBodySmall,
        ])
        button.setAttributedTitle(title, for: UIControlState())
        button.url = url
        button.addTarget(self, action: #selector(ReviewConsentVC.linkClicked(_:)), for: .touchUpInside)
        view.addArrangedSubview(button)
      }
    }

    view.icon.image = UIImage.find(icon!)

    view.alpha = 0
    stackOfReviewBoxes.insertArrangedSubview(view, at: currentStepIndex)
    UIView.animate(withDuration: 0.6, animations: {
      view.alpha = 1.0
    })
  }

  func insertFinalButtons() {
    guard let consent = consent else { return }

    let continueText = consent.carer == nil ? "I consent" :
                                               "We consent"

    let cancelText = consent.carer == nil ? "I don't consent" : "We don't consent"

    continueButton = createNextButton(continueText, image: "finish", action: #selector(ReviewConsentVC.continuePressed(_:)), font: UIFont.dcMediumButtonText)
    let cancelButton = createNextButton(cancelText, image: "cancel-consent", action: #selector(ReviewConsentVC.cancelled(_:)), font: UIFont.dcMediumButtonText)

    let buttons = UIStackView(arrangedSubviews: [continueButton, cancelButton])
    buttons.axis = .vertical
    buttons.distribution = .fill
    buttons.alignment = .fill
    buttons.spacing = 8
    buttons.translatesAutoresizingMaskIntoConstraints = false

    stackOfReviewBoxes.addArrangedSubview(buttons)

    NSLayoutConstraint.activate([
      continueButton.heightAnchor.constraint(equalToConstant: 66),
      cancelButton.heightAnchor.constraint(equalToConstant: 66),
    ])
  }

  override func loadView() {
    super.loadView()

    stackOfReviewBoxes = UIStackView()
    stackOfReviewBoxes.translatesAutoresizingMaskIntoConstraints = false
    stackOfReviewBoxes.axis = .vertical
    stackOfReviewBoxes.distribution = .fill
    stackOfReviewBoxes.alignment = .fill
    stackOfReviewBoxes.spacing = 16

    scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false

    scrollView.addSubview(stackOfReviewBoxes)

    self.view.addSubview(scrollView)

    let margins = self.view.layoutMarginsGuide
    NSLayoutConstraint.activate([
      margins.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      scrollView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
      scrollView.topAnchor.constraint(equalTo: margins.topAnchor),
      margins.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

      stackOfReviewBoxes.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      scrollView.trailingAnchor.constraint(equalTo: stackOfReviewBoxes.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: stackOfReviewBoxes.bottomAnchor, constant: 16),
      stackOfReviewBoxes.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
      stackOfReviewBoxes.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
    ])
  }
}
