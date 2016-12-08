//
//  SpotifySearchManagerSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/4/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation

/*
 This singleton manages searches made through spotifys API. It loads the search results and sends them to the caller of the load function
 */


class SpotifySearchManagerSingleton : NSObject {
    private override init(){}
    
    static var limit : String = "30"
    
    private static var searchResults : [[String: String]] = []
    
    // This Function is able to be backgrounded
    // Input: search string , forSearch
    // Input: a SpotifySearchViewController - a ViewController that implements updateSearchResults
    // output: None
    // description: This sends a rest call to spotify and when it gets a response it calls
    //              supdateSearchResults(results : [[String: String]]) on the caller of this function
    static func loadSearchResults(_ forSearch: String, _ sender: SpotifySearchViewController){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async{
            
            var bTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            
            bTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                // when you are out of time and are about to be killed
                UIApplication.shared.endBackgroundTask(bTask)
                bTask = UIBackgroundTaskInvalid
            })
        
            self.searchResults.removeAll()
            
            let search = getFormattedString(forSearch)
            
            let url = "https://api.spotify.com/v1/search?q=\(search)&type=track,artist&limit=\(limit)"
            
            print(search) // debug
            
            let request : URLRequest = URLRequest(url: URL(string: url)!)
            let session = URLSession.shared
            
            let searchTask = session.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                if error != nil {
                    print("error, data: \(data)")
                    print("error \(error)")
                } else {
                    do{
                        let readableJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                        
                        //print(readableJSON as Any)
                        
                        if let tracks = readableJSON["tracks"] as? [String:AnyObject]{
                            if let items = tracks["items"] as? [AnyObject]{
                                print("track and items are not nil") // debug
                                
                                print("itemsCount \(items.count)")
                                
                                if(items.count > 0){
                                    for i in 0...items.count-1{
                                        let item = items[i] as! [String : AnyObject]
                                        
                                        let name = item["name"] as! String
                                        let type = item["type"] as! String
                                        let uri = item["uri"] as! String
                                        
                                        let artists = item["artists"] as! [AnyObject]
                                        let artistData = artists[0] as! [String : AnyObject]
                                        let artist = artistData["name"] as! String
                                        
                                        let album = item["album"] as! [String : AnyObject]
                                        let images = album["images"] as! [AnyObject]
                                        let firstImage = images[0] as! [String : AnyObject]
                                        let imageURL = firstImage["url"] as! String
                                        
                                        if(name != "" && artist != ""){
                                            self.searchResults.append(["name": name, "type":type, "uri":uri, "artist":artist, "image_url":imageURL])
                                        }
                                    }
                                }
                            }
                        }

                        sender.updateSearchResults(results: searchResults)
                        
                        // end background task
                        UIApplication.shared.endBackgroundTask(bTask)
                        bTask = UIBackgroundTaskInvalid
                    } catch{
                        print("serializtion error: \(error)")
                        
                        // end background task due to error
                        UIApplication.shared.endBackgroundTask(bTask)
                        bTask = UIBackgroundTaskInvalid
                    }
                    
                }
            })
            searchTask.resume()
            
        }
    }
    
    private static func getFormattedString(_ inSearch : String)->String{
        let searchArray = inSearch.components(separatedBy:" ")
        var search = searchArray[0]
        if(searchArray.count > 1){
            for i in 1 ... searchArray.count-1{
                search += "+\(searchArray[i])"
            }
        }
        return search
    }
}
