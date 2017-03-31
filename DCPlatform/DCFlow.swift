//
//  DCFlow.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 08/03/2016.
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

protocol FlowStep {
  func asFlowStep() -> () -> Controller<()>
}

struct Controller<Result> {
  let makeController: (_ onComplete: @escaping (Result?) -> Void) -> UIViewController?
}

struct Flow<Result> {
  let makeController: (_ onComplete: @escaping (Result?, UINavigationController) -> Void) -> UINavigationController
}

func push<Result>(_ controller: Controller<Result>, _ nav: UINavigationController, _ flowOnComplete: @escaping (Result?, UINavigationController) -> Void) {
  let onComplete = { result in flowOnComplete(result, nav) }
  if let vc = controller.makeController(onComplete) {
    nav.pushViewController(vc, animated: true)
  }
}

func flow<Input, Result>(_ controllerFunction: @escaping (Input) -> Controller<Result>, input: Input) -> Flow<Result> {
  return Flow { flowOnComplete in
    let nav = NavigationController()
    push(controllerFunction(input), nav, flowOnComplete)
    return nav
  }
}

func flow<Result>(_ controllerFunction: @escaping () -> Controller<Result> ) -> Flow<Result> {
  return Flow { flowOnComplete in
    let nav = NavigationController()
    push(controllerFunction(), nav, flowOnComplete)
    return nav
  }
}

func followOnFlow<Result>(_ navigationController: UINavigationController, _ controllerFunction: @escaping () -> Controller<Result> ) -> Flow<Result> {
  return Flow { flowOnComplete in
    push(controllerFunction(), navigationController, flowOnComplete)
    return navigationController
  }
}

func followOnFlow(_ navigationController: UINavigationController, screens: [FlowStep] ) -> Flow<()> {
  let controllerFunction = screens.first!
  var flow =  Flow<()> { flowOnComplete in
    push(controllerFunction.asFlowStep()(), navigationController, flowOnComplete)
    return navigationController
  }
  for screen in screens.dropFirst() {
    flow = flow >--> screen.asFlowStep()
  }
  return flow
}

func followOnFlowInput<Input, Result>(_ navigationController: UINavigationController, _ controllerFunction: @escaping (Input) -> Controller<Result>, input: Input ) -> Flow<Result> {
  return Flow { flowOnComplete in
    push(controllerFunction(input), navigationController, flowOnComplete)
    return navigationController
  }
}

infix operator >--> : LogicalConjunctionPrecedence

func >--> (upstreamFlow: Flow<()>, screens: [FlowStep]) -> Flow<()> {
  var flow = upstreamFlow
  for screen in screens {
    flow = flow >--> screen.asFlowStep()
  }
  return flow
}

func >--> <L, R>(upstreamFlow: Flow<L>, controllerFunction: @escaping (L) -> Controller<R>) -> Flow<R> {
  return Flow { flowOnComplete in
    return upstreamFlow.makeController({ input, nav in
      if input == nil {
        flowOnComplete(nil, nav)
      } else {
        push(controllerFunction(input!), nav, flowOnComplete)
      }
    })
  }
}

func >--> <R>(upstreamFlow: Flow<()>, controllerFunction: @escaping () -> Controller<R>) -> Flow<R> {
  return Flow { flowOnComplete in
    return upstreamFlow.makeController({ _, nav in
      push(controllerFunction(), nav, flowOnComplete)
    })
  }
}
