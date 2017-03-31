//
//  SessionFeedbackFlow.swift
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

enum LickertAnswer {
  case unanswered
  case answered(value: Int)
}

class QuestionAndResponse {
  let text: String
  var code: String
  var likertScale: (String, String)
  var answer: LickertAnswer
  var personToAnswer: PersonToAnswer

  init(text: String, code: String, likertScale: (String, String), personToAnswer: PersonToAnswer = .principal) {
    self.text = text
    self.code = code
    self.likertScale = likertScale
    self.answer = .unanswered
    self.personToAnswer = personToAnswer
  }

  var complete: Bool {
    switch answer {
    case .unanswered:
      return false
    default:
      return true
    }
  }
}

class PostSessionFeedback {
  var title: String
  var shortTitle: String
  var prompt: String
  var guidance: String
  var questions: [QuestionAndResponse]

  init(questions: [QuestionAndResponse], title: String, shortTitle: String, prompt: String, guidance: String) {
    self.questions = questions
    self.title = title
    self.shortTitle = shortTitle
    self.prompt = prompt
    self.guidance = guidance
  }
}

class PostSessionSurvey: DCSurvey {
  func present(_ canCancel: Bool, nav: UINavigationController? = nil, completion: (() -> Void)? = nil) -> UIViewController {
    return makeSessionFeedbackFlow(canCancel, completion: completion)
  }
}

func postSessionFeedback(_ filename: String) -> PostSessionFeedback? {

  if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
    let data = try? Data(contentsOf: url),
    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers),
    let jsonResult = json as? NSDictionary,
    let prompt = jsonResult["prompt"] as? String,
    let title = jsonResult["title"] as? String,
    let shortTitle = jsonResult["shortTitle"] as? String,
    let guidance = jsonResult["guidance"] as? String,
    let questions = jsonResult["questions"] as? NSArray {

    let feedbackQuestions = PostSessionFeedback(questions: [], title: title, shortTitle: shortTitle, prompt: prompt, guidance: guidance)

    for q in (questions as? [[String: Any]])! {
      // swiftlint:disable force_cast
      let code = q["code"] as! String
      let text = q["text"] as! String
      let likertScale = (q["left-label"] as! String, q["right-label"] as! String)
      let person = q["person"] as! String
      let personToAnswer: PersonToAnswer = ("principal" == person) ? .principal : .carer
      // swiftlint:enable force_cast

      feedbackQuestions.questions.append(QuestionAndResponse(text: text, code: code, likertScale: likertScale, personToAnswer: personToAnswer))
    }
    return feedbackQuestions
  } else {
    return nil
  }
}

func makeFeedbackIntroScreen(_ canCancel: Bool, feedback: PostSessionFeedback)-> () -> Controller<()> {
  return {
    return Controller { completion in
      let viewController = SurveyIntroVC(canCancel: canCancel)
      viewController.introduction = feedback.guidance
      viewController.currentSurveyTitle = feedback.title
      viewController.buttonTitle = "Start"
      viewController.title = feedback.shortTitle
      viewController.imageName = "feedback"
      viewController.completion = { completion(nil) }
      return viewController
    }
  }
}

func makeFeedbackInstructionsScreen(_ feedback: PostSessionFeedback)-> () -> Controller<()> {
  return {
    return Controller { completion in
      let viewController = SurveyInstructionVC()
      viewController.introduction = feedback.prompt
      viewController.buttonTitle = "Okay"
      viewController.completion = { completion(nil) }
      return viewController
    }
  }
}

func makeSessionChoiceScreen() -> Controller<DCSessionType> {
  return Controller { completion in
    let viewController = GetSessionTypeVC()
    viewController.completion = completion
    return viewController
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

func logFeedbackAnswer(_ question: QuestionAndResponse) {
  switch question.answer {
  case .answered(let value):
    let params = ["code": question.code as JSONScalar, "answer": value as JSONScalar]
    DCApplication.sharedApplication.events.log("survey:answer", params: params)
  default:
    break
  }
}

func makeFeedbackControllerFunction(_ idx: Int, feedback: PostSessionFeedback) -> () -> Controller<()> {
  let questionIdx = idx
  return {
    return Controller { completion in
      let vc = SessionFeedbackVC()
      vc.feedback = feedback
      vc.questionIdx = questionIdx
      vc.completion = { survey in
        logFeedbackAnswer(feedback.questions[questionIdx])
        completion(nil)
      }
      return vc
    }
  }
}

func makeSessionFeedbackFlow(_ canCancel: Bool, completion: (() -> Void)? = nil) -> UIViewController {

  guard let singleFeedback = postSessionFeedback("Feedback"),
            let withCarerFeedback = postSessionFeedback("Feedback-C") else {
      fatalError("JSON Parsing errors")
  }

  func makePairFeedbackIntro(_ feedback: PostSessionFeedback) -> Flow<DCSessionType> {
    return flow(makeFeedbackIntroScreen(canCancel, feedback: feedback))
      >--> makeFeedbackInstructionsScreen(feedback)
      >--> makeSessionChoiceScreen
  }

  func makeSingleFeedbackIntro(_ feedback: PostSessionFeedback) -> Flow<()> {
    return flow(makeFeedbackIntroScreen(canCancel, feedback: feedback))
      >--> makeFeedbackInstructionsScreen(feedback)
  }

  func makeFeedback(_ feedback: PostSessionFeedback, _ navigationController: UINavigationController) -> Flow<()> {
    var flow = followOnFlow(navigationController, makeFeedbackControllerFunction(0, feedback: feedback))
    for questionIndex in 1..<feedback.questions.count {
      flow = flow >--> makeFeedbackControllerFunction(questionIndex, feedback: feedback)
    }
    return flow
  }

  let participantType = ApplicationState.sharedInstance.participantType

  switch participantType {

  case .Single:
    return makeSingleFeedbackIntro(singleFeedback).makeController { (_, nav) in
      _ = makeFeedback(singleFeedback, nav).makeController { (_, _) in
        _ = followOnFlow(nav, makeEndScreen()).makeController { (_, _) in
          DCApplication.sharedApplication.events.log("session_feedback:ended")
          completion?()
        }
      }
    }

  case .WithCarer:
    return makePairFeedbackIntro(withCarerFeedback).makeController { (obj, nav) in
      if let sessionType = obj {

        let feedbackCompleted: (()?, UINavigationController) -> Void = { (completed, nav) in
          _ = followOnFlow(nav, makeEndScreen()).makeController { (_, _) in
            DCApplication.sharedApplication.events.log("session_feedback:ended")
            completion?()
          }
        }

        switch sessionType {
        case .Single:
          _ = makeFeedback(singleFeedback, nav).makeController(feedbackCompleted)
        case .WithCarer:
          _ = makeFeedback(withCarerFeedback, nav).makeController(feedbackCompleted)
        }

      } else {
        fatalError("Expected a participant type to be selected")
      }
    }

  case .Neither:
    fatalError("Expected a participant type to be selected")
  }

}
