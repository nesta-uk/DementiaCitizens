//
//  DCApplicationState.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 05/04/2016.
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

class ApplicationState {

  static let sharedInstance = ApplicationState()

  fileprivate enum Key: String {
    case HasBeenShownConsent = "DC.hasBeenShownConsent"
    case DeclinedEnrollment = "DC.didEnrolInResearch"
    case DisableEvents = "DC.sendEvents"
    case UserId = "DC.userId"
    case ParticipantType = "DC.participantType"
    case PrincipalName = "DC.principalName"
    case CarerName = "DC.carerName"
    case EnrollmentDate = "DC.enrollDate"
  }

  var participantType: DCParticipantType = .Neither {
    didSet {
      self.setString(.ParticipantType, participantType.rawValue)
    }
  }

  var userId: String? = nil {
    didSet {
      if let userId = userId {
        self.setString(.UserId, userId)
      } else {
        self.reset(.UserId)
      }
    }
  }

  var hasBeenShownConsent: Bool = false {
    didSet {
      self.set(.HasBeenShownConsent, hasBeenShownConsent)
    }
  }

  var enrollmentDate: Date? = nil {
    didSet {
      if let enrollmentDate = enrollmentDate {
        self.setDate(.EnrollmentDate, enrollmentDate)
      } else {
        self.reset(.EnrollmentDate)
      }
    }
  }

  var disableEvents: Bool = false {
    didSet {
      self.set(.DisableEvents, disableEvents)
    }
  }

  var declinedEnrolment: Bool = false {
    didSet {
      self.set(.DeclinedEnrollment, declinedEnrolment)
    }
  }

  var principalName: String? = nil {
    didSet {
      if let principalName = principalName {
        self.setString(.PrincipalName, principalName)
      }
    }
  }

  var carerName: String? = nil {
    didSet {
      if let carerName = carerName {
        self.setString(.CarerName, carerName)
      }
    }
  }

  fileprivate func reset(_ key: Key) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }

  fileprivate func setString(_ key: Key, _ value: String) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
  }

  fileprivate func setDate(_ key: Key, _ value: Date) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
  }

  fileprivate func getDate(_ key: Key) -> Date? {
    let defaults = UserDefaults.standard
    if let obj = defaults.object(forKey: key.rawValue),
          let date = obj as? Date {
      return date
    } else {
      return nil
    }
  }

  fileprivate func getString(_ key: Key) -> String? {
    let defaults = UserDefaults.standard
    return defaults.string(forKey: key.rawValue)
  }

  fileprivate func set(_ key: Key, _ value: Bool) {
    UserDefaults.standard.set(value, forKey: key.rawValue)
  }

  fileprivate func get(_ key: Key) -> Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: key.rawValue)
  }

  fileprivate init() {
    hasBeenShownConsent = get(.HasBeenShownConsent)
    declinedEnrolment = get(.DeclinedEnrollment)
    disableEvents = get(.DisableEvents)
    userId = getString(.UserId)
    enrollmentDate = getDate(.EnrollmentDate)
    if let savedParticipantType = getString(.ParticipantType),
           let participantType = DCParticipantType(rawValue: savedParticipantType) {
      self.participantType = participantType
    }
    principalName = getString(.PrincipalName)
    carerName = getString(.CarerName)
  }

}
