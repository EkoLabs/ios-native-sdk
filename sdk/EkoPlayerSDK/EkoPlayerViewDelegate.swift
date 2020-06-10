//
//  EkoPlayerViewDelegate.swift
//  ekoSDKSampleApp
//
//  Created by Divya on 2/26/20.
//  Copyright © 2020 Divya. All rights reserved.
//

import Foundation

public protocol EkoPlayerViewDelegate {

    // This function will be called whenever a specified event is triggered
    // within the player. The list of events can be found on the eko dev site.
    func onEvent(event: String, args: [Any]?)
    
    // Called whenever the player triggers an 'error' event
    func onError(error: Error)
}
