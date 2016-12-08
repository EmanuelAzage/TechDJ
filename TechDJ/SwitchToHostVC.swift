//
//  SwitchToHostVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/5/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SwitchToHostVC: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var hostLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fbLoginButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 250, height: 75))
        fbLoginButton.center = self.view.center
        fbLoginButton.center.y += 100
        fbLoginButton.delegate = self
        self.view.addSubview(fbLoginButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserInfoSingleton.hostName != ""{
            self.hostLabel.text! = UserInfoSingleton.hostName
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        DatabaseManagerSingleton.userDidLogout()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "loginVC") as? FacebookLoginVC
        self.present(nextViewController!, animated:true, completion:nil)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {}

    @IBAction func becomeHostClicked(_ sender: UIButton) {
        // update database
        DatabaseManagerSingleton.setUserToHost()
        
        //get the spotify player ready
        SpotifyPlayerManagerSingleton.setUp()
        
        //go to host tab bar
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "hostTabBar") as? UITabBarController
        self.present(nextViewController!, animated:true, completion:nil)
    }

}
