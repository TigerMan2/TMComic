//
//  TMAPI.swift
//  TMComic
//
//  Created by Luther on 2020/5/14.
//  Copyright © 2020 mrstock. All rights reserved.
//

import Foundation
import Moya
import HandyJSON
import MBProgressHUD

let LoadingPlugin = NetworkActivityPlugin { (type, target) in
    guard let vc = topVC else { return }
    switch type {
    case .began:
        MBProgressHUD.hide(for: vc.view, animated: false)
        DispatchQueue.main.async {
         MBProgressHUD.showAdded(to: vc.view, animated: true)
        }
    case .ended:
        MBProgressHUD.hide(for: vc.view, animated: true)
    }
}

let timeoutClosure = { (endpoint: Endpoint, closure: MoyaProvider<TMAPI>.RequestResultClosure) -> Void in
    if var urlRequest = try? endpoint.urlRequest() {
        urlRequest.timeoutInterval = 20
        closure(.success(urlRequest))
    } else {
        closure(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}

let ApiProvider = MoyaProvider<TMAPI>(requestClosure:timeoutClosure)
let ApiLoadingProvider = MoyaProvider<TMAPI>(requestClosure: timeoutClosure, plugins: [LoadingPlugin])

enum TMAPI {
    case searchHot//搜索热门
    case searchRelative(inputText: String)//相关搜索
    case searchResult(argCon: Int, q: String)//搜索结果
    
    case boutiqueList(sexType: Int)//推荐列表
    case special(argCon: Int, page: Int)//专题
    case vipList//VIP列表
    case subscribeList//订阅列表
    case rankList//排行列表

    case cateList//分类列表
    
    case comicList(argCon: Int, argName: String, argValue: Int, page: Int)//漫画列表
    
    case guessLike//猜你喜欢
    
    case detailStatic(comicid: Int)//详情(基本)
    case detailRealtime(comicid: Int)//详情(实时)
    case commentList(object_id: Int, thread_id: Int, page: Int)//评论
    
    case chapter(chapter_id: Int)//章节内容
}

extension TMAPI: TargetType {
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        var params: [String:Any] = [:]
        switch self {
        case .searchRelative(let inputText):
            params["inputText"] = inputText
            
        case .searchResult(let argCon, let q):
            params["argCon"] = argCon
            params["q"] = q
            
        case .boutiqueList(let sexType):
            params["sexType"] = sexType
            
        case .special(let argCon,let page):
            params["argCon"] = argCon
            params["page"] = max(1, page)
            
        case .comicList(let argCon, let argName, let argValue, let page):
            params["argCon"] = argCon
            if argName.count > 0 { params["argName"] = argName }
            params["argValue"] = argValue
            params["page"] = max(1, page)
            
        case .detailStatic(let comicid),
             .detailRealtime(let comicid):
            params["comicid"] = comicid
            
        case .commentList(let object_id, let thread_id, let page):
            params["object_id"] = object_id
            params["thread_id"] = thread_id
            params["page"] = page
            
        case .chapter(let chapter_id):
            params["chapter_id"] = chapter_id
            
        default: break
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
            return URL(string: "http://app.u17.com/v3/appV3_3/ios/phone")!
        }
    
    var path: String {
        switch self {
        case .searchHot: return "search/hotkeywordsnew"
        case .searchRelative: return "search/relative"
        case .searchResult: return "search/searchResult"
            
        case .boutiqueList: return "comic/boutiqueListNew"
        case .special: return "comic/special"
        case .vipList: return "list/vipList"
        case .subscribeList: return "list/newSubscribeList"
        case .rankList: return "rank/list"
            
        case .cateList: return "sort/mobileCateList"
            
        case .comicList: return "list/commonComicList"
            
        case .guessLike: return "comic/guessLike"
            
        case .detailStatic: return "comic/detail_static_new"
        case .detailRealtime: return "comic/detail_realtime"
        case .commentList: return "comment/list"
            
        case .chapter: return "comic/chapterNew"
        }
    }
}

extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) throws -> T {
        let jsonString = String(data: data, encoding: .utf8)
        guard let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
            throw MoyaError.jsonMapping(self)
        }
        return model
    }
}

extension MoyaProvider {
    @discardableResult
    open func request<T: HandyJSON>(_ target: Target,
                               model: T.Type,
                               completion: ((_ returnData: T?) -> Void)?) -> Cancellable? {
        return request(target) { (result) in
            guard let completion = completion else { return }
            switch result {
            case let .success(response):
                guard let returnData = try? response.mapModel(ResponseData<T>.self) else {
                    completion(nil)
                    return
                }
                completion(returnData.data?.returnData)
            case let .failure(error):
                print(error)
            }
        }
    }
}
