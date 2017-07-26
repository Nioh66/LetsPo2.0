//
//  FlowLayout.swift
//  LetsPo
//
//  Created by 溫芷榆 on 2017/7/19.
//  Copyright © 2017年 Walker. All rights reserved.
//

import UIKit
struct CardLayoutConst {
    static let maxYOffset: CGFloat = -10
    static let minZoomLevel: CGFloat = 0.9
    static let minAlpha: CGFloat = 0.5
}

let ACTIVE_DISTANCE:CGFloat = 200
let ZOOM_FACTOR:CGFloat = 0.1
let kScreen_Height = UIScreen.main.bounds.size.height
let kScreen_Widgh = UIScreen.main.bounds.size.width
let ITEM_WIDTH = UIScreen.main.bounds.size.width * 0.68

class FlowLayout: UICollectionViewFlowLayout {
    
    
    override init() {
        super.init()
        
        self.itemSize = CGSize(width: ITEM_WIDTH, height: ITEM_WIDTH + 100)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 15
        // 設定內邊距
        self.sectionInset = UIEdgeInsetsMake(64, 35, 0, 35)
        
        
    }
    
    // collectionView的顯示範圍改變時，判斷是否需要重新刷新布局，然後再執行下面兩個方法
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // 返回值決定rect範圍内所有元素的frame
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // 獲得super已經計算好的佈局屬性
        guard let layoutAtts = super.layoutAttributesForElements(in: rect) else { return nil }
        let arr = NSArray(array:layoutAtts, copyItems: true) as! [UICollectionViewLayoutAttributes]
        
        // 最終顯示的矩形框
        var visible = CGRect()
        visible.origin = (collectionView?.contentOffset)!
        visible.size = (collectionView?.bounds.size)!
        
        
        // 在繼承的佈局上在進行微調
        for attributes in arr {
            if attributes.frame.intersects(visible) {
                // cell的中心點x 和 collectionView最中心點的x值 的間距
                var distance = visible.midX - attributes.center.x
                
                // 取絕對值
                distance = abs(distance)
                
                if distance < kScreen_Widgh / 2 + itemSize.width {
                    let zoom = 1 + ZOOM_FACTOR * (1 - distance / ACTIVE_DISTANCE)
                    
                    // 設置縮放比例
                    attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                    attributes.transform3D = CATransform3DTranslate(attributes.transform3D, 0, -zoom * 25, 0)
                    attributes.alpha = zoom - ZOOM_FACTOR
                }
            }
        }
        return arr
    }
    
//     用於決定 collectionView停止滑動時的偏移量
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
       
        // 存放最小的間距值
        var offsetAdjustment = CGFloat(MAXFLOAT)
        // 計算 collectionView 最中心點的x值
        let horizontalCenter = proposedContentOffset.x + (collectionView?.bounds.width)! / 2.0
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: (collectionView?.bounds.size.width)!, height: (collectionView?.bounds.size.height)!)
        
        let array = layoutAttributesForElements(in: targetRect)
        for layoutAttributes:UICollectionViewLayoutAttributes in array! {
            let itemHorizontalCenter = layoutAttributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
