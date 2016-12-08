//
//  SpotifySearchViewController.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/4/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

/*
 This parent class is just a wrapper for the view controllers that use the 
 SpotifySearchManagerSingleton class. This is because the spotify search manager will call the 
 updateSearchResults() function so to call a methond on the spotify search mananger, you need to
 provide an object that inherits this class and so it implements updateSearchResults.
 */

class SpotifySearchViewController: UIViewController {

    func updateSearchResults(results: [[String: String]]){}

}
