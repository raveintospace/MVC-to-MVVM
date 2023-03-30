//
//  PostListViewController.swift
//  MVC-MVVM
//
//  Created by Uri on 28/3/23.
//

import UIKit
import Combine

class PostListViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    lazy var loading: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView(style: .large)
        loading.startAnimating()
        loading.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44.0)
        return loading
    }()
    
    var viewModel = PostViewModel()
    private var anyCancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptions()
        configureTableView()
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
        
        viewModel.wasRemovedObservable.sink { (wasRemoved, indexpath) in
            if wasRemoved {
                self.tableView.deleteRows(at: [indexpath], with: .fade)
            }
        }.store(in: &anyCancellable)
    }
    
    private func configureTableView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
    }
}

// MARK: - Extensions

extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.postList[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = viewModel.formatTitle(item)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        cell.textLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = item.body
        cell.detailTextLabel?.numberOfLines = 0
        
        if viewModel.postList.count == (indexPath.row+1){
            Task{
                await viewModel.getPosts()  // load more content
            }
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
        viewModel.deletePost(postId: postId, indexPath: indexPath)
    }
}
