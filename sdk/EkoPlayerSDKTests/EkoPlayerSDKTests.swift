//
//  EkoPlayerSDKTests.swift
//  EkoPlayerSDKTests
//
//  Created by Divya on 3/2/20.
//  Copyright © 2020 Divya. All rights reserved.
//

import XCTest
@testable import EkoPlayerSDK

class EkoPlayerSDKTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProjectIdWithWhitespace() {
        let options = EkoOptions()
        let loader = EkoProjectLoader(projectId: "    ", options: options)
        let testExp = expectation(description: "EkoProjectLoader build the url with the project id and runs the callback closure")

        // 2. Exercise the asynchronous code
        loader.getProjectEmbedURL( completionHandler: { (url, metadata) in
            XCTAssert(false)
            testExp.fulfill()
        }, errorHandler: { (error) in
            XCTAssertEqual(error?.localizedDescription, "Invalid project id. Cannot build URL.", "Error description did not match expected description")
            testExp.fulfill()
        })

        // 3. Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testProjectIdWithInvalidCharacters() {
        let options = EkoOptions()
        let loader = EkoProjectLoader(projectId: "AWLL\"13432", options: options)
        let testExp = expectation(description: "EkoProjectLoader build the url with the project id and runs the callback closure")

        // 2. Exercise the asynchronous code
        loader.getProjectEmbedURL(completionHandler: { (url, metadata) in
            XCTAssert(false)
            testExp.fulfill()
        }, errorHandler: { (error) in
            XCTAssertEqual(error?.localizedDescription, "Invalid project id. Cannot build URL.", "Error description did not match expected description")
            testExp.fulfill()
        })

        // 3. Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testInvalidProjectId() {
        let options = EkoOptions()
        let loader = EkoProjectLoader(projectId: "AWLLK2", options: options)
        let testExp = expectation(description: "EkoProjectLoader build the url with the project id and runs the callback closure")

        // 2. Exercise the asynchronous code
        loader.getProjectEmbedURL(completionHandler: { (url, metadata) in
            XCTAssert(false)
            testExp.fulfill()
        }, errorHandler: { (error) in
            XCTAssertEqual(error?.localizedDescription, "Request failed with status code - 404. Potentially invalid project id.", "Error description did not match expected description")
            testExp.fulfill()
        })

        // 3. Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testValidProjectId() {
        let options = EkoOptions()
        let loader = EkoProjectLoader(projectId: "AWLLK1", options: options)
        let testExp = expectation(description: "EkoProjectLoader build the url with the project id and runs the callback closure")

        // 2. Exercise the asynchronous code
        loader.getProjectEmbedURL(completionHandler: { (url, metadata) in
            XCTAssertEqual(url, "https://sdks.eko.com/e4ys3s/cook-eggs-benedict/embed?embedapi=1.0&autoplay=true&events=eko.urls.openinparent,eko.playing", "URL did not match expected URL")
            testExp.fulfill()
        }, errorHandler: { (error) in
            XCTAssert(false)
            testExp.fulfill()
        })

        // 3. Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testCustomConfigOptsAreUsedInUrl() {
        let options = EkoOptions()
        options.params["autoplay"] = "true"
        options.params["debug"] = "true"
        let loader = EkoProjectLoader(projectId: "AWLLK1", options: options)
        let testExp = expectation(description: "EkoProjectLoader build the url with the project id and runs the callback closure")
        // 2. Exercise the asynchronous code
        loader.getProjectEmbedURL(completionHandler: { (url, metadata) in
            XCTAssert(url.contains("autoplay=true"))
            XCTAssert(url.contains("debug=true"))
            XCTAssert(url.contains("events=eko.urls.openinparent,eko.playing"))
            XCTAssert(url.contains("embedapi=1.0"))
            testExp.fulfill()
        }, errorHandler: { (error) in
            XCTAssert(false)
            testExp.fulfill()
        })

        // 3. Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }

    

}
