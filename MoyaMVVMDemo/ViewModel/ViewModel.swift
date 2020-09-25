//
//  ViewModel.swift
//  MoyaMVVMDemo
//
//  Created by 雷军 on 2020/7/31.
//  Copyright © 2020 ljcoder. All rights reserved.
//  GitHub: https://github.com/ljcoder2015
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import Moya

class ViewModel: LJBaseViewModel {
    // MARK: output
    lazy var listDriver: Driver<String> = self.listPublishRelay.asDriver(onErrorJustReturn: "")

    // MARK: Variable
    fileprivate var listPublishRelay = PublishRelay<String>()
    
}

// MARK: Action
extension ViewModel {
    func fetchList() {
        LJWorkProvider.rx.request(LJWorkAPI.fetchList)
            .asObservable()
            .mapString()
            .subscribe(onNext: { (result) in
                self.listPublishRelay.accept(result)
            }, onError: { _ in
                self.listPublishRelay.accept("")
            })
            .disposed(by: disposeBag)
    }
}
