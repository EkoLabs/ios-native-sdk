//
//  EkoUrlDelegate.swift
//  EkoPlayerSDK
//
//  Created by Divya on 6/4/20.
//  Copyright © 2020 eko. All rights reserved.
//

import Foundation

public protocol EkoUrlDelegate: AnyObject {

    // This function will be called whenever a url must be opened
    func onUrlOpen(url: String)
}

