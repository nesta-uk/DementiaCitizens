//
//  MultipleAnswerSurvey.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 01/07/2016.
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

enum MCAnswer {
  case answer(index: Int)
  case unanswered
}

enum PersonToAnswer {
  case principal
  case carer
}

typealias MCOptions = [(text: String, value: String)]

class MCQuestion {
  let text: String
  let code: String
  let options: MCOptions

  var answer: MCAnswer

  init(text: String, code: String, options: MCOptions) {
    self.text = text
    self.code = code
    self.options = options
    self.answer = MCAnswer.unanswered
  }

  func log() {
    switch answer {
      case .answer(let value):
        let answer = options[value].value
        let params = ["code": code as JSONScalar, "answer": answer as JSONScalar]
        DCApplication.sharedApplication.events.log("survey:answer", params: params)
      default:
        break
    }
  }
}

func interpolateString(_ text: String) -> String {
  var myString = text
  do {
    if let name = ApplicationState.sharedInstance.principalName {
      let matchName = try NSRegularExpression(pattern: "\\[(the person with dementia)\\]", options: .caseInsensitive)
      myString = matchName.stringByReplacingMatches(in: myString, options: [], range: NSRange(location: 0, length: myString.characters.count), withTemplate: name)
    }

    let matchBrackets = try NSRegularExpression(pattern: "\\[(.*?)\\]", options: .caseInsensitive)
    myString = matchBrackets.stringByReplacingMatches(in: myString, options: [], range: NSRange(location: 0, length: myString.characters.count), withTemplate: "$1")

  } catch {}

  return myString
}

class MCSurvey: DCSurvey {
  var title: String
  var icon: String
  var shortTitle: String
  var prompt: String
  var guidance: String
  var questions: [MCQuestion]
  var personToAnswer: PersonToAnswer

  init(title: String, icon: String, prompt: String, guidance: String, shortTitle: String, questions: [MCQuestion]) {
    self.title = title
    self.icon = icon
    self.prompt = prompt
    self.shortTitle = shortTitle
    self.guidance = guidance
    self.questions = questions
    self.personToAnswer = .principal
  }

  class func fromJSON(_ filename: String) -> MCSurvey? {
    if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers),

      let jsonResult = json as? NSDictionary,
      let prompt = jsonResult["prompt"] as? String,
      let title = jsonResult["title"] as? String,
      let icon = jsonResult["icon"] as? String,
      let options = jsonResult["options"] as? NSArray,
      let questions = jsonResult["questions"] as? NSArray,
      let guidance = jsonResult["guidance"] as? String,
      let personToAnswer = jsonResult["personToAnswer"] as? String {

      let shortTitle = jsonResult["short_title"] as? String ?? title

      var surveyOptions = MCOptions()
      for option in options {
        if let option = option as? NSDictionary,
               let text = option["text"] as? String,
              let value = option["value"] as? String {
          surveyOptions.append((text: text, value: value))
        }
      }

      var surveyQuestions = [MCQuestion]()
      for q in (questions as? [[String: Any]])! {
        if let code = q["code"] as? String,
               let text = q["text"] as? String {
          surveyQuestions.append(MCQuestion(text: interpolateString(text), code: code, options: surveyOptions))
        }
      }

      let survey = MCSurvey(title: title, icon: icon, prompt: prompt, guidance: guidance, shortTitle: shortTitle, questions: surveyQuestions)

      if personToAnswer == "Principal" {
        survey.personToAnswer = .principal
      } else if personToAnswer == "Carer" {
        survey.personToAnswer = .carer
      }

      return survey

    } else {
      return nil
    }
  }

  @discardableResult func present(_ canCancel: Bool, nav: UINavigationController? = nil, completion: (() -> Void)? = nil) -> UIViewController {
    return makeSurveyFlow(self, canCancel: canCancel, nav: nav, completion: completion)
  }

  var questionCountForDisplay: String {
    return "\(questions.count)"
  }
}

class MCSurveyVC: DCViewController {

  var survey: MCSurvey!
  var questionIdx: Int = 0
  var buttons = [UIButton]()

  var completion: ((MCSurvey) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    let backButton = UIImage.find("back-button" )
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButton, style: .plain, target: self, action: #selector(MCSurveyVC.dismiss(_:)))
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.dementiaCitizensBlue()
  }

  func dismiss(_ sender: AnyObject) {
    _ = self.navigationController?.popViewController(animated: true)
  }

  @IBAction func buttonPressed(_ sender: UIButton) {
    let question = survey.questions[questionIdx]
    question.answer = .answer(index: sender.tag)
    sender.isSelected = true
    for button in buttons {
      if button.tag != sender.tag {
        button.isSelected = false
      }
    }
    completion?(survey)
  }

  override func loadView() {
    super.loadView()

    title = "Question \(questionIdx+1) of \(survey.questions.count)"

    let surveyQuestion = survey.questions[questionIdx]
    let question = createInstructionLabel(surveyQuestion.text)
    question.font = UIFont.dcBodyLarge

    let labels = UIStackView(arrangedSubviews: [question])
    labels.axis = .vertical
    labels.distribution = .fill
    labels.alignment = .center
    labels.spacing = 16
    labels.translatesAutoresizingMaskIntoConstraints = false

    let buttonHeight: CGFloat = 50

    buttons = surveyQuestion.options.enumerated().map { (idx, option) -> UIButton in
      let button = createChoiceButton(option.text, action: #selector(MCSurveyVC.buttonPressed(_:)))
      button.tag = idx
      button.addConstraint(button.heightAnchor.constraint(equalToConstant: buttonHeight))
      button.titleLabel?.font = UIFont.dcBodyLarge

      return button
    }

    let buttonssv = UIStackView(arrangedSubviews: buttons)
    buttonssv.axis = .vertical
    buttonssv.distribution = .equalSpacing
    buttonssv.spacing = 12
    buttonssv.translatesAutoresizingMaskIntoConstraints = false

    let containerView = ConsentContainerView(topView: labels, bottomView: buttonssv)

    self.view.addSubview(containerView)

    let buttonFrameHeight = CGFloat(buttons.count) * buttonHeight + labels.spacing * CGFloat(buttons.count - 1)

    NSLayoutConstraint.activate([
      buttonssv.heightAnchor.constraint(equalToConstant: buttonFrameHeight),
    ])
  }
}

func makeSurveyFlow(_ survey: MCSurvey, canCancel: Bool, nav: UINavigationController? = nil, completion: (() -> Void)? = nil) -> UIViewController {
  let count = survey.questions.count

  var qolFlow: Flow<MCSurvey>?

  func makeIntroScreen()-> () -> Controller<()> {
    return {
      return Controller { completion in
        let viewController = SurveyIntroVC(canCancel: canCancel)
        viewController.introduction = survey.guidance
        viewController.currentSurveyTitle = survey.title
        viewController.personToAnswer = survey.personToAnswer
        viewController.buttonTitle = "Start"
        viewController.imageName = survey.icon
        viewController.title = survey.shortTitle
        viewController.completion = { completion(nil) }
        return viewController
      }
    }
  }

  func makeInstructionsScreen()-> () -> Controller<()> {
    return {
      return Controller { completion in
        let viewController = SurveyInstructionVC()
        viewController.introduction = survey.prompt
        viewController.buttonTitle = "Okay"
        viewController.title = "How to Complete"
        viewController.completion = { completion(nil) }
        return viewController
      }
    }
  }

  func makeEndScreen()-> () -> Controller<()> {
    return {
      return Controller { completion in
        let viewController = SurveyEndVC()
        viewController.introduction = "Thank you for taking part in dementia research! Your data will be used to try to improve dementia care."
        viewController.currentSurveyTitle = "Complete!"
        viewController.buttonTitle = "Finish"
        viewController.title = "Questionnaire complete"
        viewController.completion = { completion(nil) }
        return viewController
      }
    }
  }

  func makeControllerFunction(_ idx: Int) -> () -> Controller<()> {
    let questionIdx = idx
    return { feedback in
      return Controller { completion in
        let vc = MCSurveyVC()
        vc.survey = survey
        vc.questionIdx = questionIdx
        vc.completion = { survey in
          survey.questions[questionIdx].log()
          completion(nil)
        }
        return vc
      }
    }
  }

  var a_flow = nav == nil ? flow(makeIntroScreen()) : followOnFlow(nav!, makeIntroScreen())
  a_flow = a_flow >--> makeInstructionsScreen()
  for questionIndex in 0 ..< count {
    a_flow = a_flow >--> makeControllerFunction(questionIndex)
  }
  a_flow = a_flow >--> makeEndScreen()

  return a_flow.makeController { (_, _) in
    completion?()
  }
}
