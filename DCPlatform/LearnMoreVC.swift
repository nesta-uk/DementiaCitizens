//
//  LearnMoreVC.swift
//  DCPlatform
//
//  Created by James Godwin on 16/03/2016.
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

class LearnMoreVC: DCViewController {

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

  var text: String = ""
  var image: UIImage?
  var buttonTitle: String = "Next"
  var link: (text: String, link: String)?
  var videoName: String?

  var completion: (() -> Void)?

  @IBAction func handleNextButton(_ sender: AnyObject) {
    completion?()
  }

  func handleLink(_ gestureRecognizer: UIGestureRecognizer) {
    if let link = link, let url = URL(string: link.link) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  func createPlayButton(_ action: Selector) -> UIButton {
    let button = UIButton(frame: CGRect(x: 114, y: 115, width: 60, height: 60))
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage.find("play-video-button"), for: UIControlState())
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }

  override func loadView() {
    super.loadView()

    let topView = createImageWithText(text, image: image)

    if let link = link {
      let linkText = createLink(link.text, action: #selector(LearnMoreVC.handleLink(_:)))
      topView.addArrangedSubview(linkText)
    }

    let nextButton = createNextButton(buttonTitle, image: "next", action: #selector(LearnMoreVC.handleNextButton(_:)))

    let container = ConsentContainerView(topView: topView, bottomView: nextButton)
    self.view.addSubview(container)

    if videoName != nil {
      if let imageView = topView.arrangedSubviews.first {
        let button = createPlayButton(#selector(LearnMoreVC.playVideoPressed(_:)))

        self.view.addSubview(button)

        NSLayoutConstraint.activate([
          button.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
          button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
      }
    }

    NSLayoutConstraint.activate([
      nextButton.heightAnchor.constraint(equalToConstant: 76),
      nextButton.widthAnchor.constraint(equalToConstant: 288),
    ])

  }
}
