//
//  ArrayExtension.swift
//  TMComic
//
//  Created by Luther on 2020/5/18.
//  Copyright © 2020 mrstock. All rights reserved.
//

import Foundation

extension Array {
    public func takeMax(_ n: Int) -> Array {
        return Array(self[0..<Swift.max(0, Swift.min(n, count))])
    }
}
