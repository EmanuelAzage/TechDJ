//
//  UserTypeSelectionVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 11/22/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

class UserTypeSelectionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //DatabaseManagerSingleton.loadListOfLoggedInUsers()// test

    }
    
    func listOfLoggedInUsersLoaded(users : [[String:String]]){
        print("users in spotifyVC: \(users)")
    }
    
    @IBAction func hostClicked(_ sender: Any) {
        //add to database this user is a host
        DatabaseManagerSingleton.setUserToHost()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        weak var nextViewController = storyBoard.instantiateViewController(withIdentifier: "spotifyVC") as? SpotifyLoginVC
        self.present(nextViewController!, animated:true, completion:nil)
    }

    @IBAction func ContributerClicked(_ sender: Any) {
        DatabaseManagerSingleton.setUserToContributer()
    }

}
