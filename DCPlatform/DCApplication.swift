//
//  DCApplication.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 21/06/2016.
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
import UserNotifications

open class DCApplication {

  open var name: String!
  open static let sharedApplication = DCApplication()

  open var participantType: DCParticipantType {
    return self.applicationState?.participantType ?? .Neither
  }

  var events: EventLog!
  var poller: EventPoller?
  var calendar: DCCalendar?
  var study: DCStudy?
  var applicationState: ApplicationState?

  var studyFinished: Bool {
    if let state = self.applicationState,
            let date = state.enrollmentDate,
           let study = self.study {
      return study.hasFinished(date)
    } else {
      return false
    }
  }

  init() {
    self.calendar = DCCalendar.loadOrCreateCalendar()
  }

  // swiftlint:disable function_parameter_count
  open func application(_ application: UIApplication,
                        didLaunchWithName name: String,
                        launchOptions: [AnyHashable: Any]?,
                        baseURL: String,
                        sharedSecret: String,
                        study: DCStudy) {
    self.name = name
    self.study = study
    self.applicationState = ApplicationState.sharedInstance
    self.events = EventLog(eventPoster: EventPoster(baseURL: baseURL, sharedSecret: sharedSecret))
    self.poller =  EventPoller(log: self.events)
    // swiftlint:enable function_parameter_count

    events.log("app:launch_app")

    if ProcessInfo.processInfo.arguments.contains("DCTESTING") {
      print("LAUNCHED UNDER TESTING")
      applicationState?.disableEvents = true
      applicationState?.hasBeenShownConsent = false
      applicationState?.enrollmentDate = nil
    }

    Reminders(application: application).schedule()

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (_, _) in })

    if studyFinished && calendar?.tasks.count == 0 {
      applicationState?.disableEvents = true
    }
  }

  open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    calendar?.reorderNotifications()
  }

  open func applicationDidBecomeActive(_ application: UIApplication) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
  }

  open func applicationWillResignActive(_ application: UIApplication) {
    if let toDoList = calendar?.tasksToDo() {
      application.applicationIconBadgeNumber = toDoList.count
    }
  }

  open func log(_ type: String, params: [String:JSONScalar]? = nil) {
    events.log(type, params: params)
  }

  open func schedule(_ task: DCTaskType, date: Date, title: String, icon: String, reminder: Date? = nil, force: Bool = false) {
    if !studyFinished || force {
      let task = Task(taskType: task)
      task.dueDate = date
      task.listTitle = title
      task.iconName = icon
      if reminder != nil {
        task.reminderDate = reminder
      }
      self.calendar?.addTask(task)
    }
  }
}
