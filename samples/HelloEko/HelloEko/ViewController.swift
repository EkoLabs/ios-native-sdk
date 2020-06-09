//
//  ViewController.swift
//  HelloEko
//
//  Created by Divya on 6/9/20.
//  Copyright © 2020 Divya. All rights reserved.
//

import UIKit
import EkoPlayerSDK

class ViewController: UIViewController, EkoPlayerViewDelegate, EkoUrlDelegate {

    var portraitBounds : CGRect?
    let loadingView : UIView = UIView()
    
    @IBOutlet weak var eventsField: UITextField!
    @IBOutlet weak var projectIdField: UITextField!
    @IBOutlet weak var loadBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var customCoverOn: UISwitch!
    @IBOutlet weak var paramField: UITextField!
    @IBOutlet weak var playerView: EkoPlayerView!
    @IBOutlet weak var eventLog: UITextView!

    @IBAction func onLoadClicked(_ sender: Any) {
        let projectId = projectIdField.text
        let ekoConfig = EkoOptions()
        if (eventsField.text! != "") {
            let customEvents = eventsField.text!.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            ekoConfig.events = customEvents
        }
        if (customCoverOn.isOn) {
            ekoConfig.customCover = loadingView
        }
        if (paramField.text! != "") {
            let params = paramField.text!.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            for p in params {
                let keyValPair = p.split(separator: "=")
                let key = String(keyValPair[0])
                let val = String(keyValPair[1])
                ekoConfig.params[key] = val
            }
        }
        playerView?.load(projectId: projectId!, options: ekoConfig)
    }
    @IBAction func onPlayClicked(_ sender: Any) {
        playerView?.play()
    }
    @IBAction func onPauseClicked(_ sender: Any) {
        playerView?.pause()
    }
    
    func onError(error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.eventLog.text = "\(self.eventLog.text ?? "")\n received error: \(error.localizedDescription)"
        }
    }

    func onEvent(event: String, args: [Any]?) {
        DispatchQueue.main.async {
            self.eventLog.text = "\(self.eventLog.text ?? "")\n received event: \(event)"
        }
    }
    
    func onUrlOpen(url: String) {
        if let urlObj = URL(string: url) {
            DispatchQueue.main.async {
                self.eventLog.text = "\(self.eventLog.text ?? "")\n received url open event for url: \(url)"
                UIApplication.shared.open(urlObj)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingView.backgroundColor = UIColor.blue
        playerView.delegate = self
        playerView.urlDelegate = self
        playerView.appName = "SampleApp"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (UIDevice.current.orientation.isLandscape) {
            projectIdField.isHidden = true
            eventsField.isHidden = true
            eventLog.isHidden = true
            loadBtn.isHidden = true
            playBtn.isHidden = true
            pauseBtn.isHidden = true
            customCoverOn.isHidden = true
            playerView.frame = self.view.bounds
            
        } else if let newBounds = portraitBounds {
            playerView.frame = newBounds
            projectIdField.isHidden = false
            eventsField.isHidden = false
            eventLog.isHidden = false
            loadBtn.isHidden = false
            playBtn.isHidden = false
            pauseBtn.isHidden = false
            customCoverOn.isHidden = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if (portraitBounds == nil) {
            portraitBounds = playerView.frame
        }
    }


}

