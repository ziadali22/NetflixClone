//
//  DonwloadsViewController.swift
//  Netflix
//
//  Created by ziad on 15/02/2022.
//

import UIKit

class DonwloadsViewController: UIViewController {
    private var titles: [TitleItem] = [TitleItem]()
    private let downloadedTableView : UITableView = {
        let downloadedTableView = UITableView()
        downloadedTableView.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifer)
        return downloadedTableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.addSubview(downloadedTableView)
        downloadedTableView.delegate = self
        downloadedTableView.dataSource = self
        fetchDataFromCoreData()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloaded"), object: nil, queue: nil) { _ in
            self.fetchDataFromCoreData()
        }
    }
    private func fetchDataFromCoreData(){
        DataPersistenceManager.shared.fetchingTitlesFromDataBase { [weak self] result in
            switch result{
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.downloadedTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTableView.frame = view.bounds
    }

}
extension DonwloadsViewController: UITableViewDelegate, UITableViewDataSource{
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case .delete:
            DataPersistenceManager.shared.deleteDataFromDataBase(model: titles[indexPath.row]) { [weak self] result in
                switch result{
                case .success():
                    print("Deleted from Data Base")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.titles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
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
