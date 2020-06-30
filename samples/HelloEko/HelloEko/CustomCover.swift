//
//  CustomCover.swift
//  HelloEko
//
//  Created by Elad Gil on 28/06/2020.
//  Copyright © 2020 Divya. All rights reserved.
//
import UIKit
import Foundation

class CustomCover: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.blue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blue
    }
}
