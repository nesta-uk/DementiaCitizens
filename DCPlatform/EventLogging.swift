//
//  EventLogging.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 29/03/2016.
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

public protocol JSONScalar {}

extension JSONScalar {
  public func toJSON() -> String {
    return String(describing: self)
  }
}

extension String: JSONScalar {}
extension Double: JSONScalar {}
extension Float: JSONScalar {}
extension Bool: JSONScalar {}
extension Int: JSONScalar {}

struct Event {

  typealias UUID = String

  let uuid: UUID = Foundation.UUID().uuidString
  let date = Date()

  var type: String
  var params: [String:JSONScalar]?
}

extension Event: Hashable {
  var hashValue: Int {
    return uuid.hashValue
  }
}

func == (lhs: Event, rhs: Event) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

open class EventLog {

  var events: [Event]
  var eventQueue = DispatchQueue(label: "Event logging queue", attributes: [])
  var poster: EventPoster

  init(eventPoster: EventPoster) {
    events = EventLog.loadQueue()
    poster = eventPoster
    poster.log = self
  }

  open func log(_ type: String, params: [String:JSONScalar]? = nil) {
    if !ApplicationState.sharedInstance.disableEvents {
      logEvent(Event(type: type, params: params))
    }
  }

  fileprivate func logEvent(_ event: Event) {
    eventQueue.async {
      self.events.append(event)
      self.saveQueue()
      self.poster.postEvent(event)
    }
  }

  func eventLogged(_ event: Event) {
    eventQueue.async {
      if let index = self.events.index(of: event) {
        self.events.remove(at: index)
        self.saveQueue()
      }
    }
  }

  func sendEvents() {
    eventQueue.async {
      for event in self.events {
        self.poster.postEvent(event)
      }
    }
  }

  func saveQueue() {

  }

  static func loadQueue() -> [Event] {
    return []
  }
}

class EventPoster: NSObject, URLSessionTaskDelegate {

  var resultQueue: OperationQueue
  var session: Foundation.URLSession?
  weak var log: EventLog?
  let baseURL: String
  var taskToEvent = [URLSessionTask: Event]()
  var eventToTask = [Event: URLSessionTask]()
  var sharedSecret: String

  init(baseURL: String, sharedSecret: String) {
    self.baseURL = baseURL
    self.sharedSecret = sharedSecret
    resultQueue = OperationQueue()
    resultQueue.maxConcurrentOperationCount = 1
    super.init()
    session = defaultSession()
  }

  func digestForRequest(_ request: URLRequest) -> String? {
    if let string = String(data:request.httpBody!, encoding: String.Encoding.utf8) {
      return string.hmac(.sha1, key: sharedSecret)
    } else {
      return nil
    }
  }

  func defaultSession() -> Foundation.URLSession {
     return Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: resultQueue)
  }

  func put(_ params: [String:AnyObject], url: String) -> URLSessionTask? {
    if session == nil {
      session = defaultSession()
    }

    if let url = URL(string: url),
           let session = session {
      do {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        try request.httpBody = JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.setValue(digestForRequest(request), forHTTPHeaderField: "X-DC-HMAC")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return session.dataTask(with: request)
      } catch {
        return nil
      }
    } else {
      return nil
    }
  }

  func removeEventTask(_ task: URLSessionTask) {
    if let event = taskToEvent[task] {
      taskToEvent.removeValue(forKey: task)
      eventToTask.removeValue(forKey: event)
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      print("Error from URLSession: \(error)")
    } else {
      resultQueue.addOperation(BlockOperation {
        if let response = task.response as? HTTPURLResponse,
                  let event = self.taskToEvent[task] {
          if response.statusCode >= 200 && response.statusCode < 300 {
            self.log?.eventLogged(event)
          } else {
            print("Received \(response.statusCode) from server \(self.baseURL)")
          }
        }
        self.removeEventTask(task)
      })
    }
  }

  @discardableResult func postEvent(_ event: Event) -> Bool {
    if eventToTask[event] != nil {
      return false
    }

    var jsonParams = [String: String]()
    if let params = event.params {
      for (k, v) in params {
        jsonParams[k] = v.toJSON()
      }
    }

    let params: [String: AnyObject] = [
      "user_id": userID as AnyObject,
      "type": event.type as AnyObject,
      "time": String(event.date.timeIntervalSince1970) as AnyObject,
      "data": jsonParams as AnyObject,
    ]

    if let task = put(params, url: "\(baseURL)/events/\(event.uuid)") {
      eventToTask[event] = task
      taskToEvent[task] = event
      task.resume()
    }

    return true
  }
}

class EventPoller {
  var timer: Timer?
  let log: EventLog

  init(log: EventLog) {
    self.log = log
    self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(30), target: self, selector: #selector(self.onTick), userInfo: nil, repeats: true)
  }

  @objc func onTick() {
    log.sendEvents()
  }
}
