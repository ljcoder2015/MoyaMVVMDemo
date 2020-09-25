//
//  Enum.swift
//  IntelligentDoor
//
//  Created by ljcoder on 2017/9/30.
//  Copyright © 2017年 shanglv. All rights reserved.
//

import Foundation
import UIKit

enum ChatType {
    case C2C
    case C2C_GROUP
    case GROUP
}

enum LJResult {
    case ok(message: String)
    case empty
    case failed(message: String)
}

extension LJResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension LJResult {

    var description: String {
        switch self {
        case .ok(let message):
            return message
        case .failed(let message):
            return message
        default:
            return ""
        }
    }
}

// MARK: Dictionary to json
extension NSDictionary {
    func toJSON() -> String {
        
        var data: Data = Data()
        do {
            data = try JSONSerialization.data(withJSONObject: self, options: .init(rawValue: 0))
        }
        catch let error {
            print(error)
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

// MARK: LJError
enum LJError: Error {
    case EmptyError
    case RequestError
    case DecodeError
    case repeatRequestError
    case TokenError
}

// MARK: LJResponse
public enum LJResponse<T> {
    case Success(T)
    case Failed(Error)
}

extension LJResponse {
    
    var isSuccess: Bool {
        switch self{
        case .Success:
            return true
        case .Failed:
            return false
        }
    }
    
    var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failed(let error):
            return error
        }
    }
    
    var data: T? {
        switch self {
        case LJResponse.Success(let value): return value
        case LJResponse.Failed: return nil
        }
    }
    
    func map<U>(f: (T)->U) -> LJResponse<U> {
        switch self {
        case .Success(let t): return .Success(f(t))
        case .Failed(let err): return .Failed(err)
        }
    }
    
    func flatMap<U>(f: (T)->LJResponse<U>) -> LJResponse<U> {
        switch self {
        case .Success(let t): return f(t)
        case .Failed(let err): return .Failed(err)
        }
    }
}
