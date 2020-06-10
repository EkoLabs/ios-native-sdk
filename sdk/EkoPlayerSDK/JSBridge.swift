//
//  JSBridge.swift
//  EkoPlayerSDK
//
//  Created by Divya on 6/8/20.
//  Copyright © 2020 Divya. All rights reserved.
//

import Foundation
import WebKit

class JSBridge : NSObject {

    static func setUpMessageHandlers(eventHandler: String) -> WKUserScript {
        let messagingScript = """
        window.nativeSdk = {
                postMessage: function(data) {
                    if (data && typeof data !== "string") {
                        data = JSON.stringify(Array.prototype.slice.apply(arguments));
                    }
                    window.webkit.messageHandlers.\(eventHandler).postMessage(data);
                }
        }
        """
        let userScript = WKUserScript(source: messagingScript, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        return userScript
    }
    
    static func buildAction(method: String, args: [Any]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: args, options: []) else {
            return nil
        }
        if let argString = String(data: data, encoding: .utf8) {
            return """
            window.postMessage( {
                type: '\(method)',
                args: \(argString)
            }, '*');
            """
        }
        return nil
    }
    
    static func convertJSONStringToDictionary(jsonString: String) throws -> Dictionary<String, AnyObject>? {
        if let data = jsonString.data(using: .utf8) {
            do {
                let convertedJsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject>
                return convertedJsonDict
                
            } catch let error as NSError {
                throw error
            }
        }
        return nil
    }


}
