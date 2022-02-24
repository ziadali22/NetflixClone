//
//  MoviesAndSeriesCollectionViewCell.swift
//  Netflix
//
//  Created by ziad on 21/02/2022.
//

import UIKit
import SDWebImage

class MoviesAndSeriesCollectionViewCell: UICollectionViewCell {
    static let identifer = "MoviesAndSeriesCollectionViewCell"
    
    private let posterImageView: UIImageView = {
        let posterImageView = UIImageView()
        posterImageView.contentMode = .scaleAspectFill
        return posterImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }
    
    public func configure(with model: String){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model)") else {return}
        posterImageView.sd_setImage(with: url, completed: nil)
    }
}
