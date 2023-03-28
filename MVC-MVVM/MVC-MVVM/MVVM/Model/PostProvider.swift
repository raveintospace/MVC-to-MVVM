//
//  PostProvider.swift
//  MVC-MVVM
//
//  Created by Uri on 28/3/23.
//

import Foundation

class PostProvider {
    func getPosts(moreResults : Bool = false) async -> [PostModel]? {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response1 = try decoder.decode([PostModel].self, from: data)
            let response = Array(response1.prefix(10))
            return response
        } catch {
            print("Invalid data: ", error)
            return nil
        }
    }
    
}
