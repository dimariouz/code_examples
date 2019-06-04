//
//  CategoriesCollectionView.swift
//  WR-app
//
//  Created by dimarious on 28.04.2019.
//  Copyright © 2019 Dmytro Doroshchuk. All rights reserved.
//

import UIKit
import RealmSwift

class CategoriesCollectionView: UICollectionView {
    
    var categor: Results<Categories>!

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .white
        
        register(CategoriesCollectionViewCell.self, forCellWithReuseIdentifier: CategoriesCollectionViewCell.reuseIdentifier)
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        showsVerticalScrollIndicator = false
    }
    
    func set(cells: Results<Categories>!) {
        self.categor = cells
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
