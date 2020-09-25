//
//  Moya+Extension.swift
//  IntelligentDoor
//
//  Created by ljcoder on 2017/9/28.
//  Copyright © 2017年 shanglv. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import RxCocoa
import RxSwift
import SVProgressHUD

// Data Key
let LJStatusError = false
let LJDataKey = "data"
let LJStatusKey = "status"
let LJCodekey = "code"
let LJMessagekey = "message"
let LJTotalPage = "totalPage"

extension TargetType {
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: "https://www.ljcoder.com/")! }
    var method: Moya.Method { return .post }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool { return true }
    
    // The headers to be used in the request.
    var headers: [String: String]? {
        return nil
    }

}

// MARK: Refresh Token
public extension Reactive where Base: MoyaProviderType {
    
    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
        return Single.create { [weak base] single in
                let cancellableToken = base?.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                    switch result {
                    case let .success(response):
                        if response.status {
                            single(.success(response))
                        }
                        else {
                            if response.code == 10001 {
                                single(.error(LJError.TokenError))
                            }
                            else {
                                single(.success(response))
                            }
                        }
                    case let .failure(error):
                        single(.error(error))
                    }
                }
            
                return Disposables.create {
                    cancellableToken?.cancel()
                }
            }
//            .retryWhen { (e) in
//                return Observable.zip(e, Observable.range(start: 1, count: 1), resultSelector: { $1 })
//                    .flatMap { i in
//                        return LJTokenProvider.rx.request(LJTokenAPI.refreshToken(refreshToken: LJUserModel.read().refresh_token ?? ""))
//                            .asObservable()
//                            .mapObject(LJUserModel.self)
//                            .filter({ (result) -> Bool in
//                                return result.isSuccess
//                            })
//                            .flatMapLatest({
//                                token -> Observable<LJResponse<LJUserModel>> in
//                                let user = token.data
//                                user?.TLSSig = LJUserModel.read().TLSSig
//                                user?.save()
//                                return Observable.just(token)
//                            })
//                }
//            }
    }
}

extension Response {
    
    var status: Bool {
        get {
            do {
                let optionDictionary = try self.mapJSON() as? Dictionary<String, Any>
                guard let dictionary = optionDictionary else {
                    throw MoyaError.jsonMapping(self)
                }
                let optionStatus = dictionary[LJStatusKey] as? Bool
                if let status = optionStatus {
                    return status
                }
                return LJStatusError
            }
            catch {
                return LJStatusError
            }
        }
    }
    
    var message: String {
        get {
            do {
                let optionDictionary = try self.mapJSON() as? Dictionary<String, Any>
                guard let dictionary = optionDictionary else {
                    throw MoyaError.jsonMapping(self)
                }
                let optionmessage = dictionary[LJMessagekey] as? String
                if let message = optionmessage {
                    return message
                }
                return ""
            }
            catch {
                return ""
            }
        }
    }
    
    var content: Any? {
        get {
            do {
                let optionDictionary = try self.mapJSON() as? Dictionary<String, Any>
                guard let dictionary = optionDictionary else {
                    throw MoyaError.jsonMapping(self)
                }
                if status {
                    let optionData = dictionary[LJDataKey]
                    if let data = optionData {
                        return data
                    }
                }
                return nil
            }
            catch {
                return nil
            }
        }
    }
    
    var responseData: Any? {
        get {
            do {
                let optionDictionary = try self.mapJSON() as? Dictionary<String, Any>
                guard let dictionary = optionDictionary else {
                    throw MoyaError.jsonMapping(self)
                }
                let optionData = dictionary["data"]
                if let data = optionData {
                    return data
                }
                return nil
            }
            catch {
                return nil
            }
        }
    }
    
    var code: Int? {
        get {
            do {
                let optionDictionary = try self.mapJSON() as? Dictionary<String, Any>
                guard let dictionary = optionDictionary else {
                    throw MoyaError.jsonMapping(self)
                }
                let optionCode = dictionary["code"] as? Int
                
                return optionCode
            }
            catch {
                return nil
            }
        }
    }
    
    /// 解析成Dictionary
    func mapDictionary() -> LJResponse<Dictionary<String, Any>> {
        if !status {
            if message.count > 0 {
                SVProgressHUD.showError(withStatus: message)
            }
            return LJResponse<Dictionary<String, Any>>.Failed(LJError.RequestError)
        }
        
        if message.count > 0 {
            SVProgressHUD.showSuccess(withStatus: message)
        }
        
        if content is Dictionary<String, Any> {
            return LJResponse.Success(content as! Dictionary<String, Any>)
        }
        else {
            return LJResponse.Success(Dictionary<String, Any>())
        }
    }
    
    /// 解析成基本类型数组, 如: [String]
    func mapNormalArray<T>(_ type: T.Type) -> LJResponse<[T]> {
        if !status {
            if message.count > 0 {
                SVProgressHUD.showError(withStatus: message)
            }
            return LJResponse<[T]>.Failed(LJError.RequestError)
        }
        
        if message.count > 0 {
            SVProgressHUD.showSuccess(withStatus: message)
        }
        
        if content is Array<T> {
            return LJResponse.Success(content as! [T])
        }
        else {
            return LJResponse.Success([])
        }
    }
    /// 解析成基本类型, 如: String
    func mapNormalType<T>(_ type: T.Type) -> LJResponse<T> {
        if !status {
            if message.count > 0 {
                SVProgressHUD.showError(withStatus: message)
            }
            return LJResponse<T>.Failed(LJError.RequestError)
        }
        
        if message.count > 0 {
            SVProgressHUD.showSuccess(withStatus: message)
        }
        
        if content is T {
            return LJResponse.Success(content as! T)
        }
        else {
            return LJResponse.Failed(LJError.DecodeError)
        }
    }
    
    /// 解析成Model
    func mapObject<T: BaseMappable>(_ type: T.Type) -> LJResponse<T> {
        if !status {
            if message.count > 0 {
                SVProgressHUD.showError(withStatus: message)
            }
            return LJResponse<T>.Failed(LJError.RequestError)
        }
        
        if message.count > 0 {
            SVProgressHUD.showSuccess(withStatus: message)
        }
        
        guard let object = Mapper<T>().map(JSONObject: content) else {
            return LJResponse<T>.Failed(MoyaError.jsonMapping(self))
        }
        return LJResponse.Success(object)
    }
    /// 解析成Model数组,不分页, 如 [LJProcutModel]
    func mapArray<T: BaseMappable>(_ type: T.Type) -> LJResponse<[T]> {
        if !status {
            if message.count > 0 {
                SVProgressHUD.showError(withStatus: message)
            }
            return LJResponse<[T]>.Failed(LJError.RequestError)
        }
        
        if message.count > 0 {
            SVProgressHUD.showSuccess(withStatus: message)
        }
        
        guard let array = Mapper<T>().mapArray(JSONObject: content) else {
            return LJResponse<[T]>.Failed(MoyaError.jsonMapping(self))
        }
        return LJResponse.Success(array)
    }

}

extension ObservableType where Element == Response {
    /// 解析成Dictionary
    func mapDictionary() -> Observable<LJResponse<Dictionary<String, Any>>> {
        return flatMap({ response -> Observable<LJResponse<Dictionary<String, Any>>> in
            return Observable.just(response.mapDictionary())
        })
    }
    /// 解析成Model，解析分页数据也使用这个方法，传入LJListModel即可
    func mapObject<T: BaseMappable>(_ type: T.Type) -> Observable<LJResponse<T>> {
        return flatMap({ response -> Observable<LJResponse<T>> in
            return Observable.just(response.mapObject(T.self))
        })
    }
    /// 解析成Model数组,不分页, 如 [LJProcutModel]
    func mapArray<T: BaseMappable>(_ type: T.Type) -> Observable<LJResponse<[T]>> {
        return flatMap { response -> Observable<LJResponse<[T]>> in
            return Observable.just(response.mapArray(T.self))
        }
    }
    /// 解析成基本类型数组, 如: [String]
    func mapNormalArray<T>(_ type: T.Type) -> Observable<LJResponse<[T]>> {
        return flatMap { response -> Observable<LJResponse<[T]>> in
            return Observable.just(response.mapNormalArray(T.self))
        }
    }
    /// 解析成基本类型, 如: String
    func mapNormalType<T>(_ type: T.Type) -> Observable<LJResponse<T>> {
        return flatMap { response -> Observable<LJResponse<T>> in
            return Observable.just(response.mapNormalType(T.self))
        }
    }
}
