//
//  WebcamCollectionViewCell.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import Kingfisher

class WebcamCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.kf.indicator?.view.layoutIfNeeded()
    }
}

extension WebcamCollectionViewCell: ConfigurableCell {
    typealias ItemType = Webcam
    
    static func identifier() -> String {
        return String(describing: WebcamCollectionViewCell.self)
    }
    
    static func nibName() -> String {
        return String(describing: WebcamCollectionViewCell.self)
    }
    
    func configure(with item: Webcam) {
        if let image = item.preferedImage(), let url = URL(string: image) {
            let indicator = KFIndicator(.white)
            
            imageView.kf.indicatorType = .custom(indicator: indicator)
            imageView.kf.setImage(with: url)
        }
    
        titleLabel.text = item.title
    }
}