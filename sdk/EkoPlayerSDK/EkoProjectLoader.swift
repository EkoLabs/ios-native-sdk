//
//  EkoProjectLoader.swift
//  EkoPlayerSDK
//
//  Created by Divya on 3/13/20.
//  Copyright © 2020 Divya. All rights reserved.
//

import Foundation

enum LoadingError : LocalizedError {
    case requestError(message: String)
    case malformedResponse(message: String)
    case statusCode(message: String)
    case invalidProjectId(message: String)
    var errorDescription: String? {
        switch self {
        case let .requestError(message), let .malformedResponse(message), let .statusCode(message), let .invalidProjectId(message):
                return message
        }
    }
}

class EkoProjectLoader: NSObject {
    private var projectId: String
    private var urlParam: String = ""
    private let projectIDEndpoint : String = "/api/v1/projects/"
    private var defaultEvents = ["eko.urls.openinparent"]
    private var env : String = ""
    init(projectId: String, options: EkoOptions) {
        self.projectId = projectId
        for (key, value) in options.params {
            urlParam = "\(urlParam)&\(key)=\(value)"
        }
        if (options.showCover) {
            if (options.params["autoplay"] == "true") {
                defaultEvents.append("eko.playing")
            } else {
                defaultEvents.append("eko.canplay")
            }
        }
        options.events += defaultEvents
        let eventList = options.events.joined(separator: ",")
        urlParam = "\(urlParam)&events=\(eventList)"
        if let environment = options.environment {
            env = "\(environment)."
        }
    }
    
    func parseForError(json: NSDictionary) -> String? {
        var errorMsg : String?
        if let err = json["error"] as? String {
            errorMsg = err
            if let description = json["message"] as? String {
                errorMsg = "\(err) - \(description)"
            }
        }
        return errorMsg
    }
    
    func buildEmbedUrl(json: NSDictionary?) throws -> String? {
        var totalUrl : String?
        if let data = json {
            // Check for errors and throw a request error if necessary
            if let errorMsg = self.parseForError(json: data) {
                throw LoadingError.requestError(message: errorMsg)
            } else {
                // attempt to get the embed url from the response, throw an error if unable to
                if let projectEmbed = data["embedUrl"] as? String {
                    totalUrl = "\(projectEmbed)?embedapi=1.0\(urlParam)"
                } else {
                    throw LoadingError.malformedResponse(message: "Embed url not found - Missing embed url in response")
                }
            }
        }
        return totalUrl
    }
    
    func getProjectEmbedURL(completionHandler: @escaping (String, Dictionary<String, AnyObject>?) -> Swift.Void, errorHandler: @escaping (Error?) -> Swift.Void) {
        // build the url out of the endpoint and the passed in project id
        let urlString = "https://\(env)eko.com" + projectIDEndpoint + self.projectId
        if let balooUrl = URL(string: urlString) {
            
            // create the request
            let request = URLRequest(url: balooUrl)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // parse for error
                if let err = error {
                    errorHandler(err)
                    return
                }
                // check the status code and return an error if that fails
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    if (statusCode < 200 || statusCode > 300) {
                        errorHandler(LoadingError.statusCode(message: "Request failed with status code - \(statusCode). Potentially invalid project id."))
                        return
                    }
                }

                // check the returned data and attempt to build an embed url out of it
                if let dataDict = data {
                    do {
                        let convertedJsonDict = try JSONSerialization.jsonObject(with: dataDict, options: []) as? NSDictionary;
                        if let embedUrl = try self.buildEmbedUrl(json: convertedJsonDict) {
                            var metadata : Dictionary<String, AnyObject>? = nil
                            if let jsonDict = convertedJsonDict {
                                if let projectMetadata = jsonDict["metadata"] as? Dictionary<String, AnyObject> {
                                    if (!projectMetadata.isEmpty) {
                                        metadata = projectMetadata
                                    }
                                }
                            }
                            completionHandler(embedUrl, metadata)
                        }
                        
                    } catch let error as NSError {
                        errorHandler(error)
                    }
                        
                }
            }
            task.resume()
        } else {
            errorHandler(LoadingError.invalidProjectId(message: "Invalid project id. Cannot build URL."))
        }
        
    }
}
