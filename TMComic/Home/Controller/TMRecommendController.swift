//
//  TMRecommendController.swift
//  TMComic
//
//  Created by Luther on 2020/5/13.
//  Copyright © 2020 mrstock. All rights reserved.
//

import UIKit
import LLCycleScrollView

class TMRecommendController: TMBaseViewController {
    
    private var sexType: Int = UserDefaults.standard.integer(forKey: String.sexType)
    private var galleryItems = [GalleryItemModel]()
    private var textItems = [TextItemModel]()
    private var comicItems = [ComicListModel]()
    
    private lazy var bannerView: LLCycleScrollView = {
        let banner = LLCycleScrollView()
        banner.autoScrollTimeInterval = 3.0
        banner.backgroundColor = UIColor.background
        banner.placeHolderImage = UIImage(named: "normal_placeholder_h")
        banner.coverImage = UIImage()
        banner.pageControlPosition = .right
        banner.pageControlBottom = 20
        banner.titleBackgroundColor = UIColor.clear
        return banner
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let flowLayout = TMCollectionViewSectionBackgroundLayout()
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 10
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = UIColor.background
        collection.alwaysBounceVertical = false
        collection.contentInset = UIEdgeInsets(top: kScreenWidth * 0.467, left: 0, bottom: 0, right: 0)
        collection.scrollIndicatorInsets = collection.contentInset
        
        collection.uHead = TMRefreshHeader { [weak self] in
            self?.loadData(false)
        }
        
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(false)
    }
    
    override func setupSubviews() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(collectionView.contentInset.top)
        }
    }
    
    override func registerCell() {
        collectionView.register(cellType: TMComicCell.self)
        collectionView.register(cellType: TMBoardCell.self)
        collectionView.register(supplementaryViewType: TMComicHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.register(supplementaryViewType: TMComicFooterView.self, ofKind: UICollectionView.elementKindSectionFooter)
    }
    
    private func loadData(_ changeSex: Bool) {
        if changeSex {
            sexType = 3 - sexType
            UserDefaults.standard.setValue(sexType, forKey: String.sexType)
            UserDefaults.standard.synchronize()
        }
        
        ApiLoadingProvider.request(TMAPI.boutiqueList(sexType: sexType), model: BoutiqueListModel.self) { [weak self] (returnData) in
            self?.galleryItems = returnData?.galleryItems ?? []
            self?.textItems = returnData?.textItems ?? []
            self?.comicItems = returnData?.comicLists ?? []
            
            self?.bannerView.imagePaths = self?.galleryItems.filter({ (item) -> Bool in
                return item.cover != nil
            }).map({ (item) -> String in
                return item.cover!
            }) ?? []
            
            self?.collectionView.uHead.endRefreshing()
            self?.collectionView.reloadData()
        }
        
    }
}

extension TMRecommendController: UICollectionViewDataSource,TMCollectionViewSectionBackgroundLayoutDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.comicItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let comicList = comicItems[section]
        return comicList.comics?.prefix(4).count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor {
        return UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: TMComicHeaderView.self)
            let comicList = comicItems[indexPath.section]
            headerView.iconView.kf.setImage(with: URL(string: comicList.newTitleIconUrl!)!)
            headerView.titleLabel.text = comicList.itemTitle
            headerView.moreActionClosure { [weak self] in
                
            }
            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: TMComicFooterView.self)
            return footerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let comicList = comicItems[section]
        return comicList.itemTitle?.count ?? 0 > 0 ? CGSize(width: kScreenWidth, height: 44) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return comicItems.count - 1 != section ? CGSize(width: kScreenWidth, height: 10) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comicList = comicItems[indexPath.section]
        if comicList.comicType == .billboard {
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: TMBoardCell.self)
            cell.model = comicList.comics?[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: TMComicCell.self)
            if comicList.comicType == .thematic {
                cell.style = .none
            } else {
                cell.style = .titleAndDes
            }
            cell.model = comicList.comics?[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let comicList = comicItems[indexPath.section]
        if comicList.comicType == .billboard {
            let width = floor((kScreenWidth - 15.0) / 4.0)
            return CGSize(width: width, height: 80)
        }else {
            if comicList.comicType == .thematic {
                let width = floor((kScreenWidth - 5.0) / 2.0)
                return CGSize(width: width, height: 120)
            } else {
                let count = comicList.comics?.takeMax(4).count ?? 0
                let warp = count % 2 + 2
                let width = floor((kScreenWidth - CGFloat(warp - 1) * 5.0) / CGFloat(warp))
                return CGSize(width: width, height: CGFloat(warp * 80))
            }
        }
    }
    
}
