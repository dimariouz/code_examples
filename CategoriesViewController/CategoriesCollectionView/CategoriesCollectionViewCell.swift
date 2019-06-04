//
//  CategoriesCollectionViewCell.swift
//  WR-app
//
//  Created by dimarious on 29.04.2019.
//  Copyright © 2019 Dmytro Doroshchuk. All rights reserved.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addShadow(cornerRadius: CGFloat.scale(accordingToDeviceSize: 15),
                       radius: 5,
                       opacity: 0.5,
                       offset: CGSize(width: 0.0, height: 4.0),
                       color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        return view
    }()
    
    let mainImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = CGFloat.scale(accordingToDeviceSize: 15)
        view.clipsToBounds = true
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [shadowView, mainImageView, nameLabel].forEach(addSubview)
        
        [   shadowView.topAnchor.constraint(equalTo: topAnchor),
            shadowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            shadowView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: 1),
            
            mainImageView.topAnchor.constraint(equalTo: topAnchor),
            mainImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            mainImageView.widthAnchor.constraint(equalTo: mainImageView.heightAnchor, multiplier: 1),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 12),
        ].forEach { $0.isActive = true }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
