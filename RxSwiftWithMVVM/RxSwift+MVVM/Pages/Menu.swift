//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by 서준일 on 4/9/25.
//  Copyright © 2025 iamchiwon. All rights reserved.
//

// View Model
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
