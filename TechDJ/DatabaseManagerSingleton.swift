//
//  DatabaseManagerSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/1/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation
import Firebase


/*
 This singleton manager is in charge of all communications to the firebase database.
 It has several methods for accomplishing specific read, write, or remove operations on the database.
 
 All of the firebase data operations are rest calls so I for the ones that might be loading a large amount of data such as a long list of songs, I put them in a background task.
 
 */
class DatabaseManagerSingleton : NSObject {
    
    static var fbID = ""
    static private let ref = FIRDatabase.database().reference()

    private override init(){}
    
    // creates a user if that user doesn't already exist
    static func createUserWith(firstName: String, lastName: String, email: String, forUserID: String){
       
        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let  user = value?[fbID] as? NSDictionary
            
            if user == nil {
                self.ref.child("users/\(fbID)/first_name").setValue(firstName)
                self.ref.child("users/\(fbID)/last_name").setValue(lastName)
                self.ref.child("users/\(fbID)/email").setValue(email)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
 
    // populates the userinfo singleton from the database information
    static func populateUserInfo(){
        self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let  user = value?[fbID] as? NSDictionary
            
            if user != nil {
                UserInfoSingleton.firstName = user?["first_name"] as! String
                UserInfoSingleton.lastName = user?["last_name"] as! String
                UserInfoSingleton.email = user?["email"] as! String
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // sets the user key is_active to false on the firebase database
    static func userDidLogout(){
        if(fbID.characters.count > 1){
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let  user = value?[fbID] as? NSDictionary
                
                if user != nil {
                    self.ref.child("users/\(fbID)/is_active").setValue("false")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // sets the user key is_active to true on the firebase database
    static func userDidLogin(){
        if(fbID.characters.count > 1){
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let  user = value?[fbID] as? NSDictionary
                
                if user != nil {
                    self.ref.child("users/\(fbID)/is_active").setValue("true")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // sets the user key user_type to host
    static func setUserToHost(){
        if(fbID.characters.count > 1){
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let  user = value?[fbID] as? NSDictionary
                
                if user != nil {
                    self.ref.child("users/\(fbID)/user_type").setValue("host")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // sets the user key user_type to contributer
    static func setUserToContributer(){
        if(fbID.characters.count > 1){
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let  user = value?[fbID] as? NSDictionary
                
                if user != nil {
                    self.ref.child("users/\(fbID)/user_type").setValue("contributer")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // asks for background processing time.
    // sends to the caller of the function, all the available hosts. By available I mean a user with
    // the is_active key set to true.
    static func loadListOfAvailableHosts(_ sender : ListOfHostsVC){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async{
            
            var bTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            
            bTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                // when you are out of time and are about to be killed
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
            })
        
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                var listOfHosts : [[String:String]] = []
                
                let enumerator = snapshot.children
                
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let user = rest.value as? NSDictionary
                    let userKey = rest.key
                    let isActive = user?["is_active"] as? String
                    let userType = user?["user_type"] as? String
                    let firstName = user?["first_name"] as? String
                    let lastName = user?["last_name"] as? String
                    let fullName = "\(firstName!) \(lastName!)"
                    if(isActive == "true" && userType == "host"){
                        let dict = ["full_name": fullName, "user_key": userKey]
                        listOfHosts.append(dict)
                    }
                }
                
                sender.updateHostsList(listOfHosts)
                
                // finished loading task
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
                
            }) { (error) in
                print(error.localizedDescription)
                
                // finished task with an error
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
            }
        
        }

    }
    
    // sends a song suggestion to the host with the user id host
    static func makeSuggestionToHost(_ host : String, _ song: [String:String]){
        if(host != "" && host != "none"){
            self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let  user = value?[host] as? NSDictionary
                
                if user != nil {
                    let suggestionsRef = self.ref.child("users/\(host)/suggestions").childByAutoId()
                    suggestionsRef.setValue(song)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // ask for background processing time
    // sends to the caller of this function a list of suggestions that has been made for the host 
    //  with user id hostID.
    static func loadSuggestionsForHost(_ hostID: String, sender: ContributorsSongsVC){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async{
            
            var bTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            
            bTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                // when you are out of time and are about to be killed
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
            })
            
            self.ref.child("users/\(hostID)/suggestions").observeSingleEvent(of: .value, with: { (snapshot) in
                
                var songSuggestions : [[String:String]] = []
                
                let enumerator = snapshot.children
                
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let song = rest.value as? NSDictionary
                    let key = rest.key
                    
                    print("key is : \(key)")
                    print("song data: \(song)")
                    
                    let name = song?["name"] as? String
                    let artist = song?["artist"] as? String
                    let image = song?["image_url"] as? String
                    let uri = song?["uri"] as? String
                    let type = song?["type"] as? String
                    
                    print("song name: ")
                    print(name!)
                    
                    songSuggestions.append(["name":name!, "artist": artist!, "image_url": image!, "uri": uri!, "type": type!])
                }
                
                sender.updateContributorsSuggestions(result: songSuggestions)
                
                //done with task
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
                
            }) { (error) in
                print(error.localizedDescription)
                print("database error")
                sender.updateContributorsSuggestions(result: [])
                
                // done with the task, although we got an error
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
            }
            
        }
        
    }
    
    static func clearSharedList(){
        let suggestionsRef = self.ref.child("users/\(fbID)/suggestions")
        suggestionsRef.setValue(nil)
    }
    
}
