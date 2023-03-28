//
//  PostListViewController.swift
//  MVC-MVVM
//
//  Created by Uri on 28/3/23.
//

import UIKit
import Combine

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = PostViewModel()
    private var anyCancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.prefersLargeTitles = true
        subscriptions()
        Task{
            await self.viewModel.getPosts()
        }
    }
    
    private func subscriptions() {
        viewModel.postObservable.sink { error in
            print("error: ", error)
        } receiveValue: {
            self.tableView.reloadData()
        }.store(in: &anyCancellable)
    }
    
    private func deletePostClosure(postId : Int, completion : @escaping (Bool)->Void){
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
    
    private func deleteRowFromList(_ indexPath : IndexPath){
        viewModel.postList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func formatTitle(_ item : PostModel) -> String{
        let title = item.title.capitalized
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.postList[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = formatTitle(item)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        cell.textLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = item.body
        cell.detailTextLabel?.numberOfLines = 0
        
        if viewModel.postList.count == (indexPath.row+1){
            Task{
                await viewModel.getPosts()  // load more content
            }
            
            let loading = UIActivityIndicatorView(style: .large)
            loading.startAnimating()
            loading.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44.0)
            
            self.tableView.tableFooterView = loading
            self.tableView.tableFooterView?.isHidden = false
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = viewModel.postList[indexPath.row]
        let vc = DetailViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let postId = viewModel.postList[indexPath.row].id
        deletePostClosure(postId: postId) { [weak self] wasRemoved in
            if wasRemoved{
                self?.deleteRowFromList(indexPath)
            }else{
                print("error removing")
            }
        }
    }
}
