//
//  ViewController.swift
//  ExMap
//
//  Created by 김종권 on 2022/12/22.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserData()
            .map(User.self)
            .subscribe()
            .disposed(by: disposeBag)
        
        getUserData()
            .subscribe(onNext: { data in
                let decoder = JSONDecoder()
                guard let user = try? decoder.decode(User.self, from: data) else { return }
                print(user) // User(id: "1", name: "jake")
            })
            .disposed(by: disposeBag)
    }
    
    func getUserData() -> Observable<Data> {
        let user = User(id: "1", name: "jake")
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(user) else { return .empty() }
        return .just(data)
    }
}

struct User: Codable {
    let id: String
    let name: String
}

extension Observable where Element == Data {
    func map<T: Decodable>(_ type: T.Type) -> Observable<T> {
        flatMap { element -> Observable<T> in
                .create { observer in
                    let decoder = JSONDecoder()
                    do {
                        let model = try decoder.decode(T.self, from: element)
                        observer.onNext(model)
                    } catch {
                        observer.onError(NSError())
                    }
                    return Disposables.create()
                }
        }
    }
}
