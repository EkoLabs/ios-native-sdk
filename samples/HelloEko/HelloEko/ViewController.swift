//
//  ViewController.swift
//  HelloEko
//
//  Created by Divya on 6/9/20.
//  Copyright © 2020 Divya. All rights reserved.
//

import UIKit
import EkoPlayerSDK

class ViewController: UIViewController, EkoPlayerViewDelegate, EkoUrlDelegate, EkoShareDelegate {
    
    var portraitBounds : CGRect?
    let loadingView : UIView = UIView()
    let playerView : EkoPlayerView = EkoPlayerView()
    @IBOutlet weak var eventsField: UITextField!
    @IBOutlet weak var projectIdField: UITextField!
    @IBOutlet weak var loadBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var customCoverOn: UISwitch!
    @IBOutlet weak var paramField: UITextField!
    @IBOutlet weak var eventLog: UITextView!
    @IBOutlet weak var envField: UITextField!
    @IBOutlet weak var clearDataBtn: UIButton!
    
    @IBAction func onLoadClicked(_ sender: Any) {
        clearDataBtn.isEnabled = false
        let projectId = projectIdField.text
        let ekoOptions = EkoOptions()
        if (eventsField.text! != "") {
            let customEvents = eventsField.text!.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            ekoOptions.events = customEvents
        }
        if (customCoverOn.isOn) {
            ekoOptions.cover = CustomCover.self
        }
        if (paramField.text! != "") {
            let params = paramField.text!.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            for p in params {
                let keyValPair = p.split(separator: "=")
                let key = String(keyValPair[0])
                let val = String(keyValPair[1])
                ekoOptions.params[key] = val
            }
        }
        if (envField.text! != "") {
            ekoOptions.environment = envField.text!
        }
        playerView.load(projectId: projectId!, options: ekoOptions)
    }
    @IBAction func onPlayClicked(_ sender: Any) {
        playerView.play()
    }
    @IBAction func onPauseClicked(_ sender: Any) {
        playerView.pause()
    }
    
    @IBAction func handleUrlsValueChanged(_ sender: Any) {
        if ((sender as! UISwitch).isOn) {
            playerView.urlDelegate = self
        } else {
            playerView.urlDelegate = nil
        }
    }
    
    @IBAction func handleShareValueChanges(_ sender: Any) {
        if ((sender as! UISwitch).isOn) {
            playerView.shareDelegate = self
        } else {
            playerView.shareDelegate = nil
        }
    }
    
    @IBAction func onClearDataClicked(_ sender: Any) {
        EkoPlayerView.clearData()
    }
    
    func onError(error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.eventLog.text = "\(self.eventLog.text ?? "")\n received error: \(error.localizedDescription)"
        }
    }

    func onEvent(event: String, args: [Any]?) {
        DispatchQueue.main.async {
            if let data = args {
                var str = ""
                for ele in data {
                    str = "\(str), \(ele)"
                }
                self.eventLog.text = "\(self.eventLog.text ?? "")\n received event: \(event) with args: \(str)"
            } else {
                self.eventLog.text = "\(self.eventLog.text ?? "")\n received event: \(event)"
            }
        }
    }
    
    func onUrlOpen(url: String) {
        self.eventLog.text = "\(self.eventLog.text ?? "")\n received url open event for url: \(url)"
    }
    
    func onShare(url: String) {
        self.eventLog.text = "\(self.eventLog.text ?? "")\n received share intent for url: \(url)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingView.backgroundColor = UIColor.blue
        self.view.addSubview(playerView)
        playerView.frame = CGRect(x: 20, y: 369, width: 374, height: 260)
        playerView.delegate = self
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

