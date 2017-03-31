//
//  ConsentFlow.swift
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

class InformationScreen: FlowStep {

  var title: String
  var text: String
  var icon: String?
  var buttonTitle: String = "Next"

  var imageName: String?

  var links = [(link: String, linkText: String)]()

  var link: String?
  var linkText: String?

  var videoName: String?

  init(title: String, text: String) {
    self.title = title
    self.text = text
  }

  var controller: LearnMoreVC {

    let viewController = LearnMoreVC()

    viewController.title = title
    viewController.text = text
    if let imageName = imageName {
      viewController.image = UIImage.find(imageName)
    }
    viewController.buttonTitle = buttonTitle
    if let link = link, let linkText = linkText {
      viewController.link = (text: linkText, link: link)
    }

    if let videoName = videoName {
      viewController.videoName = videoName
    }

    return viewController
  }

  func asFlowStep() -> () -> Controller<()> {
    return {
      return Controller { completion in
        let controller = self.controller
        controller.completion = completion
        return controller
      }
    }
  }
}

func loadConsentScreens(_ name: String) -> [InformationScreen] {
  var screens = [InformationScreen]()

  if let url = Bundle.main.url(forResource: "Consent", withExtension: "json"),
    let data = try? Data(contentsOf: url),
    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers),
    let jsonResult = json as? NSDictionary,
    let screenArray = jsonResult[name] as? NSArray {

    for obj in (screenArray as? [[String: Any]])! {
      // swiftlint:disable force_cast
      let title = obj["title"] as! String
      let text = obj["text"] as! String
      // swiftlint:disable force_cast

      let screen = InformationScreen(title: title, text: text)

      if let imageName = obj["imageName"] as? String {
        screen.imageName = imageName
      }

      if let videoName = obj["videoName"] as? String {
        screen.videoName = videoName
      }

      if let linkText = obj["linkText"] as? String, let link = obj["link"] as? String {
        screen.link = link
        screen.linkText = linkText
      }

      screens.append(screen)
    }
  }
  return screens
}

func makeCancellableScreen(_ title: String,
                           text: String,
                           correctAnswer: YesNoAnswer,
                           controller: String = "YesNoVC") -> (Bool) -> Controller<(Bool)> {
  return { yes in
    return Controller { completion in
      if !yes {
        completion(false)
        return nil
      } else {
        let viewController = YesNoVC()
        viewController.title = title
        viewController.prompt = text
        viewController.correctAnswer = correctAnswer
        viewController.completion = completion
        return viewController
      }
    }
  }
}

func makeNameScreen(_ person: Person, prompt: String) -> () -> Controller<()> {
  return {
    return Controller { completion in
      let viewController = GetNameVC()
      viewController.title = "First Name"
      viewController.prompt = prompt
      viewController.completion = { name in
        person.name = name
        completion(nil)
      }
      return viewController
    }
  }
}

func makeCareHomeScreen(_ person: Person, prompt: String? = nil) -> () -> Controller<()> {
  return {
    return Controller { completion in
      let viewController = YesNoVC()
      viewController.title = "Where \(person.name!) Lives"
      if let prompt = prompt {
        viewController.prompt = prompt
      } else {
        viewController.prompt = "Does \(person.name!) live in a care home or other supervised care setting such as a hospital or a hospice?"
      }
      viewController.completion = { careHome in
        person.inCareHome = careHome
        completion(nil)
      }
      return viewController
    }
  }
}

func makeGenderScreen(_ person: Person, prompt: String? = nil) -> () -> Controller<()> {
  return {
    return Controller { completion in
      let viewController = GetGenderVC()
      viewController.title = "\(person.name!)'s Gender"
      if let prompt = prompt {
        viewController.prompt = prompt
      } else {
        viewController.prompt = "What is \(person.name!)'s gender?"
      }
      viewController.completion = { gender in
        person.gender = gender
        completion(nil)
      }
      return viewController
    }
  }
}

func makeAgeScreen(_ person: Person, prompt: String? = nil) -> () -> Controller<()> {
  return {
    return Controller { completion in
      let viewController = GetAgeVC()
      viewController.title = "\(person.name!)'s Age"
      if let prompt = prompt {
        viewController.prompt = prompt
      } else {
        viewController.prompt = "How old is \(person.name!)?"
      }
      viewController.completion = { age in
        person.age = age
        completion(nil)
      }
      return viewController
    }
  }
}

func makeParticipantChoiceScreen() -> Controller<DCParticipantType> {
  return Controller { completion in
    let viewController = GetParticipantTypeVC()
    viewController.title = "About You"
    viewController.completion = completion
    return viewController
  }
}

func makeConsentIntroductionScreen() -> Controller<()> {
  return Controller { completion in
    let viewController = OnboardViewController()
    viewController.completion = {
      completion(nil)
    }
    return viewController
  }
}

func makeConsentReview(_ consent: Consent) -> () -> Controller<(Bool)> {
  return {
    return Controller { completion in
      let viewController = ReviewConsentVC()
      if consent.carer == nil {
        viewController.title = "\(consent.principal.name!)'s Consent"
        ApplicationState.sharedInstance.principalName = consent.principal.name
      } else {
        viewController.title = "\(consent.principal.name!) and \(consent.carer!.name!)'s Consent"
        ApplicationState.sharedInstance.principalName = consent.principal.name
        ApplicationState.sharedInstance.carerName = consent.carer!.name
      }
      viewController.consent = consent
      viewController.completion = { consented in
        if consented {
          logConsentEvents(consent)
        }
        completion(consented)
      }
      return viewController
    }
  }
}

func makeOnboardingFlow() -> Flow<DCParticipantType> {
  return flow(makeConsentIntroductionScreen)
    >--> makeParticipantChoiceScreen
}

func makePairConsentFlow(_ consent: Consent, navigationController: UINavigationController) -> Flow<(Bool)> {

  return followOnFlow(navigationController,
                                 makeNameScreen(consent.principal,
                                  prompt: "What is the first name of the person with dementia in your pair?"))
    >--> makeGenderScreen(consent.principal)
    >--> makeAgeScreen(consent.principal)
    >--> makeCareHomeScreen(consent.principal)
    >--> makeNameScreen(consent.carer!, prompt: "What is the name of the other person in your pair?")
    >--> makeGenderScreen(consent.carer!)
    >--> makeAgeScreen(consent.carer!)
    >--> loadConsentScreens("consent_prime").map { $0 as FlowStep }
    >--> makeConsentReview(consent)
}

func makeSingleConsentFlow(_ consent: Consent, navigationController: UINavigationController) -> Flow<(Bool)> {

  return followOnFlow(navigationController,
                      makeNameScreen(consent.principal,
                        prompt: "What is your first name?"))
    >--> makeGenderScreen(consent.principal, prompt: "What is your gender?")
    >--> makeAgeScreen(consent.principal, prompt: "How old are you?")
    >--> makeCareHomeScreen(consent.principal, prompt: "Do you live in a care home or other supervised care setting such as a hospital or a hospice?")
    >--> loadConsentScreens("consent_prime").map { $0 as FlowStep }
    >--> makeConsentReview(consent)
}

func makeEligibilityFlow(_ navigationController: UINavigationController, participantType: DCParticipantType) -> Flow<(Bool)> {

  let elegibilityQuestions: [(String, String, YesNoAnswer)] = [
    ("Have you been diagnosed with dementia?", "Has one of the people in your pair been diagnosed with dementia?", .yes),
  ]

  func makeStep(_ idx: Int) -> (Bool) -> Controller<Bool> {
    let text = participantType == .Single ? elegibilityQuestions[idx].0 : elegibilityQuestions[idx].1
    return makeCancellableScreen("Study Eligibility", text: text, correctAnswer: elegibilityQuestions[idx].2)
  }

  return followOnFlowInput(navigationController, makeStep(0), input: true)
}

func ineligible(_ nav: UINavigationController, _ finalCompletion: @escaping (Bool, DCParticipantType) -> Void) {
  let ineligible = loadConsentScreens("ineligible").map { $0 as FlowStep }
  _ = followOnFlow(nav, screens: ineligible).makeController { (_, _) in
    finalCompletion(false, .Neither)
  }
}

func obtainConsent(_ nav: UINavigationController, participantType: DCParticipantType, consent: Consent, consentCompleted: @escaping (Bool?, UINavigationController) -> Void) {
  switch participantType {
  case .Single:
    _ = makeSingleConsentFlow(consent, navigationController: nav).makeController(consentCompleted)
  case .WithCarer:
    consent.carer = Person()
    _ = makePairConsentFlow(consent, navigationController: nav).makeController(consentCompleted)
  default:
    fatalError("Expected a participant type to be selected")  }
}

func makeConsentFlow(_ consent: Consent, finalCompletion: @escaping (Bool, DCParticipantType) -> Void) -> UIViewController {
  return makeOnboardingFlow().makeController { (obj, nav) in
    if let participantType = obj {

        let consentCompleted: (Bool?, UINavigationController) -> Void = { (consented, nav) in
          if let consented = consented, consented == true {

            let done = loadConsentScreens("signed_up").map { $0 as FlowStep }
            _ = followOnFlow(nav, screens: done).makeController { (_, _) in

              switch participantType {
              case .Single:
                MCSurvey.fromJSON("QOL-AD-S")!.present(false, nav: nav, completion: {
                  finalCompletion(true, participantType)
                })
              case .WithCarer:
                MCSurvey.fromJSON("QOL-AD")!.present(false, nav: nav, completion: {
                  MCSurvey.fromJSON("QOL-AD-C")!.present(false, nav: nav, completion: {
                    MCSurvey.fromJSON("Swemwbs")!.present(false, nav: nav, completion: {
                      finalCompletion(true, participantType)
                    })
                  })
                })
              default:
                break
              }
            }
          } else {
            DCApplication.sharedApplication.events.log("consent:not_confirmed")
            ineligible(nav, finalCompletion)
          }
        }

        let eligibilityCompleted: (Bool?, UINavigationController) -> Void = { (consented, nav) in
          if let consented = consented, consented == true {
            obtainConsent(nav, participantType: participantType, consent: consent, consentCompleted: consentCompleted)
          } else {
            DCApplication.sharedApplication.events.log("consent:ineligible")
            ineligible(nav, finalCompletion)
          }
        }

        _ = makeEligibilityFlow(nav, participantType: participantType).makeController(eligibilityCompleted)

    } else {
      fatalError("Expected a participant type to be selected")
    }
  }
}

func logConsentEvents(_ consent: Consent) {
  if let _ = consent.principal.name {
    DCApplication.sharedApplication.events.log("consent:provide_pwd_name")
  }
  if let gender = consent.principal.gender {
    DCApplication.sharedApplication.events.log("consent:provide_pwd_gender", params: ["gender": gender.rawValue])
  }
  if let age = consent.principal.age {
    DCApplication.sharedApplication.events.log("consent:provide_pwd_age", params: ["age": age])
  }

  DCApplication.sharedApplication.events.log("consent:provide_pwd_carehome", params: ["value": consent.principal.inCareHome])
  DCApplication.sharedApplication.events.log("consent:provide_consent")

  if let carer = consent.carer {
    if let _ = carer.name {
      DCApplication.sharedApplication.events.log("consent:provide_carer_name")
    }
    if let gender = carer.gender {
      DCApplication.sharedApplication.events.log("consent:provide_carer_gender", params: ["gender": gender.rawValue])
    }
    if let age = carer.age {
      DCApplication.sharedApplication.events.log("consent:provide_carer_age", params: ["age": age])
    }
  }

}
