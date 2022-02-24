//
//  UpComingViewController.swift
//  Netflix
//
//  Created by ziad on 15/02/2022.
//

import UIKit

class UpComingViewController: UIViewController {
    // MARK: - Variables
    private var titles: [Title] = [Title]()
    private let upcomingTableView : UITableView = {
        let upcomingTableView = UITableView()
        upcomingTableView.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifer)
        return upcomingTableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UpComing"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.addSubview(upcomingTableView)
        setupTableView()
        fetchData()
    }
    private func setupTableView(){
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableView.frame = view.bounds
    }

    private func fetchData(){
        ApiCaller.shared.getUpcomingMovies { result in
            switch result{
            case .success(let titles):
                self.titles = titles
                DispatchQueue.main.async { [weak self] in
                    self?.upcomingTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
extension UpComingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.identifer, for: indexPath) as? UpcomingTableViewCell else {return UITableViewCell()}
        
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: title.original_name ?? title.original_title ?? "" , posterUrl: title.poster_path ?? ""))
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
