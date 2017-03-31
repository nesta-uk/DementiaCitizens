//
//  QOLSurvey.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 16/03/2016.
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
class TaskCell: UITableViewCell {

  @IBOutlet weak var cellDate: UILabel!
  @IBOutlet weak var numberOfQuestions: UILabel!
  @IBOutlet weak var cellLabel: UILabel!
  @IBOutlet weak var cellImage: UIImageView!

  override func draw(_ rect: CGRect) {

    UIColor.dementiaCitizensBackground().setFill()
    UIRectFill(rect)

    let topBorder = UIBezierPath()
    topBorder.move(to: CGPoint(x:0, y:0))
    topBorder.addLine(to: CGPoint(x:rect.width, y:0))
    topBorder.close()

    let bottomBorder = UIBezierPath()
    bottomBorder.move(to: CGPoint(x:0, y:rect.height))
    bottomBorder.addLine(to: CGPoint(x:rect.width, y:rect.height))
    bottomBorder.close()

    UIColor.dementiaCitizensBlack().withAlphaComponent(0.3).set()
    topBorder.stroke()
    bottomBorder.stroke()
  }
}

class HeaderCell: UITableViewCell {
  @IBOutlet weak var headerTitle: UILabel!
}

@IBDesignable
class QOLTableViewController: UITableViewController, CalendarAware {

  fileprivate let reuseIdentifier = "taskCell"

  var calendar: DCCalendar?

  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(refreshList), name: NSNotification.Name(rawValue: "TodoListShouldRefresh"), object: nil)
    self.navigationItem.titleView = UIImageView(image: UIImage.find("menu-logo"))
    self.navigationController?.navigationBar.barTintColor = UIColor.dementiaCitizensBackground()
    self.navigationController?.navigationBar.isTranslucent = false
    self.tableView.backgroundColor = UIColor.dementiaCitizensDarkBackground()
  }

  override func viewWillAppear(_ animated: Bool) {
    refreshList()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let calendar = calendar else { return 0 }
    return calendar.tasksToDo().count
  }

  func noTasks() -> UIView? {

    guard let calendar = calendar else { return nil }
    if calendar.tasksToDo().count > 0 { return nil }

    let widthOfLabel = self.tableView.bounds.size.width * 0.8
    let labelMargin = (self.tableView.bounds.size.width - widthOfLabel) / 2

    let noTasksView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
    noTasksView.backgroundColor = UIColor.dementiaCitizensDarkBackground()

    let noTasks: UILabel = UILabel(frame: CGRect(x: labelMargin, y: 0, width: widthOfLabel, height: self.tableView.bounds.size.height))
    noTasks.lineBreakMode = .byWordWrapping
    noTasks.numberOfLines = 0
    noTasks.font = UIFont.dcBodySmall

    if DCApplication.sharedApplication.studyFinished {
      noTasks.text = DCApplication.sharedApplication.study?.endMessage
    } else {
      noTasks.text = "When you have study tasks to complete they will appear here."
    }

    noTasks.textColor = UIColor.dementiaCitizensBlack().withAlphaComponent(0.9)
    noTasks.textAlignment = NSTextAlignment.center

    noTasksView.addSubview(noTasks)
    return noTasksView
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TaskCell,
      let calendar = calendar {
      let getTask = calendar.tasksToDo()[indexPath.item]
      cell.cellLabel.text = getTask.listTitle

      let dueDate = getTask.dueDate
      let formatter = DateFormatter()
      formatter.dateFormat = "d MMM"

      cell.numberOfQuestions.text = "\(getTask.taskType.numberOfQuestions) Questions"
      let dateString = formatter.string(from: dueDate as Date)
      cell.cellDate.text = dateString
      cell.cellImage.image = UIImage.find(getTask.iconName)
      cell.backgroundColor = UIColor.dementiaCitizensBackground()

      return cell
    } else {
      return UITableViewCell()
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
    let sectionTitle: String
    if calendar?.tasksToDo().count == 0 {
      sectionTitle = ""
    } else {
      sectionTitle = "Current Study Tasks"
    }
    return sectionTitle
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if calendar?.tasksToDo().count == 0 {
      if let header = view as? UITableViewHeaderFooterView {
        header.textLabel?.text = ""
      }
    } else {
      if let header = view as? UITableViewHeaderFooterView {
        header.textLabel?.textColor = UIColor.dementiaCitizensBlack().withAlphaComponent(0.65)
        header.textLabel?.textAlignment = .left
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        header.textLabel?.text = "Current Study Tasks"
      }
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let calendar = calendar else { return }

    let getTask = calendar.tasksToDo()[indexPath.item]
    let viewController = getTask.getViewController {
      self.dismiss(animated: true, completion:  nil)
    }
    self.present(viewController, animated: true, completion: nil)
  }

  func refreshList() {
    tableView.reloadData()
    self.tableView.backgroundView = noTasks()
  }

}
