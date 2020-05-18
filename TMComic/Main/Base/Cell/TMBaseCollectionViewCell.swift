//
//  TMBaseCollectionViewCell.swift
//  TMComic
//
//  Created by Luther on 2020/5/17.
//  Copyright © 2020 mrstock. All rights reserved.
//

import UIKit
import Reusable

class TMBaseCollectionViewCell: UICollectionViewCell, Reusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
    }
}
