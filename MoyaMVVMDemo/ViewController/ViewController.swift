//
//  ViewController.swift
//  MoyaMVVMDemo
//
//  Created by 雷军 on 2020/7/31.
//  Copyright © 2020 ljcoder. All rights reserved.
//  GitHub: https://github.com/ljcoder2015
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    // MARK: UI
    fileprivate lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送请求", for: .normal)
        button.frame = CGRect(x: 150, y: 100, width: 100, height: 50)
        button.addTarget(self, action: #selector(loadData), for: .touchUpInside)
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var textView = UITextView(frame: CGRect(x: 30, y: 200, width: 300, height: 200))

    // MARK: Property
    fileprivate let viewModel = ViewModel()
}

// MARK: Life Cycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MoyaDemo"
        
        setupUI()
        
        bindViewModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func loadData() {
        viewModel.fetchList()
    }
}

// MARK: bindViewModel
extension ViewController {
    
    func bindViewModel() {
        
        viewModel.listDriver
            .drive(onNext: { [weak self] (result) in
                guard let `self` = self else { return }
//                if result.isSuccess {
//
//                }
                self.textView.text = result
            })
            .disposed(by: disposeBag)
    }
}

// MARK: SetupUI
extension ViewController {
    
    fileprivate func setupUI() {
        view.addSubview(button)
        view.addSubview(textView)
        
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.isEditable = false
    }
}
