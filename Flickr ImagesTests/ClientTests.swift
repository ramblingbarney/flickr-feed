//
//  ClientTests.swift
//  Flickr ImagesTests
//
//  Created by Consultant on 07/08/2019.
//  Copyright © 2019 Consultant. All rights reserved.
//


import XCTest
@testable import Flickr_Images

class ClientTests: XCTestCase {

    let defaultTimeout = 15.0
    var systemUnderTest: FlickrClient!
    
    override func setUp() {
        systemUnderTest = FlickrClient()
    }
    
    override func tearDown() {
        systemUnderTest = nil
    }
    
    func testValidAPIConnectionWithNoTags() {
        
        let request = FlickrRequest.publicPhotos(tags: nil)
        let promise = expectation(description: "Valid API Connection")
        
        systemUnderTest.getFeed(from: request) { result in
            promise.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    func testReceivedDataFromServerWithNoTags() {
        
        let request = FlickrRequest.publicPhotos(tags: nil)
        let promise = expectation(description: "Received Data from API")
        var connectionResult: Result<Data, APIError>?
        
        systemUnderTest.getFeed(from: request) { result in
            connectionResult = result
            promise.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        guard let actualResult = connectionResult else { return XCTFail() }
        
        switch actualResult {
        case .success(_): break
        case .failure(let error): XCTFail(error.localizedDescription)
        }
    }
    
    func testValidAPIConnectionWithMultipleTags() {
        
        let request = FlickrRequest.publicPhotos(tags: ["dog", "cat"])
        let promise = expectation(description: "Valid API Connection")
        
        systemUnderTest.getFeed(from: request) { result in
            promise.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    func testReceivedDataFromServerWithMultipleTags() {
        
        let request = FlickrRequest.publicPhotos(tags: ["dog", "cat"])
        let promise = expectation(description: "Received Data from API")
        var connectionResult: Result<Data, APIError>?
        
        systemUnderTest.getFeed(from: request) { result in
            connectionResult = result
            promise.fulfill()
        }
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        guard let actualResult = connectionResult else { return XCTFail() }
        
        switch actualResult {
        case .success(_): break
        case .failure(let error): XCTFail(error.localizedDescription)
        }
    }
}
