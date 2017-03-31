//
//  Study.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 13/07/2016.
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

public typealias DCStudyDuration = (unit: NSCalendar.Unit, value: Int)

@objc open class DCStudy: NSObject {

  let duration: DCStudyDuration
  let endMessage: String

  public init(duration: DCStudyDuration, endMessage: String) {
    self.duration = duration
    self.endMessage = endMessage
  }

  func endpoint(_ start: Date) -> Date {
    let calendarDate = Foundation.Calendar.current
    return (calendarDate as NSCalendar).date(byAdding: duration.unit, value: duration.value, to: start, options: NSCalendar.Options()) ?? Date()
  }

  func midpoint(_ start: Date) -> Date {
    let calendarDate = Foundation.Calendar.current
    return (calendarDate as NSCalendar).date(byAdding: duration.unit, value: duration.value/2, to: start, options: NSCalendar.Options()) ?? Date()
  }

  func hasFinished(_ start: Date) -> Bool {
    let now = Date()
    return (endpoint(start) as NSDate).earlierDate(now) == endpoint(start)
  }

  func didEnrol(_ start: Date, withCarer: Bool) {
    let app = DCApplication.sharedApplication
    let state = ApplicationState.sharedInstance

    if let principalName = state.principalName {
      let title = "\(principalName)'s Quality of Life Questionnaire"

      if withCarer {
        app.schedule(DCTaskType.QOL, date: midpoint(start), title: title, icon: "qol")
        app.schedule(DCTaskType.QOL, date: endpoint(start), title: title, icon: "qol")
        if let carerName = state.carerName {
          let qol_title = "\(carerName)'s Quality of Life Questionnaire (about \(principalName))"
          let web_title = "\(carerName)'s Wellbeing Questionnaire"

          app.schedule(DCTaskType.QOLCarer, date: midpoint(start), title: qol_title, icon: "qol-c")
          app.schedule(DCTaskType.WBCarer, date: midpoint(start), title: web_title, icon: "wellbeing")

          app.schedule(DCTaskType.QOLCarer, date: endpoint(start), title: qol_title, icon: "qol-c")
          app.schedule(DCTaskType.WBCarer, date: endpoint(start), title: web_title, icon: "wellbeing")
        }
      } else {
        app.schedule(DCTaskType.QOLSingle, date: midpoint(start), title: title, icon: "qol")
        app.schedule(DCTaskType.QOLSingle, date: endpoint(start), title: title, icon: "qol")
      }
    }
  }
}
