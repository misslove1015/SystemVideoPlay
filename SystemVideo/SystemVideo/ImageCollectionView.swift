//
//  ImageCollectionView.swift
//  SystemVideo
//
//  Created by 郭明亮 on 2019/7/20.
//  Copyright © 2019 郭明亮. All rights reserved.
//

// 预览图 CollectionView

import UIKit

class ImageCollectionView: UICollectionView {
   
    var touchBegin:(() -> Void)?
    var touchEnd:(() -> Void)?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchBegin != nil {
            touchBegin!()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchEnd != nil {
            touchEnd!()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
