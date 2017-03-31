//
//  ContainerView.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 22/06/2016.
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

class ConsentContainerView: UIView {

  var constraintsLoaded: Bool = false

  var topView: UIView
  var bottomView: UIView

  var compactWidthConstraints = [NSLayoutConstraint]()
  var regularWidthConstraints = [NSLayoutConstraint]()
  var compactWidthCompactHeightConstraints = [NSLayoutConstraint]()

  override func updateConstraints() {
    if !constraintsLoaded {
      constraintsLoaded = true

      if let superview = self.superview {
        let margins = superview.layoutMarginsGuide
        NSLayoutConstraint.activate([
          self.topAnchor.constraint(equalTo: margins.topAnchor, constant: 24),
          self.bottomAnchor.constraint(equalTo: margins.bottomAnchor),

          bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
          bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
          bottomView.centerXAnchor.constraint(equalTo: self.centerXAnchor),

          topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
          topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
          topView.topAnchor.constraint(equalTo: self.topAnchor),
          ])

        compactWidthConstraints = [
          self.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
          self.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        ]

        compactWidthCompactHeightConstraints = [
          self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
          self.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
        ]

        regularWidthConstraints = [
          self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
          self.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
        ]
      }
    }

    let wideLandscape = (self.traitCollection.horizontalSizeClass == .regular)
    let shortLandscape = (self.traitCollection.horizontalSizeClass == .compact && self.traitCollection.verticalSizeClass == .compact)

    NSLayoutConstraint.deactivate(compactWidthConstraints)
    NSLayoutConstraint.deactivate(compactWidthCompactHeightConstraints)
    NSLayoutConstraint.deactivate(regularWidthConstraints)

    if wideLandscape {            // iPAD all orientations + 6S landscape
        NSLayoutConstraint.activate(regularWidthConstraints)
    } else if shortLandscape {    // iPhones in landscape
        NSLayoutConstraint.activate(compactWidthCompactHeightConstraints)
    } else {                      // iphone in portrait
        NSLayoutConstraint.activate(compactWidthConstraints)
    }

    super.updateConstraints()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    self.setNeedsUpdateConstraints()
  }

  init(topView: UIView, bottomView: UIView) {
    self.topView = topView
    self.bottomView = bottomView
    super.init(frame: CGRect.zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(topView)
    self.addSubview(bottomView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
