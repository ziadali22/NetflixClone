//
//  HomeViewController.swift
//  Netflix
//
//  Created by ziad on 15/02/2022.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTvs = 1
    case Popular = 2
    case UpComing = 3
    case TopRated = 4
}
class HomeViewController: UIViewController {

    // MARK: - Varables
    let sectionTitle: [String] = ["Top Rated", "Popular", "Trending Tv", "Last Movies"]
    private var randomTrendingMovie: Title?
    private var headerView: MainHomeHeader?
    
    
    private var homeTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifer)
        return table
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavbar()
        view.addSubview(homeTableView)
        setupTable()
        apiCall()
        configureHeroHeaderView()
    }
    private func configureHeroHeaderView() {

        ApiCaller.shared.getTrendingMovies { [weak self] result in
            switch result {
            case .success(let titles):
                let selectedTitle = titles.randomElement()
                
                self?.randomTrendingMovie = selectedTitle
                self?.headerView?.configure(with: TitleViewModel(titleName: selectedTitle?.original_title ?? "", posterUrl: selectedTitle?.poster_path ?? ""))
                
            case .failure(let erorr):
                print(erorr.localizedDescription)
            }
        }
    }
    private func configureNavbar() {
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
    }
    private func setupTable(){
        homeTableView.delegate = self
        homeTableView.dataSource = self
        headerView = MainHomeHeader(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeTableView.tableHeaderView = headerView
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeTableView.frame = view.bounds
    }
    
    private func apiCall(){
        ApiCaller.shared.getTrendingMovies { [weak self]result in
            switch result{
            case .success(let titles):
                let selectedTitles = titles.randomElement()
                self?.randomTrendingMovie = selectedTitles
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }

}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifer, for: indexPath) as? CollectionViewTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        switch indexPath.section{
        case Sections.TrendingMovies.rawValue:
            ApiCaller.shared.getTrendingMovies { result in
                switch result{
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TrendingTvs.rawValue:
            ApiCaller.shared.getTrendingTv { result in
                switch result{
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.Popular.rawValue:
            ApiCaller.shared.getPopular { result in
                switch result{
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.UpComing.rawValue:
            ApiCaller.shared.getUpcomingMovies { result in
                switch result{
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.TopRated.rawValue:
            ApiCaller.shared.getTopRated { result in
                switch result{
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        default:
            return UITableViewCell()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return}
        header.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .white
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20 , y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
}

extension HomeViewController: CollectionViewTableViewCellDelegate{
    func CollectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: DetailsViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = DetailsViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        
    }
    
    
}
