//
//  ViewController.swift
//  Flickr Images
//
//  Created by Consultant on 06/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import UIKit

// Sort options for custom sorting
enum SortOption {
    case dateTaken
    case datePublished
}

protocol ListModel {
    var numberOrSections: Int { get }
    func numberOfRows(in section: Int) -> Int
    func object(at indexPath: IndexPath) -> Any?
}

protocol MasterModel {
    
    var client: FlickrClient { get }
    var sortOption: SortOption { get }
    
    func sort(by option: SortOption)
    func searchFeed(with tags: [String]?, completion: @escaping (Bool) -> Void)
    
}

class MasterViewControllerModel: MasterModel {
    
    var client: FlickrClient
    var sortOption: SortOption
    
    private var feedItems: [FlickrFeedItem]
    
    init(_ client: FlickrClient) {
        self.client = client
        sortOption = .datePublished
        feedItems = []
    }
    
    func sort(by option: SortOption) {
        sortOption = option
        
        feedItems = feedItems.sorted(by: { item1, item2 in
            
            switch sortOption {
                case .dateTaken:
                    return item1.dateTaken < item2.dateTaken
                case .datePublished:
                    return item1.published < item2.published
            }
            
        })
    }
    
    func searchFeed(with tags: [String]? = nil, completion: @escaping (Bool) -> Void) {
        
        // Use the API to get data
        client.getFeed(from: FlickrRequest.publicPhotos(tags: tags) ) { result in
            
            switch result {
                case .success(let data):
                    
                    // Need to 'clean' data as the API returns some information which cannot used with Codable
                    guard let cleanData = data.clean else {
                        print("JSON could not be cleaned")
                        return completion(false)
                    }
                    
                    do{
                        let data = try DataParser.parse(cleanData, type: FlickrFeed.self)
                        self.feedItems = data.items
                        self.sort(by: self.sortOption)
                        completion(true)
                    } catch {
                        print(error.localizedDescription)
                        completion(false)
                }
                
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false)
            }
            
        }
        
    }
    
}

extension MasterViewControllerModel: ListModel {
    
    var numberOrSections: Int { return 1 }
    
    func numberOfRows(in section: Int) -> Int {
        guard section >= 0 && section < numberOrSections else { return 0 }
        return feedItems.count
    }
    
    func object(at indexPath: IndexPath) -> Any? {
        
        guard indexPath.section >= 0 && indexPath.section < numberOfRows(in: indexPath.section) else {
            print("Sections Error")
            return nil
        }
        
        guard indexPath.row >= 0 && indexPath.row < numberOfRows(in: indexPath.section) else {
            print("Rows Error")
            return nil
        }
        
        return feedItems[indexPath.row]
        
    }
    
}

class MasterViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    typealias MasterTableViewModel = MasterModel & ListModel
    
    var model: MasterTableViewModel!
    
    // MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sortItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortItems(_:)))
        navigationItem.rightBarButtonItem = sortItem
        
        // Setup the Search Controller, mostly boiler plate code
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Register the cell
        collectionView.register(MasterCollectionViewCell.self)
        
        // Subimt a default search to show something
        model.searchFeed(with: nil) { result in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sortItems(_ sender:UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Sorting", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sort by Date Taken", style: .default, handler: { _ in
            
            self.model.sort(by: .dateTaken)
            DispatchQueue.main.async { [unowned self] in self.collectionView.reloadData() }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Sort by Date Published", style: .default, handler: { _ in
            
            self.model.sort(by: .dateTaken)
            DispatchQueue.main.async { [unowned self] in self.collectionView.reloadData() }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func filterContent(forSearch searchText: String) {
        
        let searchTags = searchText.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        model.searchFeed(with: searchTags) { result in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
            case UIStoryboardSegue.keys.showDetail:
                if let detination = segue.destination as? DetailTableViewController,
                    let feedItem = sender as? FlickrFeedItem {
                    
                    let detailModel = DetailViewControllerModel(client: model.client, feedItem)
                    detination.model = detailModel
            }
            
            default: break
            
        }
    }
}

// MARK: - UICollectionViewDataSource Ext
extension MasterViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.numberOrSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeue(reusableCell: MasterCollectionViewCell.self, for: indexPath)
        
        guard let feedItem = model.object(at: indexPath) as? FlickrFeedItem else {
            fatalError("Something went very wrong here")
        }
        
        cell.client = model.client
        cell.configure(with: feedItem)
        return cell
    }
}

// MARK: - UICollectionViewDelegate Ext
extension MasterViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: UIStoryboardSegue.keys.showDetail, sender: model.object(at: indexPath))
    }
}

extension MasterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (collectionView.frame.height - 5) / 3
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - UISearchBar Delegate
extension MasterViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        filterContent(forSearch: text)
    }
}

// MARK: - Extensions
// NOTE: These should be moved to their own files, but in the interest of time they are here
extension UIStoryboardSegue {
    
    enum keys {
        static let showDetail = "showDetail"
    }
}

extension String {
    
    struct Replace {
        var pattern: String
        var with: String
    }
    
    mutating func filtering(filterItems: Replace...) {
        for filterItem in filterItems {
            self = self.replacingOccurrences(of: filterItem.pattern, with: filterItem.with)
        }
    }
}

// All this was found on online as a quick way to 'clean'
// No the best but it does the job, was focusing on other areas, like using protocols etc
extension Data {
    
    var clean: Data? {
        
        guard var str = String(data: self, encoding: .utf8) else { return nil }
        
        str.filtering(filterItems: String.Replace(pattern: "})", with: "}"),
                      String.Replace(pattern: "jsonFlickrFeed(", with: ""))
        
        return str.data(using: .utf8)
    }
    
}
