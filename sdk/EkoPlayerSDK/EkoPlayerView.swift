//
//  EkoPlayerView.swift
//  EkoPlayerSDK
//
//  Created by Divya on 3/2/20.
//  Copyright © 2020 eko. All rights reserved.
//

import UIKit
import WebKit

enum PlayerEventError : LocalizedError {
    case unknownEventReceived(message: String)
    case malformedEventData(message: String)
    var errorDescription: String? {
        switch self {
        case let .unknownEventReceived(message), let .malformedEventData(message):
                return message
        }
    }
}

@IBDesignable public class EkoPlayerView: UIView, WKScriptMessageHandler, WKNavigationDelegate {

    public weak var delegate : EkoPlayerViewDelegate?
    public weak var urlDelegate : EkoUrlDelegate?
    public weak var shareDelegate : EkoShareDelegate?
    public var appName : String? {
        didSet {
            setCustomUserAgent(completionHandler: onUserAgentGenerated, errorHandler: onUserAgentError)
        }
    }
    private var webView : WKWebView?
    private var fakeWebView : WKWebView?
    private var projectLoadQueue : [EkoProjectLoader] = []
    private let eventHandlerName = "nativeSdk"
    private var isLoaded = false
    private var willAutoplay = false
    private var cover : UIView?
    private var readyEvent : String = "eko.canplay"
    private var playingEvent : String = "eko.playing"
    
    public class func clearData() {
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
           records.forEach { record in
               WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
           }
        }
    }

    // MARK: init code
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // TODO: Figure out if this should take in a config obj too?
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        // TODO: Figure out if this should take in a config obj too?
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.black
        initializeWebView()
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }

    // internal initialization function that handles creating the webview
    func initializeWebView() {
        // Create content controller for project
        let contentController = WKUserContentController()
        let listenerUserScript = JSBridge.setUpMessageHandlers(eventHandler: eventHandlerName)
        contentController.addUserScript(listenerUserScript)
        // Subscribe to all events
        contentController.add(self, name: eventHandlerName)
        
        // Create the web configuration for this project
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.userContentController = contentController

        // Create the webview
        let newWebView = WKWebView(frame: self.bounds, configuration: webConfiguration)
        self.webView = newWebView
        newWebView.navigationDelegate = self
        self.addSubview(newWebView)
    }

    @objc func willResignActive() {
        if (isLoaded) {
            self.pause();
        }
    }
    // Set the custom user agent per app name specified in config
    func setCustomUserAgent(completionHandler: @escaping (String) -> Swift.Void, errorHandler: @escaping (Error?) -> Swift.Void) {
        if let wv = self.webView {
            if (wv.customUserAgent == "") {
                let aName: String?;
                if (self.appName != nil) {
                    aName = self.appName;
                } else {
                    aName = Bundle.main.bundleIdentifier;
                }
                
                let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                let sdkVersion = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                
                // Swift has this annoying thing that once you use "navigator.userAgent" you can't
                // change the customUserAgent property of the webview. So, workaround is to create
                // a fake webview to get the current user agent, and then append the app name and
                // OS System version to that
                self.fakeWebView = WKWebView()
                
                self.fakeWebView?.evaluateJavaScript("navigator.userAgent") { (result, error) in
                
                    self.fakeWebView = nil
                    // Don't set custom user agent if unable to get current user agent
                    if let err = error {
                        errorHandler(err)
                    } else {
                        // Otherwise, get the current user agent as a string
                        let userAgent = result as? String
                        if let ua = userAgent, let name = aName, let app = appVersion, let sdk = sdkVersion {
                            // Create the custom user agent and assign it
                            let customUA = "\(ua) - ekoNativeSDK/\(sdk) - \(name)/\(app)"
                            completionHandler(customUA)
                        }
                    }
                }
            }
        }
    }
    
    func onUserAgentGenerated(customUserAgent: String) {
        
        self.webView?.customUserAgent = customUserAgent
        if (!self.projectLoadQueue.isEmpty) {
            for projectLoader in self.projectLoadQueue {
                projectLoader.getProjectEmbedURL(
                    completionHandler: onProjectEmbedLoaded,
                    errorHandler: onProjectEmbedFailed)
            }
            self.projectLoadQueue = []
        }
    }
    
    func onUserAgentError(error: Error?) {
        if let e = error {
            self.delegate?.onError(error: e)
        }
    }
    
    // MARK: layout code
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.webView?.frame = self.bounds
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) {
            // clean up webview delegates. Delegates and script message handlers are
            // strong references, so need to remove them otherwise memory leak will occur
            self.webView?.uiDelegate = nil
            self.webView?.navigationDelegate = nil
            self.webView?.configuration.userContentController.removeAllUserScripts()
            self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: eventHandlerName)
            self.webView = nil
        }
    }

    // MARK: Load functionality
    
    // Will actually load and display an eko video.
    // The EkoPlayerView will display some loading animation while it prepares the project for playback
    public func load(projectId: String, options: EkoOptions) {
        // If the view has been created from the storyboard, and they haven't set the config,
        // initialize a webview with the default values
        isLoaded = false
        if (self.webView == nil) {
            initializeWebView()
        }
        
        if let wv = self.webView {
            wv.isHidden = true
            self.willAutoplay = options.params["autoplay"] == "true"
            if (options.cover != nil) {
                self.addCover(cover: options.cover!)
            }
            
            // Making an assumption here that we don't want to load the project
            // until we set the user agent
            let projectLoader = EkoProjectLoader(projectId: projectId, options: options)
            if (!((wv.customUserAgent ?? "").isEmpty)) {
                projectLoader.getProjectEmbedURL(
                    completionHandler: onProjectEmbedLoaded,
                    errorHandler: onProjectEmbedFailed)
            } else {
                if (self.appName == nil) {
                    self.setCustomUserAgent(completionHandler: onUserAgentGenerated, errorHandler: onUserAgentError)
                }
                self.projectLoadQueue.append(projectLoader)
            }
        }
    }
    
    public func play() {
        self.invoke(method: "eko.play", args: [""]) { (error) in
            self.delegate?.onError(error: error)
        }
    }
    
    public func pause() {
        self.invoke(method: "eko.pause", args: [""]) { (error) in
            self.delegate?.onError(error: error)
        }
    }
    
    public func invoke(method: String, args: [Any], errorHandler: @escaping (Error) -> Swift.Void) {
        if let fnString = JSBridge.buildAction(method: method, args: args) {
            self.webView?.evaluateJavaScript(fnString, completionHandler: { (result, error) in
                if let e = error {
                    errorHandler(e)
                }
            })
        }
    }

    func addCover(cover: UIView.Type) {
        self.cover = cover.init(frame: self.bounds)
        self.addSubview(self.cover!)
    }
    
    func removeCover() {
        self.cover?.removeFromSuperview()
    }
    
    func onProjectEmbedLoaded(projectEmbedUrl: String, projectMetadata: Dictionary<String, AnyObject>?) {
        if let metadata = projectMetadata {
            self.delegate?.onEvent(event: "metadata", args: [metadata])
        }
        if let myURL = URL(string:projectEmbedUrl) {
            let myRequest = URLRequest(url: myURL)
            DispatchQueue.main.async {
                self.webView?.load(myRequest)
            }
        }
    }
    
    func onProjectEmbedFailed(error: Error?) {
        DispatchQueue.main.async {
            self.removeCover()
        }
        if let err = error {
            self.delegate?.onError(error: err)
        }
    }
    
    func getParentUIViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    // MARK: Delegate functions
    // WKNavigationDelegate function
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.onError(error: error)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView?.isHidden = false
    }
    
    // Implementation of WKScriptMessageHandler that will forward events to delegate
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.parseMessage(message: message)
    }
    
    // MARK: Event Handling
    func parseEvent(json: Dictionary<String, AnyObject>) {
        if let eventName = json["type"] as? String {
            
            // player should be defined by now. Add custom event listeners.
            if ((self.willAutoplay && eventName == self.playingEvent) ||
                (!self.willAutoplay && eventName == self.readyEvent)) {
                isLoaded = true
                self.removeCover()
            }

            // the URL might not be encoded, so encode it before passing it to the delegate
            if (eventName == "eko.urls.openinparent") {
                if let args = json["args"] as? Array<AnyObject> {
                    if !args.isEmpty, let urlString = args[0]["url"] as? String {
                         if let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            DispatchQueue.main.async {
                                if let urlOpener = self.urlDelegate {
                                    urlOpener.onUrlOpen(url: escapedString)
                                } else {
                                    if let urlObj = URL(string: escapedString) {
                                            UIApplication.shared.open(urlObj)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        let urlError = PlayerEventError.malformedEventData(message: "Received malformed urls open data. Missing url.")
                        self.delegate?.onError(error: urlError)
                    }
                } else {
                    let urlError = PlayerEventError.malformedEventData(message: "Received malformed urls open data. Missing args.")
                    self.delegate?.onError(error: urlError)
                }
            } else if (eventName == "eko.share.intent") {
                if let args = json["args"] as? Array<AnyObject> {
                    if !args.isEmpty, let urlString = args[0]["url"] as? String {
                         if let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            DispatchQueue.main.async {
                                if let shareOpener = self.shareDelegate {
                                    shareOpener.onShare(url: escapedString)
                                } else {
                                    if let urlObj = URL(string: escapedString) {
                                        let activity = UIActivityViewController(activityItems: [urlObj], applicationActivities: nil)
                                        self.getParentUIViewController()?.present(activity, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        let urlError = PlayerEventError.malformedEventData(message: "Received malformed share data. Missing url.")
                        self.delegate?.onError(error: urlError)
                    }
                } else {
                    let urlError = PlayerEventError.malformedEventData(message: "Received malformed share data. Missing args.")
                    self.delegate?.onError(error: urlError)
                }
            } else {
                let args = json["args"] as? [Any]
                self.delegate?.onEvent(event: eventName, args: args)
            }
            
        } else {
            let error = PlayerEventError.malformedEventData(message: "Received malformed event data. Missing event name.")
            self.delegate?.onError(error: error)
        }
    }
    
    func parseMessage(message: WKScriptMessage) {
        if let arguments = message.body as? String {
            do {
                let convertedDict = try JSBridge.convertJSONStringToDictionary(jsonString: arguments)
                if let jsonObj = convertedDict {
                    switch message.name {
                    case eventHandlerName:
                        parseEvent(json: jsonObj)
                        break
                    default:
                        let errorMsg = "Received an unknown event. Received: \(message.name)"
                        let error = PlayerEventError.unknownEventReceived(message:errorMsg)
                        self.delegate?.onError(error: error)
                        break
                    }
                }
            } catch let error as NSError {
                let errorMsg = "Received malformed event data. Received: \(arguments) with error: \(error.localizedDescription)"
                let playerError = PlayerEventError.malformedEventData(message: errorMsg)
                self.delegate?.onError(error: playerError)
            }
        }
        
    }
}
