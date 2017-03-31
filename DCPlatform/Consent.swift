//
//  Consent.swift
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

import Foundation

func ensureUserId() -> String {
  let app = ApplicationState.sharedInstance
  if app.userId == nil {
    app.userId = UUID().uuidString
  }
  return app.userId!
}

let userID = ensureUserId()

enum Gender: String {
  case Male = "M"
  case Female = "F"
}

class Person: NSObject {
  var name: String?
  var age: Int?
  var gender: Gender?
  var inCareHome: Bool = false
}

struct ConsentConfirmation {
  let consenter: Person
  // usually the person who consented, but sometimes the carer
  let consentedBy: Person
  let consentDate: Date

  init(consenter: Person, consentedBy: Person? = nil) {
    self.consenter = consenter
    self.consentedBy = consentedBy ?? consenter
    self.consentDate = Date()
  }
}

class Consent {
  var principal: Person
  var carer: Person?

  var consents: [Person : ConsentConfirmation] = [:]

  init() {
    self.principal = Person()
  }

  var isProxy: Bool {
    return true
  }

  var complete: Bool {
    if let carer = carer {
      return consents[principal] != nil && consents[carer] != nil
    } else {
      return consents[principal] != nil
    }
  }
}
