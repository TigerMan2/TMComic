//
//  TMBaseViewController.swift
//  TMComic
//
//  Created by Luther on 2020/5/13.
//  Copyright © 2020 mrstock. All rights reserved.
//

import UIKit
import Then
import SnapKit
import Reusable
import Kingfisher

class TMBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.background
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        setupSubviews()
        registerCell()
        initValue()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configNavigationBar()
    }
    
    func setupSubviews() {}
    func registerCell() {}
    func initValue() {}
    func loadData() {}
    func bindViewData() {}
    func configNavigationBar() {
        guard let nav = navigationController else { return }
        if nav.visibleViewController == self {
            nav.barStyle(.theme)
            nav.disablePopGesture = false
        }
    }
    
}

extension TMBaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
