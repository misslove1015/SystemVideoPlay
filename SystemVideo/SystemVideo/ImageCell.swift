//
//  ImageCell.swift
//  SystemVideo
//
//  Created by 郭明亮 on 2019/7/19.
//  Copyright © 2019 郭明亮. All rights reserved.
//

// 预览图 Cell

import UIKit

class ImageCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50*16/9.0, height: 50))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
