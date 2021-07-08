//
//  MultipleStickyLayout.swift
//  CollectionKit
//
//  Created by Egor Sakhabaev on 08.04.2021.
//  Copyright © 2021 lkzhao. All rights reserved.
//

import UIKit

public class MultipleStickyLayout: StickyLayout {
  /*
  public override func visible(in visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    self.visibleFrame = visibleFrame
    let stickyIndexes = stickyFrames.enumerated().filter { index, stickyFrame in
      let previousHeadersHeight = stickyFrames[0..<index].reduce(0) { $0 + $1.frame.height }
      return stickyFrame.frame.minY < visibleFrame.minY + previousHeadersHeight
    }.map { $0.element }
    var oldVisible = rootLayout.visible(in: visibleFrame)
    stickyIndexes.forEach {
      if $0.index >= 0 {
        if let index = oldVisible.indexes.firstIndex(of: $0.index) {
          oldVisible.indexes.remove(at: index)
        }
        oldVisible.indexes += [$0.index]
      }
    }
    return oldVisible
  }*/
  
  public override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    self.visibleFrame = visibleFrame
    let stickyIndexes = stickyFrames.enumerated().filter { index, stickyFrame in
      let previousHeadersHeight = stickyFrames[0..<index].reduce(0) { $0 + $1.frame.height }
      return stickyFrame.frame.minY < visibleFrame.minY + previousHeadersHeight
    }.map { $0.element }
    var oldVisible = rootLayout.visibleIndexes(visibleFrame: visibleFrame)
    stickyIndexes.forEach {
      if $0.index >= 0 {
        if let index = oldVisible.firstIndex(of: $0.index) {
          oldVisible.remove(at: index)
        }
        oldVisible += [$0.index]
      }
    }
    return oldVisible
  }
  
  public override func frame(at: Int) -> CGRect {
    let superFrame = rootLayout.frame(at: at)
    let stickyFrame = stickyFrames.first { $0.index == at }
    var previousHeadersHeight: CGFloat = 0
    if stickyFrame != nil {
      previousHeadersHeight = stickyFrames[0..<stickyFrames.firstIndex { $0.index == stickyFrame!.index }! ].reduce(0) { $0 + $1.frame.height }
    }
    
    if superFrame.minY < visibleFrame.minY + previousHeadersHeight, stickyFrame != nil {
      var pushedY = superFrame.minY
      if pushedY < visibleFrame.minY + previousHeadersHeight {
        pushedY = visibleFrame.minY + previousHeadersHeight
      }
      return CGRect(origin: CGPoint(x: superFrame.minX, y: pushedY), size: superFrame.size)
    }
    return superFrame
  }
}
