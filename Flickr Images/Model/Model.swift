//
//  Model.swift
//  Flickr Images
//
//  Created by Consultant on 08/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import Foundation

struct FlickrFeed: Decodable {
    var title: String
    var link: String
    var items: [FlickrFeedItem]
}

struct FlickrFeedItem: Decodable {
    var title: String
    var link: String
    var dateTaken: Date
    var description: String
    var published: Date
    var author: String
    var tags: String    // TODO: Change this to use [String]
    var media: FlickerMediaItem
    
    enum CodingKeys: String, CodingKey {
        case title
        case link
        case description
        case published
        case author
        case tags
        case media
        case dateTaken = "date_taken"
    }
}

struct FlickerMediaItem: Decodable {
    var m: String
}
