//
//  UIImageView+Extension.swift
//  Qiita_App
//
//  Created by Sakai Syunya on 2021/06/10.
//  Copyright © 2021 Sakai Syunya. All rights reserved.
//

import UIKit

class EnhancedCircleImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let image = self.image
        self.image = image
    }

    override var image: UIImage? {
        get { return super.image }
        set {
            self.contentMode = .scaleAspectFit
            super.image = newValue?.roundImage()
        }
    }
    
}
