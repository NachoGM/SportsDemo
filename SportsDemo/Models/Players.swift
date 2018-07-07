//
//  Football.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation

struct Player {
    
    var title: String!
    var players: NSDictionary!
    
    init(players: NSDictionary, title: String) {
        self.players = players
        self.title = title
    }
}
