//
//  LJListModel.swift
//  CommerceDataCloud
//
//  Created by Adam on 2017/12/11.
//  Copyright © 2017年 shanglv. All rights reserved.
//  GitHub: https://github.com/ljcoder2015
//

import UIKit
import ObjectMapper

class LJListModel<Item: BaseMappable>: Mappable {
    
    var currentPage: Int = 1
    var lastPage: Int = 1
    var list: [Item]?
    var totalPage: Int = 1
    var total: Int = 0
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        lastPage    <- map["last_page"]
        list    <- map["data"]
        totalPage    <- map["totalPage"]
        currentPage    <- map["current_page"]
        total    <- map["total"]
    }
}
