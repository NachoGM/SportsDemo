//
//  UIHelper.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation
import UIKit

// MARK:  All Players & Golf players
var URL_SPORTS = "https://api.myjson.com/bins/66851"
var imageHeaderArray = ["football_ic","tennis_ic","golf_ic","formula1_ic"]

extension UIViewController {
    func displayAlertMessage(userTitle: String, userMessage: String) {
        
        let myAlert = UIAlertController(title: userTitle, message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            let vc = self.storyboard?.instantiateInitialViewController()
            self.present(vc!, animated: false, completion: nil)
        }
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
}
