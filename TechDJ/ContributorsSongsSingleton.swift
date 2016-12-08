//
//  ContributorsSongsSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/5/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation

/*
    This is a singleton to hold all the songs for the shared songs.
 */

class ContributorsSongsSingleton: NSObject {
    static var shared : [[String:String]] = []
    
    private override init(){}
}
