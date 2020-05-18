//
//  TMTabBarController.swift
//  TMComic
//
//  Created by Luther on 2020/5/13.
//  Copyright © 2020 mrstock. All rights reserved.
//

import UIKit

class TMTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        tabBar.isTranslucent = false
        
        ///首页
        let home = TMHomeController(titles: ["推荐","VIP","订阅","排行"],
                                    vcs: [TMRecommendController(),
                                          TMVIPController(),
                                          TMSubscribeController(),
                                          TMRankController()],
                                    pageStyle: .navgationBarSegment)
        addChildViewController(home, title: "首页", image: UIImage(named: "tab_home"), selectedImage: UIImage(named: "tab_home_S"))
        
        ///分类
        let cate = TMCateController()
        addChildViewController(cate, title: "分类", image: UIImage(named: "tab_class"), selectedImage: UIImage(named: "tab_class_S"))
        
        ///书架
        let book = TMHomeController(titles: ["收藏","书单","下载"],
                                    vcs: [TMBaseViewController(),TMBaseViewController(),TMBaseViewController()],
                                    pageStyle: .navgationBarSegment)
        addChildViewController(book, title: "书架", image: UIImage(named: "tab_book"), selectedImage: UIImage(named: "tab_book_S"))
        
        ///我的
        let mine = TMMineController()
        addChildViewController(mine, title: "我的", image: UIImage(named: "tab_mine"), selectedImage: UIImage(named: "tab_mine_S"))
        
    }
    
    func addChildViewController(_ viewController: UIViewController, title: String?, image:UIImage?, selectedImage: UIImage?) {
        viewController.title = title
        viewController.tabBarItem = UITabBarItem(title: nil,
                                                 image: image?.withRenderingMode(.alwaysOriginal),
                                                 selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        if UIDevice.current.userInterfaceIdiom == .phone {
            viewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        addChild(TMNavigationController(rootViewController: viewController))
    }
}

extension TMTabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let select = selectedViewController else {
            return .lightContent
        }
        return select.preferredStatusBarStyle
    }
}
