//
//  YoutubeSearch.swift
//  Netflix
//
//  Created by ziad on 16/02/2022.
//

import Foundation
struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}


struct VideoElement: Codable {
    let id: IdVideoElement
}


struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
