//
//  RequestTests.swift
//  Flickr ImagesTests
//
//  Created by Consultant on 07/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//

import XCTest
@testable import Flickr_Images

class RequestTests: XCTestCase {
    
    let expectedUrlComps = URLComponents(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json")!
    
    var systemUnderTest: FlickrRequest!
    
    override func setUp() {
        super.setUp()
        systemUnderTest = FlickrRequest.publicPhotos(tags: nil)
    }
    
    override func tearDown() {
        systemUnderTest = nil
        super.tearDown()
    }
    
    
    func testCreatePublicPhotosNoTags_NonNilURLComps() {
        
        // When - We create the URLComponents
        let urlComps = systemUnderTest.urlComponents
        
        // Then - The URLComponents should be NOT be nil
        XCTAssertNotNil(urlComps)
    }
    
    func testCreatePublicPhotosNoTags_NonNilURL() {

        // When - We create the URL
        let urlComps = systemUnderTest.urlComponents?.url
        
        // Then - The URL should be NOT be nil
        XCTAssertNotNil(urlComps)
    }
    
    func testCreatePublicPhotosWithSingleTag_NonNilURLComps() {
        
        let sut = FlickrRequest.publicPhotos(tags: ["dog"])
        
        // When - We create the URLComponents
        let urlComps = sut.urlComponents
        
        // Then - The URLComponents should be NOT be nil
        XCTAssertNotNil(urlComps)
    }
    
    func testCreatePublicPhotosWithSingleTag_NonNilURL() {
        
         let sut = FlickrRequest.publicPhotos(tags: ["dog"])
        
        // When - We create the URL
        let urlComps = sut.urlComponents?.url
        
        // Then - The URL should be NOT be nil
        XCTAssertNotNil(urlComps)
    }
    
    func testCreatePublicPhotosWithMultipleTags_NonNilURLComps() {
        
        let sut = FlickrRequest.publicPhotos(tags: ["dog", "cat"])
        
        // When - We create the URLComponents
        let urlComps = sut.urlComponents
        
        // Then - The URLComponents should be NOT be nil
        XCTAssertNotNil(urlComps)
    }
    
    func testCreatePublicPhotosWithMultipleTags_NonNilURL() {
        
        let sut = FlickrRequest.publicPhotos(tags: ["dog", "cat"])
        
        // When - We create the URL
        let urlComps = sut.urlComponents?.url
        
        // Then - The URL should be NOT be nil
        XCTAssertNotNil(urlComps)
    }
    
    func testsValidHost() {
        
        guard let urlComps = systemUnderTest.urlComponents else {
            XCTFail("Invalid Comps \(String(describing: systemUnderTest.urlComponents))")
            return
        }
        
        let result = urlComps.host?.caseInsensitiveCompare(expectedUrlComps.host!)
        
        XCTAssertEqual(result, ComparisonResult.orderedSame, "Invalid API Host")
    }
    
    func testsValidPath() {
        
        guard let urlComps = systemUnderTest.urlComponents else {
            XCTFail("Invalid Comps \(String(describing: systemUnderTest.urlComponents))")
            return
        }
        
        let result = urlComps.path.caseInsensitiveCompare(expectedUrlComps.path)
        
        XCTAssertEqual(result, ComparisonResult.orderedSame, "Invalid API Path")
    }
    
}

