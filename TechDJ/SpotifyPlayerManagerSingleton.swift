//
//  SpotifyPlayerManager.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/2/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation
import AVFoundation

/*
 This is a singleton to manage the playing of music from spotify. It alsos keeps track of the current state of whether there is currently music playing or not.
 */

class SpotifyPlayerManagerSingleton : NSObject{
    
    static let player : SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    static var isPlaying = false
    static var isSetUp = false
    
    private override init() {}
    
    static func setUp(){
        if(isSetUp){
            return
        }
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        try? player.start(withClientId: UserInfoSingleton.spotifyClientId)
        
        let userDefaults = UserDefaults.standard
        
        if let sessionObj = userDefaults.object(forKey: "SpotifySession"){ // session available
            let sessionDataObj = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj as Data) as! SPTSession
            if(session.isValid()){
                player.login(withAccessToken: session.accessToken)
            }
        }
    }
    
    // Starts playing the song at the given uri
    static func startPlaying(uri: String){
        self.player.playSpotifyURI(uri, startingWith: 0, startingWithPosition: 0, callback: { (error: Error?) -> Void in
            if(error != nil){
                print(error!)
            }else{
                isPlaying = true
            }
        }
        )
    }
    
    // resumes a previously started song
    static func resumePlaying(){
        self.player.setIsPlaying(true, callback: nil)
        isPlaying = true
    }
    
    // pauses the currently playing songs
    static func stopPlaying(){
        self.player.setIsPlaying(false, callback: nil)
        isPlaying = false
    }
    
}
