//
//  OnboardViewController.swift
//  DCPlatform
//
//  Created by James Godwin on 29/06/2016.
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
import AVKit
import AVFoundation

@objc protocol PagerPageDelegate {
  func joinStudyTapped(_ sender: AnyObject)
}

class OnboardViewController: DCViewController, PagerPageDelegate {

  var completion: (() -> Void)?

  func joinStudyTapped(_ sender: AnyObject) {
    completion?()
  }

  var container = UIView()

  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }

  override func loadView() {
    super.loadView()
    self.navigationController?.navigationBar.barTintColor = UIColor.dementiaCitizensBackground()
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.dementiaCitizensBlack()]
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.isHidden = true

    let logo = UIImage.find("dc-beta")
    let logoView = UIImageView()

    logoView.image = logo
    logoView.translatesAutoresizingMaskIntoConstraints = false
    logoView.contentMode = .scaleAspectFit

    let logoBlock = UIView()
    logoBlock.translatesAutoresizingMaskIntoConstraints = false
    logoBlock.backgroundColor = UIColor.dementiaCitizensBackground()
    logoBlock.addSubview(logoView)

    let divider = UIView()
    divider.translatesAutoresizingMaskIntoConstraints = false
    divider.backgroundColor = UIColor.dementiaCitizensLightGrey()
    logoBlock.addSubview(divider)

    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(container)
    self.view.addSubview(logoBlock)

    let margins = self.view.layoutMarginsGuide

    NSLayoutConstraint.activate([
      logoView.centerXAnchor.constraint(equalTo: logoBlock.centerXAnchor),
      logoView.centerYAnchor.constraint(equalTo: logoBlock.centerYAnchor),
      logoView.heightAnchor.constraint(equalTo: logoBlock.heightAnchor, multiplier: 0.5),
      divider.widthAnchor.constraint(equalTo: logoBlock.widthAnchor),
      divider.heightAnchor.constraint(equalToConstant: 1),
      divider.bottomAnchor.constraint(equalTo: logoBlock.bottomAnchor),
      divider.leadingAnchor.constraint(equalTo: logoBlock.leadingAnchor),
      divider.trailingAnchor.constraint(equalTo: logoBlock.trailingAnchor),
    ])

    NSLayoutConstraint.activate([
      container.topAnchor.constraint(equalTo: logoBlock.bottomAnchor),
      container.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
      container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

      logoBlock.topAnchor.constraint(equalTo: margins.topAnchor),
      logoBlock.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      logoBlock.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      logoBlock.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2),
    ])

    let vc = OnboardPagesViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    vc.pagerDelegate = self
    vc.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChildViewController(vc)
    container.addSubview(vc.view)
    vc.didMove(toParentViewController: self)

    NSLayoutConstraint.activate([
      vc.view.topAnchor.constraint(equalTo: container.topAnchor),
      vc.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      vc.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      vc.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
  }
}

class OnboardPagesViewController: UIPageViewController, UIPageViewControllerDataSource {

  var prompts = loadConsentScreens("onboarding")

  weak var pagerDelegate: PagerPageDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = self
    self.setViewControllers([getViewControllerAtIndex(0)!] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)

    let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [OnboardPagesViewController.self])
    pageControl.pageIndicatorTintColor = UIColor.gray
    pageControl.currentPageIndicatorTintColor = UIColor.black
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let pageContent = viewController as? PagerPage else { return nil }
    let index = pageContent.pageIndex
    if index == 0 {
      return nil
    }
      return getViewControllerAtIndex(index!-1)
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let pageContent = viewController as? PagerPage else { return nil }
    let index = pageContent.pageIndex
    if index == prompts.count - 1 {
      return nil
    }
    return getViewControllerAtIndex(index!+1)
  }

  func getViewControllerAtIndex(_ index: NSInteger) -> UIViewController? {
    let pageContentViewController = PagerPage()
    pageContentViewController.delegate = pagerDelegate
    pageContentViewController.pageText = prompts[index].text
    pageContentViewController.pageImageName = prompts[index].imageName
    pageContentViewController.pageIndex = index
    if pageContentViewController.pageIndex + 1 == prompts.count {
      pageContentViewController.hasJoinButton = true
    }
    if pageContentViewController.pageIndex == 0 {
      pageContentViewController.isFirstPage = true
    }
    if prompts[index].videoName != nil {
      pageContentViewController.videoName = prompts[index].videoName
    }
    return pageContentViewController
  }

  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return prompts.count
  }

  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    guard let currentPage = pageViewController.viewControllers?.first as? PagerPage else { return 0 }
    return currentPage.pageIndex
  }

}

class PagerPage: DCViewController {

  var pageIndex: Int!
  var pageImageName: String!
  var pageText: String!
  var videoName: String?
  var hasJoinButton = false
  var isFirstPage = false

  @IBAction func playVideoPressed(_ sender: AnyObject) {
    if let videoName = videoName {
      do {
        let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4")
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
          playerViewController.player!.play()
        }
      } catch {
        print("Error setting audiosession category")
      }
    }
  }

  weak var delegate: PagerPageDelegate?
  var imageAndText: UIStackView!

  override func loadView() {
    super.loadView()
    self.view.backgroundColor = UIColor.dementiaCitizensBackground()

    let pageLabel = UILabel()
    pageLabel.translatesAutoresizingMaskIntoConstraints = false
    pageLabel.textAlignment = .center
    pageLabel.text = pageText
    pageLabel.lineBreakMode = .byClipping
    pageLabel.adjustsFontSizeToFitWidth = true
    pageLabel.minimumScaleFactor = 0.5
    pageLabel.numberOfLines = 0
    pageLabel.font = UIFont.dcHeader
    pageLabel.textColor = UIColor.dementiaCitizensBlack()
    pageLabel.backgroundColor = UIColor.dementiaCitizensBackground()

    let image = UIImage.find(pageImageName)
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = image
    imageView.contentMode = UIViewContentMode.scaleAspectFit

    imageAndText = UIStackView(arrangedSubviews: [imageView, pageLabel])
    imageAndText.translatesAutoresizingMaskIntoConstraints = false
    imageAndText.distribution = .fill
    imageAndText.spacing = 15

    if self.traitCollection.verticalSizeClass == .compact {
      imageAndText.axis = .horizontal
    } else {
      imageAndText.axis = .vertical
    }

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 15

    stackView.addArrangedSubview(imageAndText)
    stackView.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(stackView)
    let margins = self.view.layoutMarginsGuide

    if hasJoinButton {
      let joinButton = createNextButton("Join Study", image: "next", action: #selector(PagerPage.handleJoinStudy(_:)))
      joinButton.translatesAutoresizingMaskIntoConstraints = false
      joinButton.setTitle("Join Study", for: UIControlState())
      joinButton.backgroundColor = UIColor.blue
      stackView.addArrangedSubview(joinButton)

      NSLayoutConstraint.activate([
        joinButton.heightAnchor.constraint(equalToConstant: 76),
        joinButton.widthAnchor.constraint(equalToConstant: 288),
      ])
    }

    if let video = videoName {
      let videoButton = createChoiceButton(video, action: #selector(PagerPage.playVideoPressed(_:)))
      videoButton.translatesAutoresizingMaskIntoConstraints = false
      videoButton.setTitle("Watch our study video", for: UIControlState())
      videoButton.titleLabel?.font = UIFont.dcBody
      videoButton.titleLabel?.textAlignment = .center
      stackView.addArrangedSubview(videoButton)

      NSLayoutConstraint.activate([
        videoButton.heightAnchor.constraint(equalToConstant: 56),
        videoButton.widthAnchor.constraint(equalToConstant: 288),
      ])
    }

    if self.isFirstPage {
      let captionLabel = createCaptionLabel("Swipe left to see more")
      stackView.addArrangedSubview(captionLabel)
       NSLayoutConstraint.activate([
        captionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
      ])
    }

    NSLayoutConstraint.activate([
      pageLabel.widthAnchor.constraint(greaterThanOrEqualTo: stackView.widthAnchor, multiplier: 0.5),
      pageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
      stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
      stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
      stackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
    ])
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if let imageAndText = imageAndText {
      let originalAxis = imageAndText.axis
      if self.traitCollection.verticalSizeClass == .compact {
        imageAndText.axis = .horizontal
      } else {
        imageAndText.axis = .vertical
      }
      if originalAxis != imageAndText.axis {
        imageAndText.layoutIfNeeded()
      }
    }
  }

  func handleJoinStudy(_ sender: AnyObject) {
    delegate?.joinStudyTapped(sender)
  }

}
