//
//  Item.swift
//  ListDetailTest
//
//  Created by Vitalii Navrotskyi on 01.05.2025.
//

import Foundation

struct CharacterItem: Codable {
    let id: Int
    let name: String
    let image: String
}

struct CharacterResponse: Codable {
    let results: [CharacterItem]
}
