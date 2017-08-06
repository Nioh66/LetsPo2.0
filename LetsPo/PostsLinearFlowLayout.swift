//
//  PostsLinearFlowLayout.swift
//  LetsPo
//
//  Created by Pin Liao on 07/08/2017.
//  Copyright © 2017 Walker. All rights reserved.
//

import UIKit

class PostsLinearFlowLayout: UICollectionViewFlowLayout {
    var lastCollectionViewSize : CGSize = CGSize.zero
    var scalingOffset:CGFloat = 200
    var minimumScaleFactor:CGFloat = 0.7
    var scaleItems = true
    
    
    static func configureLayout(collectionView: UICollectionView, itemSize: CGSize, minimumLineSpacing: CGFloat) -> PostsLinearFlowLayout {
        let layout = PostsLinearFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing
        layout.itemSize = itemSize
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.collectionViewLayout = layout
        
        return layout
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureDefaults()
    }
    func configureDefaults() {
        self.scalingOffset = 200
        self.minimumLineSpacing = 0.7
        self.scaleItems = true
    }
    
    // MARK: Invalidation
    override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if self.collectionView == nil {
            return
        }
        
        guard let currentCollectionViewSize = self.collectionView?.bounds.size else{
            return
        }
        
        if !currentCollectionViewSize.equalTo(self.lastCollectionViewSize) {
            self.configureInset()
            self.lastCollectionViewSize = currentCollectionViewSize
        }
    }
    private func configureInset() -> Void{
        if self.collectionView == nil {
            return
        }
        
        let inset = self.collectionView!.bounds.size.width/2 - self.itemSize.width/2
        self.collectionView!.contentInset = UIEdgeInsetsMake(0, inset, 0, inset)
        self.collectionView!.contentOffset = CGPoint(x: -inset, y: 0)
        
    }
    
    //MARK: UICollectionViewLayout (UISubclassingHooks)
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if self.collectionView == nil {
            return proposedContentOffset
        }
        
        let collectionViewSize = self.collectionView!.bounds.size
        let proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
        
        let layoutAttributes = self.layoutAttributesForElements(in: proposedRect)
        
        if layoutAttributes == nil {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes! {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        if candidateAttributes == nil {
            return proposedContentOffset
        }
        
        var newOffsetX = candidateAttributes!.center.x - self.collectionView!.bounds.size.width / 2
        
        let offset = newOffsetX - self.collectionView!.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = self.itemSize.width + self.minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
    
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        if !self.scaleItems || self.collectionView == nil {
            return super.layoutAttributesForElements(in: rect)
        }
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let contentOffset = self.collectionView!.contentOffset
        let size = self.collectionView!.bounds.size
        
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        
        let visibleCenterX = visibleRect.midX
        
        var newAttributesArray = Array<UICollectionViewLayoutAttributes>()
        
        for (_, attributes) in superAttributes.enumerated() {
            let newAttributes = attributes.copy() as! UICollectionViewLayoutAttributes
            newAttributesArray.append(newAttributes)
            let distanceFromCenter = visibleCenterX - newAttributes.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scalingOffset)
            let scale = absDistanceFromCenter * (self.minimumScaleFactor - 1) / self.scalingOffset + 1
            newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        }
        
        return newAttributesArray;
    }
}
