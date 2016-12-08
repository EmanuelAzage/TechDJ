//
//  SwitchUserTypeVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/1/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SwitchUserTypeVC: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add fb login button to center
        let fbLoginButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 250, height: 75))
        fbLoginButton.center = self.view.center
        fbLoginButton.center.y += 100
        fbLoginButton.delegate = self
        self.view.addSubview(fbLoginButton)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        DatabaseManagerSingleton.userDidLogout()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "loginVC") as? FacebookLoginVC
        self.present(nextViewController!, animated:true, completion:nil)
        
        if(SpotifyPlayerManagerSingleton.isPlaying){
            SpotifyPlayerManagerSingleton.stopPlaying()
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {}

    @IBAction func becomeContributorClicked(_ sender: UIButton) {
        // update database
        DatabaseManagerSingleton.setUserToContributer()
        
        //go to contributor tab bar
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "contributorTabBar") as? UITabBarController
        self.present(nextViewController!, animated:true, completion:nil)
    }
    
    @IBAction func clearSharedListClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Comfirm Clear",
                                                message: "Are you sure you want to clear the shared list?",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        
        let deleteAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            DatabaseManagerSingleton.clearSharedList()

        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
        
    }

}
