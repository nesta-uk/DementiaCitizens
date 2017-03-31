//
//  RootController.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 24/03/2016.
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

open class DCRootController: UITabBarController {

  var calendar: DCCalendar?

  var actualViewControllers: [UIViewController] {
    if let viewControllers = viewControllers {
      return viewControllers.map { vc in
        if let vc = vc as? UINavigationController {
          return vc.topViewController!
        } else {
          return vc
        }
      }
    } else {
      return [UIViewController]()
    }
  }

  override open func awakeFromNib() {
    super.awakeFromNib()
    let vc = loadVC("toDoRootVC", bundleName: "ToDo")
    self.viewControllers?.append(vc)
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.calendar = DCApplication.sharedApplication.calendar

    for viewController in actualViewControllers {
      if let vc = viewController as? CalendarAware {
        vc.calendar = calendar
      }
    }
  }

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: NSNotification.Name(rawValue: "TodoListShouldRefresh"), object: nil)
    updateBadge()

    let state = ApplicationState.sharedInstance

    if !state.hasBeenShownConsent {
      let consent = Consent()
      let consentFlow = makeConsentFlow(consent) { (consented, participantType) in
        if consented {
          DCApplication.sharedApplication.events.log("consent:completed")
          state.enrollmentDate = Date()
          DCApplication.sharedApplication.study?.didEnrol(Date(), withCarer: consent.carer != nil)
          self.updateBadge()
        } else {
          state.disableEvents = true
        }
        state.participantType = participantType
        state.hasBeenShownConsent = true
        self.dismiss(animated: true, completion: nil)
      }
      self.present(consentFlow, animated: false, completion: {
         DCApplication.sharedApplication.events.log("consent:started")
      })

    }
  }

  func updateBadge() {
    let numberOfTasks = calendar!.tasksToDo().count
    if numberOfTasks == 0 {
      self.tabBar.items!.last?.badgeValue = nil
    } else {
      self.tabBar.items!.last?.badgeValue = String(numberOfTasks)
    }
  }
}
