//
//  DetailTableViewController.swift
//  Flickr Images
//
//  Created by Consultant on 11/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import UIKit

// Wanted to resue a lot of cells
struct DisplayItem {
    
    enum Section: Int {
        case image
        case text
        case link
    }
    
    var title: String?
    var item: String
    var itemType: Section
}

protocol DetailModel {
    
    var client: FlickrClient { get }
    var feedItem: FlickrFeedItem { get }
    
    func feetchFeedImage(_ completion: @escaping (Result<UIImage, APIError>) -> Swift.Void)
}

class DetailViewControllerModel: DetailModel {
    
    var feedItem: FlickrFeedItem
    var client: FlickrClient
    
    private var data: [[DisplayItem]]
    
    init(client: FlickrClient, _ feedItem: FlickrFeedItem) {
        self.client = client
        self.feedItem = feedItem
        data = []
        
        setup()
    }
    
    func setup() {
        
        // Simple dateformatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        // Create the data for the table view
        data.append([DisplayItem(title: nil, item: feedItem.media.m, itemType: .image)])
        
        var section2 = [DisplayItem]()
        section2.append(DisplayItem(title: "Title", item: feedItem.title, itemType: .text))
        section2.append(DisplayItem(title: "Date Taken", item: dateFormatter.string(from: feedItem.dateTaken), itemType: .text))
        section2.append(DisplayItem(title: "Date Published", item: dateFormatter.string(from: feedItem.published), itemType: .text))
        if feedItem.tags.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            section2.append(DisplayItem(title: "Tags", item: feedItem.tags, itemType: .text))
        }
        data.append(section2)
        
        var section3 = [DisplayItem]()
        section3.append(DisplayItem(title: "Save in Gallery", item: feedItem.media.m, itemType: .link))
        section3.append(DisplayItem(title: "Open in Browser", item: feedItem.link, itemType: .link))
        section3.append(DisplayItem(title: "Share via Email", item: feedItem.link, itemType: .link))
        data.append(section3)
        
    }
    
    func feetchFeedImage(_ completion: @escaping (Result<UIImage, APIError>) -> Swift.Void) {
        
        client.fetchImage(for: feedItem, completion: { result in
            
            switch result {
                case .success(let image): completion(.success(image))
                case .failure(let error): completion(.failure(error))
            }
        })
        
    }
}

extension DetailViewControllerModel: ListModel {
    
    var numberOrSections: Int {
        return data.count
    }
    
    func subSet(in section: Int) -> [DisplayItem]? {
        guard section >= 0 && section < numberOrSections else { return nil }
        return data[section]
    }
    
    func numberOfRows(in section: Int) -> Int {
        guard let subSetData = subSet(in: section) else { return 0 }
        return subSetData.count
    }
    
    func object(at indexPath: IndexPath) -> Any? {
        guard let subSetData = subSet(in: indexPath.section),
            (indexPath.row >= 0 && indexPath.row < numberOfRows(in: indexPath.section))else { return nil }
        return subSetData[indexPath.row]
    }
    
    
}

class DetailTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let allActivities: Set = [UIActivity.ActivityType.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .mail, .message, .openInIBooks, .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToVimeo, .postToWeibo, .print, .saveToCameraRoll, .markupAsPDF]
    
    typealias DetailTableViewModel = DetailModel & ListModel
    
    var model: DetailViewControllerModel!
    
    // MARK: - ViewController Life Cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the cells
        tableView.register(ImageTableViewCell.self)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    // MARK: - TableView Data Source & Delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOrSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(in: section)
    }
    
    let tableViewCellID = "BasicTableViewCell"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = DisplayItem.Section(rawValue: indexPath.section) else {
            fatalError("Section \(indexPath.section) not accounted for")
        }
        
        // Setting up the cells depending on whether they are displaying an image, sharing options or simple text
        switch section {
            case .image:
                let cell = tableView.dequeue(reusableCell: ImageTableViewCell.self, for: indexPath)
                cell.client = model.client
                // Yeah the cells fetches its own img
                // Not the best but wanted to try out something
                
                // inside here
                cell.configure(with: model.feedItem)
                return cell
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellID, for: indexPath)
                guard let feedItem = model.object(at: indexPath) as? DisplayItem else { return cell }
                cell.textLabel?.text = feedItem.title
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.text = feedItem.item
                return cell
            case .link:
                let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellID, for: indexPath)
                guard let feedItem = model.object(at: indexPath) as? DisplayItem else { return cell }
                cell.textLabel?.text = feedItem.title
                cell.textLabel?.textColor = .blue
                cell.detailTextLabel?.text = nil
                return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = DisplayItem.Section(rawValue: indexPath.section) else {
            fatalError("Section \(indexPath.section) not accounted for")
        }
        
        switch section {
            case .image: return tableView.frame.width * 0.75
            default: return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        guard let section = DisplayItem.Section(rawValue: indexPath.section) else {
            fatalError("Section \(indexPath.section) not accounted for")
        }
        
        switch section {
            case .link: return indexPath
            default:  return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        guard let displayItem = model.object(at: indexPath) as? DisplayItem else { return }
        
        switch indexPath.row {
            case 1:
                if let url = URL(string: displayItem.item) {
                    UIApplication.shared.open(url, options: [:])
            }
            case 0:
                share(via: .saveToCameraRoll)
            case 2:
                share(via: .mail)
            default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Instance Functions
    func share(via options: UIActivity.ActivityType...) {
        
        model.feetchFeedImage { result in
            
            switch result {
                case .success(let image):
                    
                    let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    
                    let excludedActivities = self.allActivities.subtracting(Set(options))
                    
                    activity.excludedActivityTypes = Array(excludedActivities)
                    DispatchQueue.main.async { [unowned self] in
                        self.present(activity, animated: true, completion: nil)
                }
                case .failure(let error):
                    return print(error.localizedDescription)
            }
            
        }
        
    }
}
