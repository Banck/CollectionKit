//
//  HashableDataSource.swift
//  CollectionKit
//
//  Created by Egor Sakhabaev on 13.12.2021.
//  Copyright © 2021 lkzhao. All rights reserved.
//

import CoreGraphics

open class HashableSizeSource<Data: Hashable>: ClosureSizeSource<Data> {
    private var hashedSizes: [Int: CGSize] = [:]

    open override func size(at index: Int, data: Data, collectionSize: CGSize) -> CGSize {
        if let size = hashedSizes[data.hashValue] {
            return size
        } else {
            let size = super.size(at: index, data: data, collectionSize: collectionSize)
            hashedSizes[data.hashValue] = size
            return size
        }
    }
}
