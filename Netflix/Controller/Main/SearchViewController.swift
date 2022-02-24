//
//  SearchViewController.swift
//  Netflix
//
//  Created by ziad on 15/02/2022.
//

import UIKit

class SearchViewController: UIViewController {

    

    // MARK: - Varibales
    var titles: [Title] = [Title]()
    
    private let searchTableView: UITableView = {
        let table = UITableView()
        table.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifer)
        return table
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultViewController())
        controller.searchBar.placeholder = "Search for a movie or Tv Show"
        controller.searchBar.searchBarStyle = .minimal
        
        return controller
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        view.addSubview(searchTableView)
        setupTableView()
        fetchSearchData()
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        searchController.searchResultsUpdater = self
    }
    private func setupTableView(){
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTableView.frame = view.bounds
    }
    
    private func fetchSearchData(){
        ApiCaller.shared.getSearch() { [weak self] result in
            switch result{
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async { [weak self] in
                    self?.searchTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.identifer, for: indexPath) as? UpcomingTableViewCell else {return UITableViewCell()}
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.original_name ?? title.original_title ?? "", posterUrl: title.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = titles[indexPath.row]
        guard let titleName = title.original_name ?? title.original_title else {return}
        ApiCaller.shared.getMoviesFromYoutube(with: titleName + " trailer") { [weak self] result in
            switch result{
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = DetailsViewController()
                    vc.configure(with: DetailsViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
extension SearchViewController : UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar  = searchController.searchBar
        guard let quaery = searchBar.text,
              !quaery.trimmingCharacters(in: .whitespaces).isEmpty,
              quaery.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultController = searchController.searchResultsController as? SearchResultViewController else {return}
        resultController.delegate = self
        ApiCaller.shared.getSearchWithQueary(with: quaery) { result in
            switch result{
            case .success(let titles):
                DispatchQueue.main.async {
                    resultController.titles = titles
                    resultController.SearchResultCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func searchResultsViewControllerDidTapItem(_ viewModel: DetailsViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = DetailsViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
