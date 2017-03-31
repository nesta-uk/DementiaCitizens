//
//  Calendar.swift
//  DCPlatform
//
//  Created by James Godwin on 19/05/2016.
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
import UIKit
import UserNotifications

@objc protocol CalendarAware {
  var calendar: DCCalendar? { get set }
}

protocol DCSurvey {
  func present(_ canCancel: Bool, nav: UINavigationController?, completion: (() -> Void)?) -> UIViewController
}

public enum DCTaskType: String {
  case QOL
  case QOLSingle
  case QOLCarer
  case WBCarer
  case Feedback

  func getViewController(_ canCancel: Bool, completion: @escaping (() -> Void)) -> UIViewController {
    switch self {
    case .QOL: return MCSurvey.fromJSON("QOL-AD")!.present(canCancel, completion: completion)
    case .QOLCarer: return MCSurvey.fromJSON("QOL-AD-C")!.present(canCancel, completion: completion)
    case .QOLSingle: return MCSurvey.fromJSON("QOL-AD-S")!.present(canCancel, completion: completion)
    case .WBCarer: return MCSurvey.fromJSON("Swemwbs")!.present(canCancel, completion: completion)
    case .Feedback: return makeSessionFeedbackFlow(canCancel, completion: completion)
    }
  }

  var titleForNotification: String {

    let appName = DCApplication.sharedApplication.name != nil ? DCApplication.sharedApplication.name! : ""

    switch self {
    case .QOL:
      if let principalName = ApplicationState.sharedInstance.principalName {
        return "\(principalName), your \(appName) Quality of Life Questionnaire is ready to answer."
      } else {
        return "Your \(appName) Quality of Life Questionnaire is ready to answer."
      }
    case .QOLSingle:
      if let principalName = ApplicationState.sharedInstance.principalName {
        return "\(principalName), your \(appName) Quality of Life Questionnaire is ready to answer."
      } else {
        return "Your \(appName) Quality of Life Questionnaire is ready to answer."
      }
    case .Feedback:
      return "We have some questions to ask you about your recent experience of \(appName)."
    case .QOLCarer:
      if let carerName = ApplicationState.sharedInstance.carerName,
        let principalName = ApplicationState.sharedInstance.principalName {
        return "\(carerName), your \(appName) Quality of Life Questionnaire about \(principalName) is ready to answer."
      } else {
        return "Your \(appName) Quality of Life Questionnaire is ready to answer."
      }
    case .WBCarer:
      if let carerName = ApplicationState.sharedInstance.carerName {
        return "\(carerName), your \(appName) Wellbeing Questionnaire is ready to answer."
      } else {
        return "Your \(appName) Wellbeing Questionnaire is ready to answer."
      }
    }
  }

  var numberOfQuestions: String {
    switch self {
    case .QOL: return "13"
    case .QOLSingle: return "12"
    case .Feedback:
      switch DCApplication.sharedApplication.participantType {
      case .WithCarer:
        return "4-10"
      default:
        return "4"
      }
    case .QOLCarer: return "13"
    case .WBCarer: return "7"
    }
  }

  var onlyOneInCalendar: Bool {
    return self == .Feedback
  }

}

@objc protocol TaskWatcher {
  func taskDidComplete(_ task: Task)
}

@objc class Task: NSObject {
  var dueDate = Date()
  var listTitle = ""
  var iconName = ""
  var completedDate: Date?
  var reminderDate: Date?
  var completed: Bool {
    return completedDate != nil
  }
  var taskType: DCTaskType
  var UUID = Foundation.UUID().uuidString

  weak var delegate: TaskWatcher?

  init (taskType: DCTaskType) {
    self.taskType = taskType
  }

  func getViewController(_ onComplete: @escaping () -> Void) -> UIViewController {
    return taskType.getViewController(true) {
      self.completedDate = Date()
      self.delegate?.taskDidComplete(self)
      onComplete()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    // swiftlint:disable force_cast
    let taskType = aDecoder.decodeObject(forKey: "taskType") as! String
    if let taskType =  DCTaskType(rawValue: taskType) {
      self.taskType = taskType
      self.dueDate = aDecoder.decodeObject(forKey: "dueDate") as! Date
      self.listTitle = aDecoder.decodeObject(forKey: "listTitle") as! String
      self.iconName = aDecoder.decodeObject(forKey: "iconName") as! String
      if aDecoder.containsValue(forKey: "completed_date") {
        self.completedDate = aDecoder.decodeObject(forKey: "completed_date") as? Date
      }
      if aDecoder.containsValue(forKey: "reminder_date") {
        self.reminderDate = aDecoder.decodeObject(forKey: "reminder_date") as? Date
      }
      self.UUID = aDecoder.decodeObject(forKey: "uuid") as! String
    } else {
      return nil
    }
    // swiftlint:enable force_cast
  }

  func encodeWithCoder(_ aCoder: NSCoder) {
    aCoder.encode(dueDate, forKey: "dueDate")
    aCoder.encode(listTitle, forKey: "listTitle")
    aCoder.encode(iconName, forKey: "iconName")
    if completedDate != nil {
      aCoder.encode(completedDate, forKey: "completed_date")
    }
    if reminderDate != nil {
      aCoder.encode(reminderDate, forKey: "reminder_date")
    }
    aCoder.encode(taskType.rawValue, forKey: "taskType")
    aCoder.encode(UUID, forKey: "uuid")
  }
}

@objc class DCCalendar: NSObject, NSCoding, TaskWatcher {

  var tasks = [Task]()

  static var fileurl: URL? {
    return FileManager.pathForFileInDocumentsDir("calendar4.obj")
  }

  static func loadOrCreateCalendar() -> DCCalendar {

    if let path = fileurl?.path,
      let calendar = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? DCCalendar {
      return calendar
    } else {
      return DCCalendar()
    }
  }

  func save() {
    if let path = DCCalendar.fileurl?.path {
      NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
  }

  func tasksToDo() -> [Task] {
    return tasks.filter { (task) -> Bool in
      return !task.completed && (task.dueDate.timeIntervalSinceNow.sign == .minus)
    }
  }

  func taskDidComplete(_ task: Task) {
    cancelNotificationForTask(task)
    reorderNotifications()
    self.save()
  }

  override init() {
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init()
    // swiftlint:disable force_cast
    self.tasks = aDecoder.decodeObject(forKey: "tasks") as! [Task]
    for task in self.tasks {
      task.delegate = self
    }
    // swiftlint:enable force_cast
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(tasks, forKey: "tasks")
  }

  func hasTaskOfType(_ type: DCTaskType) -> Bool {
    let tasksOfType = tasks.filter { task in
      return task.taskType == type && task.completed == false
    }
    return tasksOfType.count > 0
  }

  func hasCompletedTaskToday(_ type: DCTaskType) -> Bool {
    let calendar = Foundation.Calendar.current

    let tasksOfType = tasks.filter { task in
      if let completedDate = task.completedDate {
        return task.taskType == type && calendar.isDateInToday(completedDate)
      } else {
        return false
      }
    }
    return tasksOfType.count > 0
  }

  func allCalendarNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {

    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
      let filtered = notifications.filter({ n in
        let info = n.content.userInfo
        if let type = info["Type"] as? String {
          return type == "CalendarReminder"
        } else {
          return false
        }
      })
      completion(filtered)
    })
  }

  func inDateOrder(_ notificationRequests: [UNNotificationRequest]) -> [UNNotificationRequest] {

    return notificationRequests.sorted { (a, b) in
      if let a_trigger = a.trigger as? UNCalendarNotificationTrigger,
        let b_trigger = b.trigger as? UNCalendarNotificationTrigger,
        let a_date = a_trigger.nextTriggerDate(),
        let b_date = b_trigger.nextTriggerDate() {

        let earliest = (a_date as NSDate).earlierDate(b_date)
        return earliest == a_trigger.nextTriggerDate()
      } else {
        return false
      }
    }
  }

  func createNotificationRequest(_ date: Date, body: String, uuid: String, type: String, badge: NSNumber?) -> UNNotificationRequest {

    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let content = UNMutableNotificationContent()
    content.body = body
    content.sound = UNNotificationSound.default()
    content.userInfo = ["title": body, "UUID": uuid, "Type": type]
    if badge != nil {
      content.badge = badge
    }
    return UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
  }

  func cancelNotificationForTask(_ task: Task) {

    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
      for notification in notifications {
        let identifier = notification.identifier
        if notification.content.userInfo["UUID"] as? String == task.UUID {
          UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        }
      }
    })
  }

  func reorderNotifications() {

    allCalendarNotificationRequests(completion: { notifications in

      let scheduledNotifications = self.inDateOrder(notifications)
      let startNumber = self.tasksToDo().count

      for notification in scheduledNotifications {
        let identifier = notification.identifier
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
      }

      for (badgeNumber, notification) in scheduledNotifications.enumerated() {
        let info = notification.content.userInfo
        if let uuid = info["UUID"] as? String,
          let trigger = notification.trigger as? UNCalendarNotificationTrigger,
          let triggerDate = trigger.nextTriggerDate() {

          let newBadgeNumber = badgeNumber + startNumber + 1
          let newNotification = self.createNotificationRequest(triggerDate,
                                                               body: notification.content.body,
                                                               uuid: uuid,
                                                               type: "CalendarReminder",
                                                               badge: newBadgeNumber as NSNumber)

          UNUserNotificationCenter.current().add(newNotification, withCompletionHandler: nil)
        }
      }
    })
  }

  func addTask(_ task: Task) {
    if task.taskType.onlyOneInCalendar && hasTaskOfType(task.taskType) {
      return
    } else if task.taskType.onlyOneInCalendar && hasCompletedTaskToday(task.taskType) {
      return
    } else {
      tasks.insert(task, at: 0)
      task.delegate = self
      self.save()

      let title = task.taskType.titleForNotification
      let notification = createNotificationRequest(task.dueDate, body: title, uuid: task.UUID, type: "CalendarReminder", badge: nil)

      if task.reminderDate != nil {
        let title = task.taskType.titleForNotification
        let notification = createNotificationRequest(task.reminderDate!, body: title, uuid: task.UUID, type: "DelayedReminder", badge: nil)
        UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
      }

      UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
      reorderNotifications()
    }
  }
}
