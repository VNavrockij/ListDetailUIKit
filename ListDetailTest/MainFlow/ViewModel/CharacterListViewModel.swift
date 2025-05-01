//
//  CharacterListViewModel.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import Foundation

class CharacterListViewModel {
    var items: [CharacterItem] = []
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
        guard let url = URL(string: "https://rickandmortyapi.com/api/character") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.loadFromCache()
                    self.onOffline?()
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CharacterResponse.self, from: data)
                self.items = decoded.results
                self.saveToCache(decoded.results)
                DispatchQueue.main.async {
                    self.onUpdate?()
                }
            } catch {
#if DEBUG
                print("Parsing error: \(error)")
#endif
            }
        }.resume()
    }

    private func saveToCache(_ characters: [CharacterItem]) {
        if let data = try? JSONEncoder().encode(characters) {
            UserDefaults.standard.set(data, forKey: "cachedCharacters")
        }
    }

    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: "cachedCharacters"),
           let cached = try? JSONDecoder().decode([CharacterItem].self, from: data) {
            self.items = cached
            DispatchQueue.main.async {
                self.onUpdate?()
            }
        }
    }

    func item(at index: Int) -> CharacterItem {
        items[index]
    }

    var count: Int {
        items.count
    }
}
