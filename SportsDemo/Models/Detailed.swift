//
//  Detailed.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation
import Kingfisher

struct Detailed {
    
    var section: String!
    var name: String!
    var surname: String!
    var date: String!
    var imageResource: ImageResource!

    init(section: String, name: String, surname: String, date: String, imageResource: ImageResource) {
        self.section = section
        self.name = name
        self.surname = surname
        self.date = date
        self.imageResource = imageResource
    }
}
