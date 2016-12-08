//
//  DefaultSongListSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 11/25/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation

class DefaultSongListSingleton: NSObject, SPTAudioStreamingDelegate {
    static private var player : SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    
}


