//
//  EkoEventBridgeTests.swift
//  EkoPlayerSDKTests
//
//  Created by Divya on 4/29/20.
//  Copyright © 2020 eko. All rights reserved.
//

import XCTest
import WebKit
@testable import EkoPlayerSDK
class EkoEventBridgeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testMessageHandlerDefinesWindowObject() {
        let userScript = JSBridge.setUpMessageHandlers(eventHandler: "nativeSdk")
        XCTAssert(userScript.source.contains("window.nativeSdk ="))
        
    }
    
    func testMessageHandlerDefinesPostMessageFn() {
        let userScript = JSBridge.setUpMessageHandlers(eventHandler: "nativeSdk")
        XCTAssert(userScript.source.contains("postMessage: function"))
    }
    
    func testMessageHandlerPostsMessageForEventHandler() {
        
        let eventHandlerName = "eventHandlerName"
        let userScript = JSBridge.setUpMessageHandlers(eventHandler: eventHandlerName)
        XCTAssert(userScript.source.contains("window.webkit.messageHandlers.\(eventHandlerName)"))
    }
    
    
    func testStringToDictionaryConversion() {
        let testString = """
        {"testField": "abcdef"}
        """
        do {
            let dict = try JSBridge.convertJSONStringToDictionary(jsonString: testString)
            XCTAssert(dict != nil)
            if let d = dict {
                XCTAssert(d["testField"] != nil)
                XCTAssert((d["testField"] as? String) != nil)
            }
            
        } catch _ as NSError {
            XCTAssert(false)
        }
    }

}
