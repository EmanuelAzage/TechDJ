//
//  UserInfoSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/1/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation

/*
 This singleton holds the user information such as name and facebook id and their spotify information
 */

class UserInfoSingleton : NSObject {
    
    static var firstName = ""
    static var lastName = ""
    static var email = ""
    static var fbID = ""
    static var hostID = "none"
    static var hostName = ""
    
    static var spotifyAccessToken = ""
    static let spotifyClientId = "89364e8c434941e4a987fff46f82277b"
    static let spotifyCallbackURL = "techdj://returnAfterLogin"
    
    
    private override init(){}
}
