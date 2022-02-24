//
//  SearchResultViewController.swift
//  Netflix
//
//  Created by ziad on 22/02/2022.
//

import UIKit


protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidTapItem(_ viewModel: DetailsViewModel)
}

class SearchResultViewController: UIViewController {
    // MARK: - Variables
    
    var titles : [Title] = [Title]()
    
    public weak var delegate: SearchResultsViewControllerDelegate?
    
    public let SearchResultCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10 , height: 200)
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MoviesAndSeriesCollectionViewCell.self, forCellWithReuseIdentifier: MoviesAndSeriesCollectionViewCell.identifer)
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(SearchResultCollectionView)
        setupCollectionView()
    }
    private func setupCollectionView(){
        SearchResultCollectionView.delegate = self
        SearchResultCollectionView.dataSource = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SearchResultCollectionView.frame = view.bounds
    }

}
extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesAndSeriesCollectionViewCell.identifer, for: indexPath) as? MoviesAndSeriesCollectionViewCell else {return UICollectionViewCell()}
        let title = titles[indexPath.row]
        cell.configure(with: title.poster_path ?? "")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        let titleName = title.original_title ?? ""
        ApiCaller.shared.getMoviesFromYoutube(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                self?.delegate?.searchResultsViewControllerDidTapItem(DetailsViewModel(title: title.original_title ?? "", youtubeView: videoElement, titleOverview: title.overview ?? ""))

                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        

    }
    
}
