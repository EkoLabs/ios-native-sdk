//
//  EkoPlayerViewTests.swift
//  EkoPlayerSDKTests
//
//  Created by Divya on 4/29/20.
//  Copyright © 2020 eko. All rights reserved.
//

import XCTest
import WebKit
@testable import EkoPlayerSDK

class EkoPlayerViewTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func makeEkoPlayerView() -> EkoPlayerView {
        return EkoPlayerView(frame: CGRect.zero)
    }
    
//    func testLoadingCoverDidHide() {
//        let loadingView = LoadingViewMock()
//        let ekoPlayerView = makeEkoPlayerView()
//        let ekoOptions = EkoOptions()
//        ekoOptions.cover = loadingView
//        ekoPlayerView.load(projectId: "AWLLK1", options: ekoOptions)
//        ekoPlayerView.removeCover()
//        XCTAssertEqual(loadingView.removedFromView, true)
//    }
    
//    func testHideCoverWhenPlayerReady() {
//        let loadingView = LoadingViewMock()
//        let testExp = expectation(description: "The player is ready and the loading view is hidden")
//        let playerDelegate = PlayerViewDelegateMock(event: { (event, data) in
//            XCTAssert(loadingView.removedFromView == true)
//            testExp.fulfill()
//        }) { (error) in
//            XCTAssert(false)
//            testExp.fulfill()
//        }
//        let ekoPlayerView = makeEkoPlayerView()
//        ekoPlayerView.delegate = playerDelegate
//        let ekoOptions = EkoOptions()
//        ekoOptions.cover = loadingView
//        ekoPlayerView.load(projectId: "AWLLK1", options: ekoOptions)
//        let jsonDict = ["type" : "eko.playing"]
//        ekoPlayerView.parseEvent(json: jsonDict as Dictionary<String, AnyObject>)
//        waitForExpectations(timeout: 1) { error in
//          if let error = error {
//            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//          }
//        }
//    }
    
    func testPlayerMessageParsing() {
        let testExp = expectation(description: "onEvent is called when a player event is fired")
        let mockEvent = """
        {"type" : "eko.nodestart",
        "args" : [1]
        }
        """
        let mockScriptMessage = MockScriptMessage(name: "nativeSdk" , body: mockEvent)
        let playerDelegate = PlayerViewDelegateMock(event: { (event, data) in
            XCTAssert(event == "eko.nodestart")
            XCTAssert(!data!.isEmpty)
            if let val = data![0] as? Int {
                XCTAssert(val == 1)
            }
            testExp.fulfill()
        }) { (error) in
            XCTAssert(false)
            testExp.fulfill()
        }
        let ekoPlayerView = makeEkoPlayerView()
        ekoPlayerView.delegate = playerDelegate
        ekoPlayerView.parseMessage(message: mockScriptMessage)
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    func testMalformedPlayerEventData() {
        let errorMsg = "Received malformed event data. Missing event name."
        let testExp = expectation(description: "reports an error and fails gracefully when event name is missing")
        let mockEvent = """
        { "currentNodeId" : "abcsefj_000" }
        """
        let mockScriptMessage = MockScriptMessage(name: "nativeSdk" , body: mockEvent)
        let playerDelegate = PlayerViewDelegateMock(event: { (event, data) in
            XCTAssert(false)
            testExp.fulfill()
        }) { (error) in
            XCTAssertEqual(error.localizedDescription, errorMsg)
            testExp.fulfill()
        }
        let ekoPlayerView = makeEkoPlayerView()
        ekoPlayerView.delegate = playerDelegate
        ekoPlayerView.parseMessage(message: mockScriptMessage)
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    func testURLMessageParsing() {
        let testExp = expectation(description: "onurlsopen is called when a urls.openinparent event is fired")
        let testUrl = "https://eko.com"
        let mockEvent = """
        { "type" : "eko.urls.openinparent",
          "args" : [{"url": "\(testUrl)"}]
        }
        """
        let urlDelegate = UrlDelegateMock { (url) in
            XCTAssert(testUrl == url)
            testExp.fulfill()
        }
        let mockScriptMessage = MockScriptMessage(name: "nativeSdk" , body: mockEvent)
        let playerDelegate = PlayerViewDelegateMock(event: { (event, data) in
            XCTAssert(false)
            testExp.fulfill()
        }) { (error) in
            XCTAssert(false)
            testExp.fulfill()
        }
        let ekoPlayerView = makeEkoPlayerView()
        ekoPlayerView.delegate = playerDelegate
        ekoPlayerView.urlDelegate = urlDelegate
        ekoPlayerView.parseMessage(message: mockScriptMessage)
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testMalformedUrlEvent() {
        let errorMsg = "Received malformed urls open data. Missing url."
        let testExp = expectation(description: "reports an error and fails gracefully if url is missing")
        let mockEvent = """
        { "type" : "eko.urls.openinparent",
        "args" : []
        }
        """
        let mockScriptMessage = MockScriptMessage(name: "nativeSdk" , body: mockEvent)
        let playerDelegate = PlayerViewDelegateMock(event: { (event, data) in
            XCTAssert(false)
            testExp.fulfill()
        }) { (error) in
            XCTAssertEqual(error.localizedDescription, errorMsg)
            testExp.fulfill()
        }
        let ekoPlayerView = makeEkoPlayerView()
        ekoPlayerView.delegate = playerDelegate
        ekoPlayerView.parseMessage(message: mockScriptMessage)
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testCustomMessageParsing() {
        let testExp = expectation(description: "onCustomEvent is called when a custom event is fired")
        let mockEvent = """
        {"type": "recipe.ready",
        "args": [{"recipeId": "tasty_strawberries_v_01"}]
        }
        """
        let mockScriptMessage = MockScriptMessage(name: "nativeSdk" , body: mockEvent)
        let playerDelegate = PlayerViewDelegateMock(event: { (event, data) in
            XCTAssertEqual(event, "recipe.ready")
            if let dict = data![0] as? Dictionary<String, AnyObject> {
                if let recipeId = dict["recipeId"] as? String {
                    XCTAssertEqual(recipeId, "tasty_strawberries_v_01")
                } else {
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
            testExp.fulfill()
        }) { (error) in
            XCTAssert(false)
            testExp.fulfill()
        }
        let ekoPlayerView = makeEkoPlayerView()
        ekoPlayerView.delegate = playerDelegate
        ekoPlayerView.parseMessage(message: mockScriptMessage)
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testMalformedCustomEventData() {
        let errorMsg = "Received malformed event data. Missing event name."
        let testExp = expectation(description: "reports an error and fails gracefully when type is missing.")
        let mockEvent = """
        { "recipeId" : "tasty_strawberries_v_01" }
        """
        let mockScriptMessage = MockScriptMessage(name: "nativeSdk" , body: mockEvent)
        let playerDelegate = PlayerViewDelegateMock(event: { (event, args) in
            XCTAssert(false)
            testExp.fulfill()
        }) { (error) in
            XCTAssertEqual(error.localizedDescription, errorMsg)
            testExp.fulfill()
        }
        let ekoPlayerView = makeEkoPlayerView()
        ekoPlayerView.delegate = playerDelegate
        ekoPlayerView.parseMessage(message: mockScriptMessage)
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    

}

class LoadingViewMock : UIView {
    var removedFromView = false
    override func removeFromSuperview() {
        removedFromView = true
    }
}

class PlayerViewDelegateMock : NSObject, EkoPlayerViewDelegate {
    var eventFn : (String, [Any]?) -> Swift.Void
    var errorFn : (Error) -> Swift.Void
    init(event: @escaping (String, [Any]?) -> Swift.Void,
         error: @escaping (Error) -> Swift.Void)
    {
        eventFn = event
        errorFn = error
        
    }
    func onEvent(event: String, args: [Any]?) {
        eventFn(event, args)
    }
    func onError(error: Error) {
        errorFn(error)
    }
}

class UrlDelegateMock : NSObject, EkoUrlDelegate {
    var urlFn : (String) -> Swift.Void
    init(url: @escaping (String) -> Swift.Void)
    {
        urlFn = url
    }
    func onUrlOpen(url: String) {
        urlFn(url)
    }
}

class MockScriptMessage: WKScriptMessage {
    
    let mockBody: Any
    let mockName: String
    
    init(name: String, body: Any) {
        mockName = name
        mockBody = body
    }
    
    override var body: Any {
        return mockBody
    }
    
    override var name: String {
        return mockName
    }
}
