//
//  ViewController.swift
//  TechDJ
//
//  Created by Emanuel Azage on 11/16/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginVC: UIViewController, FBSDKLoginButtonDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "concert_crowd_green.jpg")!)
        
        print("view did load: before adding fb button")
        
        // add fb login button to center
        let fbLoginButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 250, height: 75))
        fbLoginButton.center = self.view.center
        fbLoginButton.center.y += 100
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email"]
        self.view.addSubview(fbLoginButton)
        
        print("added fb button")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(FBSDKAccessToken.current() != nil){
            print("userID: ")
            print(FBSDKAccessToken.current().userID)
            
            UserInfoSingleton.fbID = FBSDKAccessToken.current().userID
            
            DatabaseManagerSingleton.fbID = FBSDKAccessToken.current().userID
            DatabaseManagerSingleton.populateUserInfo()
            DatabaseManagerSingleton.userDidLogin()
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "spotifyVC") as? SpotifyLoginVC
            self.present(nextViewController!, animated:true, completion:nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: FBLoginButton Delegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if(error == nil){
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name, last_name, email"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else
                {
                    DatabaseManagerSingleton.userDidLogin()
                    
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    
                    let fbID : String = data["id"] as! String
                    let firstName = data["first_name"] as! String
                    let lastName = data["last_name"] as! String
                    let email = data["email"] as! String
                    
                    UserInfoSingleton.firstName = firstName
                    UserInfoSingleton.lastName = lastName
                    UserInfoSingleton.email = email
                    UserInfoSingleton.fbID = fbID
                    DatabaseManagerSingleton.fbID = fbID
                    
                    
                    DatabaseManagerSingleton.createUserWith(firstName: firstName, lastName: lastName, email: email, forUserID: fbID)
                    
                    print("database manager finished");
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "spotifyVC") as? SpotifyLoginVC
                    self.present(nextViewController!, animated:true, completion:nil)
                }
            })
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}

    // iterate thru firebase sdk
    /*
    var ref = Firebase(url:MY_FIREBASE_URL)
    ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
        println(snapshot.childrenCount) // I got the expected number of items
        let enumerator = snapshot.children
        while let rest = enumerator.nextObject() as? FDataSnapshot {
            println(rest.value)
        }
    })
    */
}


