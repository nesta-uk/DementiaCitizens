//
//  Reminders.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 29/06/2016.
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

class Reminders {

  let reminderType = "AppReminder"

  weak var application: UIApplication!

  init(application: UIApplication) {
    self.application = application
  }

  func schedule() {
    clear()

    let interval = TimeInterval(60 * 60 * 24 * 3) // 3 days
    var date = Date()

    let name = DCApplication.sharedApplication.name
    let alert = "It's been a couple of days since you last used \(name)."

    for _ in 0..<3 {
      date = date.addingTimeInterval(interval)

      let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
      let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

      let content = UNMutableNotificationContent()
      content.body = alert
      content.sound = UNNotificationSound.default()
      content.userInfo = ["Type": reminderType]

      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

  }

  func clear() {
    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { reminderRequests in
      for reminder in reminderRequests {
        let userInfo = reminder.content.userInfo
        let identifier = reminder.identifier
        if let type = userInfo["Type"] as? String {
          if type == self.reminderType {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
          }
        }
      }
    })
  }

}
