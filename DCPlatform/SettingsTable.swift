//
//  SettingsTable.swift
//  DCPlatform
//
//  Created by James Godwin on 09/07/2016.
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
import MessageUI

enum Setting: Int {
  case help
  case feedback
  case bugReport
}

class SettingsCell: UITableViewCell {
  override func draw(_ rect: CGRect) {
    UIColor.dementiaCitizensBackground().setFill()
    UIRectFill(rect)
    let bottomBorder = UIBezierPath()
    bottomBorder.move(to: CGPoint(x:0, y:rect.height))
    bottomBorder.addLine(to: CGPoint(x:rect.width, y:rect.height))
    bottomBorder.close()
    UIColor.dementiaCitizensBlack().withAlphaComponent(0.5).set()
    bottomBorder.stroke()
  }
}

var reuseIdentifier = "settingsCell"

class SettingsTable: UITableViewController, MFMailComposeViewControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.barTintColor = UIColor.dementiaCitizensBackground()
    self.navigationController?.navigationBar.isTranslucent = false
    self.tableView.backgroundColor = UIColor.dementiaCitizensBackground()

    let backButton = UIImage.find("back-button" )
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButton, style: .plain, target: self, action: #selector(dismiss(_:)))
    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.dementiaCitizensBlue()
  }

  func dismiss(_ sender: AnyObject) {
    _ = self.navigationController?.popViewController(animated: true)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? SettingsCell {
      if indexPath.row == 0 {
        cell.textLabel?.text = "Dementia Citizens Help Site"
        cell.textLabel?.backgroundColor = UIColor.dementiaCitizensBackground()
      } else if indexPath.row == 1 {
        cell.textLabel?.text = "Email Feedback or a Question"
        cell.textLabel?.backgroundColor = UIColor.dementiaCitizensBackground()
      }
      return cell
    } else {
      return UITableViewCell()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let appName = DCApplication.sharedApplication.name
    if indexPath.row == 0 {
      UIApplication.shared.open(URL(string: "http://dementiacitizens.org/")!, options: [:], completionHandler: nil)
    } else if indexPath.row == 1 {
      let mailComposerVC = MFMailComposeViewController()
      mailComposerVC.mailComposeDelegate = self
      mailComposerVC.setToRecipients(["email@example.com"])
      mailComposerVC.setSubject("Feedback/Question for \(appName)")
      self.present(mailComposerVC, animated: true, completion: nil)
    }
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }

  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    self.dismiss(animated: true, completion: nil)
  }
}
