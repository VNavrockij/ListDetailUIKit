//
//  ItemCell.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import UIKit

class ItemCell: UITableViewCell {
    static let identifier = "ItemCell"

    func configure(with item: Item) {
        textLabel?.text = item.title
        detailTextLabel?.text = "ID: \(item.id)"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
