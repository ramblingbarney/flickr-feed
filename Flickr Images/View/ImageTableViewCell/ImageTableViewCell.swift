//
//  ImageTableViewCell.swift
//  Flickr Images
//
//  Created by Consultant on 12/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet var mainImageView: UIImageView!
    var client: FlickrClient?
    
    // MARK: - Instance methods
    override func prepareForReuse() {
        mainImageView.image = nil
    }
    
    func configure(with item: FlickrFeedItem) {
        
        // Use the client to the image
        client?.fetchImage(for: item, completion: { result in
            
            switch result {
                
                // Also the image is being cached using NSCache
                // Would have liked to use FileManager instead, but time
                // Used to writting my own cache as a best practice 
            case .success(let image):
                DispatchQueue.main.async { [unowned self] in
                    self.mainImageView.image = image
                }
            case .failure(let error):
                return print(error.localizedDescription)
            }
            
        })
        
    }
}

extension ImageTableViewCell: Dequeuable {}

// The core logic really then build out from there
// So here it was networking and table views
// Then test them as they are used in many places

// Get the foundation stable first then go from there

// Some say around 70% but everyone says against reaching 100%
