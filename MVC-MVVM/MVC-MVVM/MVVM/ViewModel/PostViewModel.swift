//
//  PostViewModel.swift
//  MVC-MVVM
//  https://www.youtube.com/watch?v=q7T6LHm_j8s - lesson 2
//  Created by Uri on 28/3/23.
//

import Foundation
import Combine

enum CustomError: Error {
    case generic
}

class PostViewModel {
    var provider: PostProvider
    var postList = [PostModel]()
    var postObservable = PassthroughSubject<Void, Error>()      // sends an empty signal to its subscribers
    
    init(provider: PostProvider = PostProvider()) {
        self.provider = provider
    }
    
    //MainActor to update the view in the main thread
    @MainActor func getPosts() async {
        guard let result = await provider.getPosts() else {
            postObservable.send(completion: .failure(CustomError.generic))
            return      // if we can't obtain an array of PostModel
        }
        if postList.count > 0 {     // if we have already downloaded posts
            postList += result
        } else {
            postList = result
            postObservable.send()
        }
    }
}
