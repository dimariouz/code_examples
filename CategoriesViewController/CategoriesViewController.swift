//
//  CategoriesViewController.swift
//  WR-app
//
//  Created by dimarious on 28.04.2019.
//  Copyright © 2019 Dmytro Doroshchuk. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesViewController: UIViewController {

    private var categoriesCollectionView = CategoriesCollectionView()
    var favoritesViewController = FavoritesViewController()
    let realm = try! Realm()
    var category: Results<Categories>!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readDatabase()
        setupController()
        ShareManager().showRateController(afterLaunches: 5)
    }
    
    func readDatabase() {
        category = realm.objects(Categories.self)
    }
    
    func setupController() {
        
        setupNavigationBar(title: BarTitles.categories)

        view.addSubview(categoriesCollectionView)
        
        [   categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ].forEach { $0.isActive = true}
        
        categoriesCollectionView.set(cells: category)
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
    }
}

extension CategoriesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let viewController = ExercisesViewController()
        viewController.titleText = category[indexPath.row].title
        viewController.exercise = category[indexPath.row].exercise
        viewController.categorieImage = category[indexPath.row].image
        viewController.index = indexPath.row
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count != 0 ? category.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: CategoriesCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoriesCollectionViewCell
        cell.mainImageView.image = UIImage(named: category[indexPath.row].image)
        cell.nameLabel.text = category[indexPath.row].title
        return cell
    }
}

extension CategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPadding: CGFloat = 30
        let heightPadding: CGFloat = 30
        let collectionViewWidth = categoriesCollectionView.frame.width - widthPadding
        let collectionViewHeight = categoriesCollectionView.frame.height - heightPadding
        
        return CGSize(width: collectionViewWidth / 2, height: collectionViewHeight / 2.5)
    }
}
