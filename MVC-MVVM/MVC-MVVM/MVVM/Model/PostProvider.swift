//
//  PostProvider.swift
//  MVC-MVVM
//  https://youtu.be/q7T6LHm_j8s - lesson 2 - min 17 protocols
//  Created by Uri on 28/3/23.
//

import Foundation

protocol PostProviderProtocol {
    func getPosts() async -> [PostModel]?
    func deletePostClosure(postId : Int, completion : @escaping (Bool)->Void)
}

class PostProvider: PostProviderProtocol {
    func getPosts() async -> [PostModel]? {
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
    
    func deletePostClosure(postId: Int, completion: @escaping (Bool)->Void){
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(postId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let service = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion((error == nil))
            }
        }
        service.resume()
    }
    
}
