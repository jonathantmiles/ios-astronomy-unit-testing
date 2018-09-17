//
//  MarsRoverClientTest.swift
//  AstronomyTests
//
//  Created by Jonathan T. Miles on 9/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import XCTest
@testable import Astronomy

class MockDataLoader: NetworkDataLoader {
    
    init(data: Data?, error: Error?) {
        self.data = data
        self.error = error
    }
    
    func loadData(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        self.request = request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(self.data, self.error)
        }
    }
    
    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        self.url = url
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(self.data, self.error)
        }
    }
    
    let data: Data?
    let error: Error?
    private(set) var request: URLRequest? = nil
    private(set) var url: URL? = nil
}

class MarsRoverClientTest: XCTestCase {
    
    var roverInfo: MarsRover?
    
    
    func testFetchMarsRover() {
        let mock = MockDataLoader(data: validRoverJSON, error: nil)
        let marsRoverClient = MarsRoverClient(networkLoader: mock)
        
        let expectation = self.expectation(description: "Perform MarsRover Client Fetch Expectation")
        marsRoverClient.fetchMarsRover(named: "curiosity") { (rover, error) in
            if let error = error {
                NSLog("Error fetching info for curiosity: \(error)")
                return
            }
            
            self.roverInfo = rover
            // test did it download data (!= nil)
            XCTAssertNotNil(mock.url)
            // test all the attributes of roverInfo against what's expected in the JSON
            XCTAssertEqual(self.roverInfo!.numberOfPhotos, 4156)
            // a lot of XCTAssertEqual
            XCTAssertEqual(self.roverInfo!.solDescriptions.count, 5)
            XCTAssertEqual(self.roverInfo!.name, "Curiosity")
            
            // then also load up an expectation
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    // test fetchPhotos
    
    func testFetchPhotos() {
        let mock = MockDataLoader(data: validSol1JSON, error: nil)
        let marsRoverClient = MarsRoverClient(networkLoader: mock)
        
        let expectation = self.expectation(description: "Perform MarsRover Fetch Photos Expectation")
        
        var photoReferences: [MarsPhotoReference]?
        
        // for the purposes of fetching Photos without changing the source function I created a rover with the relevant .name for fetching within the function. All the other values are very generous.
        let solDescriptions = [SolDescription]()
        let rover = MarsRover(name: "Curiosity", launchDate: Date(), landingDate: Date(), status: .active, maxSol: 1000, maxDate: Date(), numberOfPhotos: 9999999, solDescriptions: solDescriptions)
         
        marsRoverClient.fetchPhotos(from: rover, onSol: 1) { (photoRefs, error) in
            if let e = error { NSLog("Error fetching photos for \(rover.name) on sol 1: \(e)"); return }
            photoReferences = photoRefs
            
            XCTAssertNotNil(mock.url)
            
            XCTAssertEqual(photoReferences!.count, 16)
            let firstObject = photoReferences!.first
            XCTAssertEqual(firstObject!.id, 4477)
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    // same as above, but for sol1JSON data
    
}
