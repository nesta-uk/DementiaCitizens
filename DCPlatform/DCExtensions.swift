//
//  DCExtensions.swift
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

import Foundation

extension Sequence {

  func splitApart(_ test: (Iterator.Element) -> Bool) -> (passed: [Iterator.Element], failed: [Iterator.Element]) {
    return (passed: filter(test), failed: filter { !test($0) })
  }

}

extension FileManager {

  class var documentsDir: URL {
    var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
    return URL(fileURLWithPath:paths[0])
  }

  class func pathForFileInDocumentsDir(_ filename: String) -> URL {
    return documentsDir.appendingPathComponent(filename)
  }

  class func pathForFileInCachesDir(_ filename: String) -> URL {
    return cachesDir.appendingPathComponent(filename)
  }

  class var cachesDir: URL {
    var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
    return URL(fileURLWithPath:paths[0])
  }

}

func loadVC(_ name: String, bundleName: String) -> UIViewController {
  return UIStoryboard(name: bundleName, bundle: Bundle(for:DCRootController.self)).instantiateViewController(withIdentifier: name)
}

extension UIImage {

  class func find(_ imageName: String) -> UIImage? {
    let image = UIImage(named: imageName)
    if image == nil {
      return UIImage(named: imageName, in: Bundle(for: DCApplication.self), compatibleWith: nil)
    } else {
      return image
    }
  }

}
