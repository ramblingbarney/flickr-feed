//
//  MasterCollectionViewCell.swift
//  Flickr Images
//
//  Created by Consultant on 09/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import UIKit

class MasterCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    var client: FlickrClient?
    
    // MARK: - Instance functions
    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
        
        titleLabel.isHidden = false
    }
    
    func configure(with item: FlickrFeedItem) {
        
        let title = item.title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if title.count > 0  { titleLabel.text = title } else { titleLabel.isHidden = true }
        
        client?.fetchImage(for: item, completion: { result in
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async { [unowned self] in
                    self.imageView.image = image
                }
            case .failure(let error):
                return print(error.localizedDescription)
            }
            
        })
        
    }

}

extension MasterCollectionViewCell: Dequeuable {}
