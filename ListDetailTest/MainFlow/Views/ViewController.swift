//
//  ViewController.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = ItemListViewModel()

    private let offlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет соединения с интернетом"
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(offlineLabel)
        offlineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            offlineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            offlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineLabel.heightAnchor.constraint(equalToConstant: 30)
        ])


        title = "Items"
        view.backgroundColor = .systemBackground
        setupTableView()

        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onOffline = { [weak self] in
            self?.offlineLabel.isHidden = false
        }

        NetworkMonitor.shared.onStatusChange = { [weak self] isConnected in
            self?.offlineLabel.isHidden = isConnected
            if isConnected {
                self?.viewModel.fetchItems()
            }
        }

        viewModel.fetchItems()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier, for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.item(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.item(at: indexPath.row)
        let detailVC = DetailViewController(item: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


