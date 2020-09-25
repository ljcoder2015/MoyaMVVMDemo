//
//  LJNetworkLoggerPlugin.swift
//  IntelligentDoor
//
//  Created by ljcoder on 2017/11/2.
//  Copyright © 2017年 shanglv. All rights reserved.
//

import UIKit
import Moya

class LJNetworkLoggerPlugin: PluginType {
    
    fileprivate var requestUrl = ""
    
    func willSend(_ request: RequestType, target: TargetType) {
//        print("=========================== Network WillSend ============================")
//        print("willSend URL: \(request.request?.url?.absoluteString ?? "")\nmethod: \(request.request?.httpMethod ?? "")")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
#if DEBUG
        print("=========================== Network Response ============================")
        
        switch result {
        case .success(let response):
            outputItems(logNetworkRequest(response.request))
            print(logNetworkResponse(response.response, data: response.data, target: target))
        case .failure(let error):
            outputItems(logNetworkRequest(error.response?.request))
            print(logNetworkResponse(nil, data: nil, target: target))
        }
        
        print("============================ Network End =============================")
#endif
    }
    
    fileprivate func outputItems(_ items: [String]) {
        for string in items {
            print("\(string)\n")
        }
    }
}

private extension LJNetworkLoggerPlugin {
    
    func format(identifier: String, message: String) -> String {
        return "\(identifier): \(message)"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        
        var output = [String]()
        
        output += [format(identifier: "Request URL", message: request?.url?.absoluteString ?? "(invalid request)")]
        
        if let httpMethod = request?.httpMethod {
            output += [format(identifier: "HTTP Request Method", message: httpMethod)]
        }
        
        if let headers = request?.allHTTPHeaderFields {
            output += [format(identifier: "Request Headers", message: headers.description)]
        }
        
        if let bodyStream = request?.httpBodyStream {
            output += [format(identifier: "Request Body Stream", message: bodyStream.description)]
        }
        
        if let body = request?.httpBody, let stringOutput = String(data: body, encoding: .utf8) {
            output += [format(identifier: "Request Body", message: stringOutput)]
        }
        
        return output
    }
    
    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> Dictionary<String,Any> {
        if response == nil {
            return ["Response":"Received empty network response for \(target)."]
        }
        
        var output: Dictionary<String,Any> = [:]

        if let data = data {
            output["ResponseData"] = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        }
        
        return output
    }
}

