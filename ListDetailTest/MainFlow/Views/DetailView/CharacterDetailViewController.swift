//
//  CharacterDetailViewController.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    private let item: CharacterItem

    init(item: CharacterItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
#if DEBUG
        fatalError("init(coder:) has not been implemented")
#endif
    }

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Character"
        view.backgroundColor = .systemBackground

        setupLayout()
        configure()
    }

    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func configure() {
        nameLabel.text = item.name
        loadImage(from: item.image)
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            imageView.image = nil
            return
        }

        let request = URLRequest(url: url)

        // Trying to get image from cache
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            self.imageView.image = image
            return
        }

        // Loading and caching
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response,
                  let image = UIImage(data: data) else {
                return
            }

            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)

            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }

}

