//
//  TMSubscribeController.swift
//  TMComic
//
//  Created by Luther on 2020/5/13.
//  Copyright © 2020 mrstock. All rights reserved.
//

import UIKit

class TMSubscribeController: TMBaseViewController {

    private var subscribeList = [ComicListModel]()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = TMCollectionViewSectionBackgroundLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 5
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.background
        collection.alwaysBounceVertical = true
        collection.uHead = TMRefreshHeader{ [weak self] in
            self?.loadData()
        }
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func registerCell() {
        collectionView.register(cellType: TMComicCell.self)
        collectionView.register(supplementaryViewType: TMComicHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.register(supplementaryViewType: TMComicFooterView.self, ofKind: UICollectionView.elementKindSectionFooter)
    }
    
    override func setupSubviews() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.usnp.edges)
        }
    }
    
    func loadData() {
        ApiLoadingProvider.request(TMAPI.subscribeList, model: SubscribeListModel.self) { (returnData) in
            self.collectionView.mj_header?.endRefreshing()
            self.subscribeList = returnData?.newSubscribeList ?? []
            self.collectionView.reloadData()
        }
    }
}

extension TMSubscribeController: TMCollectionViewSectionBackgroundLayoutDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return subscribeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let comic = subscribeList[section]
        return comic.comics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let head = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath, viewType: TMComicHeaderView.self)
            let comicList = subscribeList[indexPath.section]
            head.iconView.kf.setImage(with: URL(string: comicList.titleIconUrl ?? ""), placeholder: UIImage(named: "normal_placeholder_h"))
            head.titleLabel.text = comicList.itemTitle
            head.moreButton.isHidden = !comicList.canMore
            head.moreActionClosure { [weak self] in
               
            }
            return head
        } else {
            let foot = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: indexPath, viewType: TMComicFooterView.self)
            return foot
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let comicList = subscribeList[section]
        return comicList.itemTitle?.count ?? 0 > 0 ? CGSize(width: kScreenWidth, height: 44) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return subscribeList.count - 1 != section ? CGSize(width: kScreenWidth, height: 10) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comic = subscribeList[indexPath.section]
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: TMComicCell.self)
        cell.style = .title
        cell.model = comic.comics?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor(Double(kScreenWidth - 10.0) / 3.0)
        return CGSize(width: width, height: 240)
    }
}
