//
//  KContactCollectionViewCell.swift
//  SwiftSampleContacts
//
//  Created by Dexter Kim on 2014-12-22.
//  Copyright (c) 2014 DexMobile. All rights reserved.
//

import UIKit

class KContactCollectionViewCell: UICollectionViewCell {
    
    let textLabel: UILabel!
    let imageView: KCImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = self.frame.size.width*3/4;
        let height = self.frame.size.height*3/4;
        let x = self.frame.size.width/2 - width/2;
        let y = self.frame.size.height/2 - height/2 - 10;
        imageView = KCImageView(frame: CGRect(x: x, y: y, width: width, height: height))
        imageView.basicSetting()
        contentView.addSubview(imageView)
        
        let textFrame = CGRect(x: 0, y: frame.size.height - 30, width: frame.size.width, height: frame.size.height/3)
        textLabel = UILabel(frame: textFrame)
        textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
    }
}
