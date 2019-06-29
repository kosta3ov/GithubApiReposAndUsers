//
//  FetchService.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 29.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum ServiceStatus {
    case loading, ready
}

protocol FetchServiceProtocol: class {
    associatedtype Item: Codable
    
    func getObjects(url: String)
    
    var status: ServiceStatus {get set}
    
    var onCompletion: (([Item]) -> Void)? {get set}
    var onError: ((ClientError) -> Void)? {get set}
    var onLink: (([LinkHeader:String]) -> Void)? {get set}
}

extension FetchServiceProtocol {
    private func getObject(from data: Data) -> Item? {
        let decoder = JSONDecoder()
        let obj = try? decoder.decode(Item.self, from: data)
        return obj
    }
    
    private func getObjectURL(from json: Any) -> Observable<String> {
        let urlKey = "url"
        
        if let jsonArray = json as? [[String:Any]] {
            let objURL = jsonArray.compactMap { $0[urlKey] as? String }
            return Observable.from(objURL)
        }
        return Observable.empty()
    }
    
    
    func getObjects(url: String) {
        
        let response = Observable
            .of(url)
            .map { URL(string: $0)! }
            .map { GithubManager.createRequest(url: $0) }
            .flatMap { URLSession.shared.rx.response(request: $0) }
            .flatMap { [weak self] response, data -> Observable<String> in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    return Observable.empty()
                }
                
                if let link = GithubManager.getLink(from: response) {
                    let links = LinkHeader.parseLinks(from: link)
                    self?.onLink?(links)
                }
                
                return self?.getObjectURL(from: json) ?? Observable.empty()
            }
            .map { URL(string: $0)! }
            .map { GithubManager.createRequest(url: $0) }
            .flatMap { URLSession.shared.rx.response(request: $0) }
            .share(replay: 1)
        
        /*
         Getting new objects from response
         */
        _ = response
            /// Filtering success response from every object
            .filter { response, _ in 200 ..< 300 ~= response.statusCode }
            .compactMap { [weak self] (response, data) -> Item? in
                return self?.getObject(from: data)
            }
            .toArray()
            .filter { $0.isEmpty == false }
            .subscribe(onSuccess: { [weak self] (newObjects) in
                self?.onCompletion?(newObjects)
                self?.status = .ready
            })
        
        
        /*
         Processing of Client errors
         */
        _ = response
            .filter {response, _ in 400 ..< 500 ~= response.statusCode }
            .map { (response, data) -> ClientError in
                GithubManager.getError(from: response, data: data)
            }
            .subscribe(onNext: { [weak self] err in
                self?.onError?(err)
                self?.status = .ready
            })
        
    }
}
