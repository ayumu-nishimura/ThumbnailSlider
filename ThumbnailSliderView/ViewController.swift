//
//  ViewController.swift
//  ThumbnailSliderView
//
//  Created by ayumu.nishimura on 2024/05/29.
//

import UIKit

class ViewController: UIViewController {
    var sliderView: ThumbnailSliderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        sliderView = ThumbnailSliderView(frame: view.bounds)
        sliderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sliderView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        sliderView.layoutIfNeeded()
        sliderView.setNeedsLayout()
    }
}
