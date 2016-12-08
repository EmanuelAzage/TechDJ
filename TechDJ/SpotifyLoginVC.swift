//
//  SpotifyLoginVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 11/17/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SpotifyLoginVC : UIViewController {
        
    @IBOutlet weak var spotifyLoginButton: UIButton!
    
    let player : SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //spotifyLoginButton.isHidden = true
        //print("TDJ:: spotify button hidden")
        
        NotificationCenter.default.addObserver(self, selector: #selector(SpotifyLoginVC.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "spotifyLoginSuccessfull"), object: nil)
        
        let userDefaults = UserDefaults.standard
        
        if let sessionObj = userDefaults.object(forKey: "SpotifySession"){ // session available
            let sessionDataObj = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj as Data) as! SPTSession
            if(session.isValid()){
                print("TDJ:: Session valid on viewdidload")
            }
        } else {
            //spotifyLoginButton.isHidden = false
            //print("TDJ:: spotify button NOT hidden")
        }
    }
    
    func updateAfterFirstLogin(){
        print("TDJ:: updateAfterFirstLogin called")
    
        let userDefaults = UserDefaults.standard
        
        if let sessionObj = userDefaults.object(forKey: "SpotifySession"){ // session available
            let sessionDataObj = sessionObj as! NSData
            let session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj as Data) as! SPTSession
            if(session.isValid()){
                print("TDJ:: Session was valid, login with access token")
            }
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "userTypeSelectionVC") as? UserTypeSelectionVC
        self.present(nextViewController!, animated:true, completion:nil)
    }
    
    @IBAction func spotifyLoginClicked(_ sender: Any) {
        
        let spotifyAuth = SPTAuth.defaultInstance()
        spotifyAuth?.clientID = UserInfoSingleton.spotifyClientId
        spotifyAuth?.redirectURL = URL(string:UserInfoSingleton.spotifyCallbackURL)
        spotifyAuth?.requestedScopes = [SPTAuthStreamingScope]
        
        let loginURL = spotifyAuth?.spotifyWebAuthenticationURL()
        
        UIApplication.shared.open(loginURL!, options: [:], completionHandler: {(x : Bool) in
        })
    
    }
    
}
