//
//  EkoShareDelegate.swift
//  EkoPlayerSDK
//
//  Created by Elad Gil on 23/06/2020.
//  Copyright © 2020 Divya. All rights reserved.
//

import Foundation

public protocol EkoShareDelegate: AnyObject {

    // There can be share intents from within an eko project via share buttons or ekoshell. This function will be called whenever a share intent happened.
    func onShare(url: String)
}
