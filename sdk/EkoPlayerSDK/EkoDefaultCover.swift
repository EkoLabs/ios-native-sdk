//
//  EkoDefaultCover.swift
//  EkoPlayerSDK
//
//  Created by Elad Gil on 28/06/2020.
//  Copyright © 2020 Divya. All rights reserved.
//
import UIKit
import Foundation

class EkoDefaultCover: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.black
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner.color = UIColor.white
        spinner.frame = self.frame
        spinner.startAnimating()
        self.addSubview(spinner)
    }
}
