//
//  ConsentTextField.swift
//  DCPlatform
//
//  Created by James Godwin on 22/03/2016.
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

@IBDesignable
class ConsentTextField: UITextField {

    let mainColor = UIColor.dementiaCitizensBlue()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupViews()
    }

    override func draw(_ rect: CGRect) {
      if self.isUserInteractionEnabled {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(mainColor.cgColor)
        context.setLineWidth(7.0)
        context.setLineDash(phase: 0, lengths: [7, 7])
        context.move(to: CGPoint(x: 0.0, y: rect.height))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height))
        context.strokePath()
      }
    }

    func setupViews() {
        self.backgroundColor = UIColor.clear
        self.attributedPlaceholder = NSAttributedString(string:"Your Name", attributes:[NSForegroundColorAttributeName: mainColor])
    }
}
