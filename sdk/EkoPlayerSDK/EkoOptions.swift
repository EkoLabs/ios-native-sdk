//
//  EkoOptions.swift
//  EkoPlayerSDK
//
//  Created by Divya on 6/4/20.
//  Copyright © 2020 eko. All rights reserved.
//

import Foundation
import UIKit

// Configuration object that sets properties on the player
public class EkoOptions {
    public init() {
        
    }
    public var params : Dictionary<String, String> = ["autoplay": "true"]
    public var events : [String] = []
    public var showCover : Bool = true
    public var customCover : UIView? = nil
    public var environment : String? = nil
}

