//
//  ItemListViewModel.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import Foundation

class ItemListViewModel {
    var items: [Item] = []
    var onUpdate: (() -> Void)?

    func fetchItems() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let decoded = try JSONDecoder().decode([Item].self, from: data)
                self.items = decoded
                DispatchQueue.main.async {
                    self.onUpdate?()
                }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }.resume()
    }

    func item(at index: Int) -> Item {
        items[index]
    }

    var count: Int {
        items.count
    }
}
