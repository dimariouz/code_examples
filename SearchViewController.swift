//
//  SearchViewController.swift
//  searchImage
//
//  Created by Dmytro on 2/18/20.
//  Copyright © 2020 Dmytro Doroshchuk. All rights reserved.
//
import UIKit

class SearchViewController: UIViewController {
    
    private let activityView = UIFactory.Utility.activityView()
    private let searchBar: UISearchBar = UISearchBar()
    private let networkService: NetworkServiceProtocol = NetworkService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }
    
    private func setupUI() {
        title = "Search Images"
        view.backgroundColor = Constants.Colors.gray
        
        view.addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    private func setupSearchBar() {
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search image"
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func showImageScreen(with imageUrl: String?) {
        let imageVC = ImageViewController()
        imageVC.imageUrl = imageUrl
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let text = searchBar.text else { return }
        activityView.startAnimating()
        networkService.getImagesUrlList(searchString: text) { result in
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
            }
            switch result {
            case .success(let imageList):
                let url = imageList?.data.randomElement()?.images.downsizedLarge.url
                DispatchQueue.main.async {
                    self.showImageScreen(with: url)
                }
            case .failure(let error):
                print(error?.localizedDescription)
            }
        }
    }
    
}
