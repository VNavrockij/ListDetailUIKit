//
//  ViewController.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = CharacterListViewModel()
    private let refreshControl = UIRefreshControl()

    private let offlineLabel: UILabel = {
        let label = UILabel()
        label.text = "No internet connection"
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Characters"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupOfflineLabel()

        view.bringSubviewToFront(offlineLabel)

        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }

        viewModel.onOffline = { [weak self] in
            self?.showOfflineBanner()
        }

        NetworkMonitor.shared.onStatusChange = { [weak self] isConnected in
#if DEBUG
            print("🌐 Online: \(isConnected)")
#endif
            if isConnected {
                self?.hideOfflineBanner()
                self?.viewModel.fetchItems()
            } else {
                self?.showOfflineBanner()
            }
        }

        viewModel.fetchItems()
    }

    private func setupOfflineLabel() {
        view.addSubview(offlineLabel)
        offlineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            offlineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            offlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func showOfflineBanner() {
        guard offlineLabel.isHidden else { return }
        offlineLabel.alpha = 0
        offlineLabel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.offlineLabel.alpha = 1
        }
    }

    private func hideOfflineBanner() {
        guard !offlineLabel.isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.offlineLabel.alpha = 0
        }, completion: { _ in
            self.offlineLabel.isHidden = true
        })
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(tableView)
    }

    @objc private func didPullToRefresh() {
        viewModel.fetchItems()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.identifier, for: indexPath) as? CharacterCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.item(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = viewModel.item(at: indexPath.row)
        let detailVC = CharacterDetailViewController(item: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
