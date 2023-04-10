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
    var provider: PostProviderProtocol
    var postList = [PostModel]()
    var postObservable = PassthroughSubject<Void, Error>()      // sends an empty signal to its subscribers
    var wasRemovedObservable = PassthroughSubject<(Bool, IndexPath), Never>()
    
    init(provider: PostProviderProtocol = PostProvider()) {
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
    
    func deletePost(postId: Int, indexPath: IndexPath) {
        provider.deletePostClosure(postId: postId) {[weak self] wasRemoved in
            guard let self = self else { return }
            self.postList.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.wasRemovedObservable.send((wasRemoved, indexPath)) // notify that was removed and in which indexPath
            }
        }
    }
    
    func formatTitle(_ item: PostModel) -> String{
        let title = item.title.capitalized
        return title
    }
}
