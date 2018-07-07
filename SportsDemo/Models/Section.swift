//
//  Section.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 5/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation

struct Section {
    
    var title: String!
    var type: String!
    var players: NSArray!
    var name: NSArray!
    var surname: NSArray!
    var image: NSArray!
    var date: NSArray!
    
    init(titleSection: String, type: String, players: NSArray, name: NSArray, surname: NSArray, image: NSArray, date: NSArray) {
        self.title = titleSection
        self.type = type
        self.players = players
        self.name = name
        self.surname = surname
        self.image = image
        self.date = date
    }
}
