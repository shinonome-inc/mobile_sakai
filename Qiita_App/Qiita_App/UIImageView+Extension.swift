//
//  UIImageView+Extension.swift
//  Qiita_App
//
//  Created by Sakai Syunya on 2021/07/15.
//  Copyright © 2021 Sakai Syunya. All rights reserved.
//

import UIKit

extension UIImageView {

    func setImageByDefault(with url: URL) {

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Success
            if error == nil, case .some(let result) = data, let image = UIImage(data: result) {
                self?.image = image

            // Failure
            } else {
                // error handling
            }
        }.resume()
    }

}
