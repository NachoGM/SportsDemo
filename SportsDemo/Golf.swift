//
//  Golf.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 5/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation

struct Golf {
    var players: NSDictionary!
    var type: String!
    var title: String!
    
    init(title: String, type: String, players: NSDictionary) {
        self.title = title
        self.type = type
        self.players = players
    }
}
