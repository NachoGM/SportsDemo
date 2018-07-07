//
//  ExpandableHeaderView.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 5/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit

protocol CustomHeaderViewDelegate {
    func toggleSection(header: CustomHeaderView, section: Int)
}

class CustomHeaderView: UITableViewHeaderFooterView {
    var delegate: CustomHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func customInit(title: String, section: Int) {
        self.textLabel?.text = title
        self.section = section
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.white
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 40.00)
        self.textLabel?.layer.masksToBounds = false
        self.textLabel?.layer.shadowColor = UIColor.darkGray.cgColor
        self.textLabel?.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.textLabel?.layer.shadowOpacity = Float(0.5)
    }
    
}
