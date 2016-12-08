//
//  DefaultSongListSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 11/25/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation

/*
 This is a singleton for an array of string to string dictionaries. Each dictionary holds all the
 information for a song so this singleton is an array of all the songs in the users default song
 list.
 
 */

class DefaultSongListSingleton: NSObject {
    static var shared : [[String:String]] = []
    
    private override init(){}
}


