//
//  Connectivity.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import Foundation
import Alamofire

//  Check Internet 
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
