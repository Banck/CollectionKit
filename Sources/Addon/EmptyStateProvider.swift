//
//  EmptyStateProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class EmptyStateProvider: ComposedProvider {
  open var emptyStateView: UIView?
  open var emptyStateViewGetter: () -> UIView
  open var contentProvider: Provider
  open var emptyStateViewSectionIdentifier: String = "emptyStateView"
  open var emptyViewSizeStrategy: (width: SimpleViewSizeSource.ViewSizeStrategy,
                                   height: SimpleViewSizeSource.ViewSizeStrategy)
  
  public init(identifier: String? = nil,
              emptyStateView: @autoclosure @escaping () -> UIView,
              emptyViewSizeStrategy: (width: SimpleViewSizeSource.ViewSizeStrategy,
                                      height: SimpleViewSizeSource.ViewSizeStrategy) = (.fill, .fill),
              content: Provider) {
    self.emptyStateViewGetter = emptyStateView
    self.contentProvider = content
    self.emptyViewSizeStrategy = emptyViewSizeStrategy
    super.init(identifier: identifier,
               layout: RowLayout().transposed(),
               sections: [content])
  }

  open override func willReload() {
    contentProvider.willReload()
    if contentProvider.realNumberOfItems == 0, sections.first?.identifier != emptyStateViewSectionIdentifier {
      if emptyStateView == nil {
        emptyStateView = emptyStateViewGetter()
      }
      let viewSection = SimpleViewProvider(
        identifier: "emptyStateView",
        views: [emptyStateView!],
        sizeStrategy: emptyViewSizeStrategy
      )
      sections = [viewSection]
      super.willReload()
    } else if contentProvider.realNumberOfItems > 0, sections.first?.identifier == emptyStateViewSectionIdentifier {
      sections = [contentProvider]
    } else {
      super.willReload()
    }
  }

  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return super.hasReloadable(reloadable) || contentProvider.hasReloadable(reloadable)
  }
}

extension Provider {
    var realNumberOfItems: Int {
        let numberOfItems = (self as? SectionProvider)?.sections.reduce(0) { $0 + $1.numberOfItems }
        return numberOfItems ?? self.numberOfItems
    }
}
