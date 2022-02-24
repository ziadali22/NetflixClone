//
//  CollectionViewTableViewCell.swift
//  Netflix
//
//  Created by ziad on 15/02/2022.
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject{
    func CollectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: DetailsViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {

    // MARK: - Variables
    static let identifer = "CollectionViewTableViewCell"
    weak var delegate: CollectionViewTableViewCellDelegate?
    private var titles = [Title]()
    // anonymous closure
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MoviesAndSeriesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesAndSeriesCollectionViewCell.identifer)
        return collectionView
        
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .brown
        contentView.addSubview(collectionView)
        setupCollectionView()
        
    }
    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with titles: [Title]){
        self.titles = titles
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    private func downloadTitleAt(indexPath: IndexPath){
        
        DataPersistenceManager.shared.downloadTitle(model: titles[indexPath.row]) { result in
            switch result{
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil )
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesAndSeriesCollectionViewCell.identifer, for: indexPath) as? MoviesAndSeriesCollectionViewCell else {return UICollectionViewCell()}
        
        cell.configure(with: titles[indexPath.row].poster_path ?? "")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let title = titles[indexPath.row]
        guard let titleName = title.original_name ?? title.original_title else {return}
        ApiCaller.shared.getMoviesFromYoutube(with: titleName + " trailer") { [weak self] result in
            switch result{
            case .success(let videoElement):
                guard let strongSelf = self else{return}
                let title = self?.titles[indexPath.row]
                let viewModel = DetailsViewModel(title: titleName ,
                                                 youtubeView: videoElement,
                                                 titleOverview: title?.overview ?? "")
                self?.delegate?.CollectionViewTableViewCellDidTapCell(strongSelf, viewModel: viewModel)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let downloadAction = UIAction(title: "Download", image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                self?.downloadTitleAt(indexPath: indexPath)
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
        }
        return config
    }
    
}

