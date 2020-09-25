//
//  LJWorkAPI.swift
//  ShowroomService
//
//  Created by 雷军 on 2018/7/24.
//  Copyright © 2018年 ljcoder. All rights reserved.
//

import Foundation
import Moya

let LJWorkProvider = MoyaProvider<LJWorkAPI>(plugins: [LJNetworkLoggerPlugin()])

enum LJWorkAPI {
    case fetchList
}

extension LJWorkAPI: TargetType {
    
    var path: String {
        switch self {
        case .fetchList:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchList:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .fetchList:
            return .requestPlain
        }
    }
}
