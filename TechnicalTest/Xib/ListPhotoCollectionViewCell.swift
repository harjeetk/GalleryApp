//
//  ListPhotoCollectionViewCell.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import UIKit
import Kingfisher

class ListPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageViewPhoto.applyCornerRadius()
    }

    func loadData(_ data: PhotoModel){
        let imageURL = data.urls?.getAnyOneURL() ?? ""
        imageViewPhoto.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: [.cacheMemoryOnly, .transition(.fade(0.3))], completionHandler: nil)
        labelName.text = data.user?.name
        labelDescription.text = data.photoModelDescription
    }
}
