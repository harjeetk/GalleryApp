//
//  PhotoViewController.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var imageViewPhoto: UIImageView!
    var objectPhoto: PhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
    }
    
    fileprivate func setupScrollView(){
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        scrollView.backgroundColor = UIColor.black
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        self.view.addSubview(scrollView)
        
        imageViewPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        imageViewPhoto.contentMode = .scaleAspectFit
        let imageURL = objectPhoto?.urls?.full ?? ""
        imageViewPhoto.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: [.cacheMemoryOnly, .transition(.fade(0.3))], completionHandler: nil)
        scrollView.addSubview(imageViewPhoto)
    }
    
}

extension PhotoViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageViewPhoto
    }
}
