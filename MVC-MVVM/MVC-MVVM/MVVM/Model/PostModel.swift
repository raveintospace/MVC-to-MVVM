//
//  PostModel.swift
//  MVC-MVVM
//  https://youtu.be/6qUFa9asnN4
//  Created by Uri on 28/3/23.
//

import Foundation

struct PostModel: Codable {
    let user: Int
    let id: Int
    let title: String
    let body: String
}
