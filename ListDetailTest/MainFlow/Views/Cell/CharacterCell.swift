//
//  CharacterCell.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import UIKit

class CharacterCell: UITableViewCell {
    static let identifier = "CharacterCell"

    let customImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        customImageView.layer.cornerRadius = 6

        contentView.addSubview(customImageView)

        NSLayoutConstraint.activate([
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 50),
            customImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    required init?(coder: NSCoder) {
#if DEBUG
        fatalError("init(coder:) has not been implemented")
#endif
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let imageRightEdge = customImageView.frame.maxX + 12
        let textOriginX = max(imageRightEdge, 75)

        textLabel?.frame.origin.x = textOriginX
        detailTextLabel?.frame.origin.x = textOriginX
    }

    func configure(with character: CharacterItem) {
        textLabel?.text = character.name
        detailTextLabel?.text = "ID: \(character.id)"
        loadImage(from: character.image)
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            customImageView.image = nil
            return
        }

        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            self.customImageView.image = image
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response,
                  let image = UIImage(data: data) else {
                return
            }

            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)

            DispatchQueue.main.async {
                self.customImageView.image = image
            }
        }.resume()
    }
}
