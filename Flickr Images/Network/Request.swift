//
//  Request.swift
//  Flickr Images
//
//  Created by Consultant on 07/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import Foundation

// Base definition of a 'Request'
protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var queries: [URLQueryItem] { get }
}
extension Endpoint {
    
    // used to create a URL
    var urlComponents: URLComponents? {
        
        guard var components = URLComponents(string: base)  else { return nil }
        components.path = path
        components.queryItems = queries
        return components
    }
    
    // Used to create URLReqest 
    var request: URLRequest? {
        guard let url = urlComponents?.url else { return nil }
        return URLRequest(url: url)
    }
}

enum FlickrRequest {
    case publicPhotos(tags: [String]?)
}

extension FlickrRequest: Endpoint {

    var base: String {
        return "https://api.flickr.com"
    }
    
    var queries: [URLQueryItem] {
        
        // The API is told we need JSON format data back
        var params = [URLQueryItem(name: "format", value: "json")]
        
        switch self {
        case .publicPhotos(let x):
            
            // We append some search tags
            if let tags = x, !tags.isEmpty {
                params.append(URLQueryItem(name: "tags", value: tags.joined(separator: ",")))
            }
            
        }
        
        return params
    }
    
    var path: String {
        
        switch self {
        case .publicPhotos(_): return "/services/feeds/photos_public.gne"
        }
    }
    
}
