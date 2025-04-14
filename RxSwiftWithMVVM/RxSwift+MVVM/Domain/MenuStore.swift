//
//  MenuStore.swift
//  RxSwift+MVVM
//
//  Created by 서준일 on 4/11/25.
//  Copyright © 2025 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

protocol MenuFetchable {
    func fetchMenus() -> Observable<[MenuItem]>
}

class MenuStore: MenuFetchable {
    func fetchMenus() -> Observable<[MenuItem]> {
        struct Response: Decodable {
            let menus: [MenuItem]
        }
        
        return APIService.fetchAllMenusRx()
            .map { data in
                guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
                    throw NSError(domain: "Decodingerror", code: -1, userInfo: nil)
                }
                return response.menus
            }
    }
}
