//
//  MainHomeHeader.swift
//  Netflix
//
//  Created by ziad on 16/02/2022.
//

import UIKit

class MainHomeHeader: UIView {
    
    // MARK: - Variables
    private let heroImageView : UIImageView = {
        let heroImage = UIImageView()
        heroImage.contentMode = .scaleAspectFill
        heroImage.clipsToBounds = true
        heroImage.image = UIImage(named: "HeroImage")
        return heroImage
    }()
    private let playButton : UIButton = {
        let playButton = UIButton()
        playButton.setTitle("Play", for: .normal)
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 1
        playButton.layer.cornerRadius = 5
        playButton.translatesAutoresizingMaskIntoConstraints = false
        return playButton
    }()
    
    private let downloadButton : UIButton = {
        let downloadButton = UIButton()
        downloadButton.setTitle("Donwload", for: .normal)
        downloadButton.layer.borderColor = UIColor.white.cgColor
        downloadButton.layer.borderWidth = 1
        downloadButton.layer.cornerRadius = 5
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        return downloadButton
    }()
    
    
    // MARK: - Main
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        addGradient()
        addSubview(playButton)
        addSubview(downloadButton)
        applayConstraint()
    }
    
    private func addGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    func applayConstraint(){
        let playButtonConstraints = [
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            playButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        let downloadButtonConstraints = [
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
    }
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterUrl)") else {
            return
        }
        
        heroImageView.sd_setImage(with: url, completed: nil)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
    }

}
