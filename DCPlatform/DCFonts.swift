//
//  DCFonts.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 27/06/2016.
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

extension UIFont {

  func bumpFontSize(_ scale: CGFloat = 1.4) -> UIFont {
    let descriptor = self.fontDescriptor
    let newDescriptor = descriptor.withSize(descriptor.pointSize * scale)
    return UIFont(descriptor: newDescriptor, size: 0.0)
  }

  class var dcBody: UIFont { return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).bumpFontSize() }
  class var dcBodySmall: UIFont { return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).bumpFontSize(1.2) }
  class var dcBodyLarge: UIFont { return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).bumpFontSize(1.8) }
  class var dcHeader: UIFont { return UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline).bumpFontSize(2.0) }
  class var dcSubHeader: UIFont { return UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline).bumpFontSize(1.7) }
  class var dcCaption: UIFont { return UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1).bumpFontSize(1.6) }

  class var dcMediumButtonText: UIFont { return UIFont(name: "Avenir-Medium", size: 24)! }
  class var dcButtonText: UIFont { return UIFont(name: "Avenir-Medium", size: 30)! }
  class var dcInput: UIFont { return UIFont(name: "Avenir-Heavy", size: 40)! }

}
