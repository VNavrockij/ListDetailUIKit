//
//  ItemListViewModel.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import Foundation

class ItemListViewModel {
    private let cacheKey = "cachedItems"

    var items: [Item] = []
    var onUpdate: (() -> Void)?
    var onOffline: (() -> Void)?

    func fetchItems() {
        if NetworkMonitor.shared.isConnected {
            fetchFromAPI()
        } else {
            loadFromCache()
            onOffline?()
        }
    }

    private func fetchFromAPI() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self.loadFromCache(); self.onOffline?() }
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Item].self, from: data)
                self.items = decoded
                self.saveToCache(decoded)
                DispatchQueue.main.async { self.onUpdate?() }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }.resume()
    }

    private func saveToCache(_ items: [Item]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }

    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode([Item].self, from: data) {
            self.items = cached
            DispatchQueue.main.async { self.onUpdate?() }
        }
    }

    func item(at index: Int) -> Item {
        items[index]
    }

    var count: Int {
        items.count
    }
}

