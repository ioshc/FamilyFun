//
//  CycleLayout.swift
//  ResponderSystemServer
//
//  Created by eden on 2018/1/29.
//  Copyright © 2018年 com.shenma. All rights reserved.
//

import Cocoa

class CycleLayout: NSCollectionViewLayout {

    private var _attributeAttay = Array<NSCollectionViewLayoutAttributes>()

    override var collectionViewContentSize: NSSize {
        return CGSize.init(width: 1280, height: 900)
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return _attributeAttay
    }

    override func prepare() {
        super.prepare()

        _attributeAttay.removeAll()
        
        //获取item的个数
        guard let itemCount = self.collectionView?.numberOfItems(inSection: 0) else {
            return
        }

        //先设定大圆的半径 取长和宽最短的
        let radius: CGFloat = min(collectionViewContentSize.width, collectionViewContentSize.height)/2

        //计算圆心位置
        let center = CGPoint(x: collectionViewContentSize.width/2,
                             y: collectionViewContentSize.height/2)

        //设置每个item的大小为50*50 则半径为25
        for i in 0..<itemCount {
            let attris = NSCollectionViewLayoutAttributes(forItemWith: IndexPath(item: i, section: 0))
            //计算每个item中心的坐标
            //算出的x y值还要减去item自身的半径大小
            let x = center.x + cos(2 * CGFloat(Double.pi) / CGFloat(itemCount) * CGFloat(i)) * (radius-50)
            let y = center.y + sin(2 * CGFloat(Double.pi) / CGFloat(itemCount) * CGFloat(i)) * (radius-50)
            attris.frame = CGRect(x: x-50, y: y-50, width:  100, height: 100)

            _attributeAttay.append(attris)
        }
    }
}
