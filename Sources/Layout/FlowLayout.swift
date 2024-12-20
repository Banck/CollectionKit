//
//  FlowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FlowLayout: VerticalSimpleLayout {
  public var lineSpacing: CGFloat
  public var interitemSpacing: CGFloat

  public var alignContent: AlignContent
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  public init(lineSpacing: CGFloat = 0,
              interitemSpacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              alignContent: AlignContent = .start) {
    self.lineSpacing = lineSpacing
    self.interitemSpacing = interitemSpacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.alignContent = alignContent
    super.init()
  }

  public convenience init(spacing: CGFloat,
                          justifyContent: JustifyContent = .start,
                          alignItems: AlignItem = .start,
                          alignContent: AlignContent = .start) {
    self.init(lineSpacing: spacing,
              interitemSpacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              alignContent: alignContent)
  }

    public override func simpleLayout(context: LayoutContext) -> [CGRect] {
        var frames: [CGRect] = []
        var sizes: [CGSize] = []
        var calculatedHeight: CGFloat = 0
        (0..<context.numberOfItems).forEach { index in
            let size = context.size(at: index, collectionSize: .init(width: context.collectionSize.width, height: context.collectionSize.height - calculatedHeight))
            calculatedHeight += size.height
            sizes.append(size)
        }
        let (totalHeight, lineData) = distributeLines(sizes: sizes, maxWidth: context.collectionSize.width)

        var (yOffset, spacing) = LayoutHelper.distribute(justifyContent: alignContent,
                                                         maxPrimary: context.collectionSize.height,
                                                         totalPrimary: totalHeight,
                                                         minimunSpacing: lineSpacing,
                                                         numberOfItems: lineData.count)

        var index = 0
        lineData.enumerated().forEach { offset, data in
            let (lineSize, count) = data
            if
                offset > 0,
                let previousLineSize = lineData.get(offset - 1)?.lineSize,
                previousLineSize.height > 0 && lineSize.height > 0
            {
                yOffset += spacing
            }
            let (xOffset, lineInteritemSpacing) =
            LayoutHelper.distribute(justifyContent: justifyContent,
                                    maxPrimary: context.collectionSize.width,
                                    totalPrimary: lineSize.width,
                                    minimunSpacing: interitemSpacing,
                                    numberOfItems: count)

            let lineFrames = LayoutHelper.alignItem(alignItems: alignItems,
                                                    startingPrimaryOffset: xOffset,
                                                    spacing: lineInteritemSpacing,
                                                    sizes: sizes[index..<(index+count)],
                                                    secondaryRange: yOffset...(yOffset + lineSize.height))

            frames.append(contentsOf: lineFrames)

            yOffset += lineSize.height
            index += count
        }
        return frames
    }

  func distributeLines(sizes: [CGSize], maxWidth: CGFloat) ->
    (totalHeight: CGFloat, lineData: [(lineSize: CGSize, count: Int)]) {
    var lineData: [(lineSize: CGSize, count: Int)] = []
    var currentLineItemCount = 0
    var currentLineWidth: CGFloat = 0
    var currentLineMaxHeight: CGFloat = 0
    var totalHeight: CGFloat = 0
    for size in sizes {
      if currentLineWidth + size.width > maxWidth, currentLineItemCount != 0 {
        lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                          height: currentLineMaxHeight),
                         count: currentLineItemCount))
        totalHeight += currentLineMaxHeight
        currentLineMaxHeight = 0
        currentLineWidth = 0
        currentLineItemCount = 0
      }
      currentLineMaxHeight = max(currentLineMaxHeight, size.height)
      currentLineWidth += size.width + interitemSpacing
      currentLineItemCount += 1
    }
    if currentLineItemCount > 0 {
      lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                        height: currentLineMaxHeight),
                       count: currentLineItemCount))
      totalHeight += currentLineMaxHeight
    }
    return (totalHeight, lineData)
  }
}
