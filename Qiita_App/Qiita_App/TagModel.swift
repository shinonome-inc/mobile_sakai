//
//  TagModel.swift
//  Qiita_App
//
//  Created by Sakai Syunya on 2021/06/25.
//  Copyright © 2021 Sakai Syunya. All rights reserved.
//

import Foundation

struct TagItem: Codable {
    //TODO:後でキャメルメースに変更
    let followers_count: Int
    let icon_url: String
    let id: String
    let items_count: Int
}
