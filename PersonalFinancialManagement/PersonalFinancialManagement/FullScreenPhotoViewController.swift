//
//  FullScreenPhotoViewController.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 29.05.2025.
//
//
//  FullScreenPhotoViewController.swift
//  PersonalFinancialManagement
//
//  Created by [Senin İsmin] on [Bugünün Tarihi].
//

import UIKit

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Setup scrollView
        scrollView.frame = view.bounds
        scrollView.delegate = self
        view.addSubview(scrollView)

        // Setup imageView
        imageView.image = image
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)

        // Tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreen))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissFullScreen() {
        dismiss(animated: true, completion: nil)
    }

    // Zoom yapılacak view burada imageView
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
