//
//  TMComicHeaderView.swift
//  TMComic
//
//  Created by Luther on 2020/5/18.
//  Copyright © 2020 mrstock. All rights reserved.
//

import UIKit

typealias TMComicHeaderViewMoreClosure = () -> Void

protocol TMComicHeaderViewDelegate: class {
    func clickMoreButton(_ comic: TMComicHeaderView, moreButton button: UIButton)
}

class TMComicHeaderView: TMBaseCollectionReusableView {
    
    weak var delegate: TMComicHeaderViewDelegate?
    
    private var moreActionClosure: TMComicHeaderViewMoreClosure?
    
    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(clickMore), for: .touchUpInside)
        return button
    }()
    
    override func setupSubviews() {
        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(iconView.snp.right).offset(5)
            $0.centerY.equalToSuperview()
        }
        
        addSubview(moreButton)
        moreButton.snp.makeConstraints {
            $0.top.bottom.right.equalToSuperview()
            $0.width.equalTo(40)
        }
    }
    
    @objc func clickMore(button: UIButton) {
        delegate?.clickMoreButton(self, moreButton: button)
        
        guard let closure = moreActionClosure else { return }
        closure()
    }
    
    func moreActionClosure(_ closure: TMComicHeaderViewMoreClosure?) {
        moreActionClosure = closure
    }
    
}
