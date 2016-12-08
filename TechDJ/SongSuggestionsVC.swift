//
//  SongSuggestionsVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/5/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

class SongSuggestionsVC: SpotifySearchViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let ac = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var isSearching : Bool = false
    
    let cellId = "songSuggestionCellId"
    
    var searchResults : [[String: String]] = []
    
    var songSuggestions : [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func addActivityIndicatorOverTableView(){
        let activityIndicatorView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.width, height:tableView.frame.height))
        activityIndicatorView.addSubview(ac)
        ac.center = activityIndicatorView.center
        ac.startAnimating()
        tableView.tableHeaderView = activityIndicatorView
    }
    
    func hideActivityIndicator(){
        print("ac stopped animating")
        ac.stopAnimating()
        if(tableView.tableHeaderView != nil){
            tableView.tableHeaderView?.isHidden = true
        }
        tableView.tableHeaderView = nil
    }
    
    // MARK: - Search Delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
        self.tableView.reloadData()
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        self.searchBar.text! = ""
        self.tableView.reloadData()
        self.searchBar.resignFirstResponder()
        
        self.searchResults.removeAll(keepingCapacity: false)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchResults.removeAll(keepingCapacity: false)
        
        addActivityIndicatorOverTableView()
        self.loadSearchResults(searchText: self.searchBar.text!)
        
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
        
    }
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.isSearching){
            return searchResults.count
        }
        return self.songSuggestions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        }
        
        if(self.isSearching){
            cell?.textLabel?.text = self.searchResults[indexPath.row]["name"]
            cell?.detailTextLabel?.text = self.searchResults[indexPath.row]["artist"]
        }else{
            cell?.textLabel?.text = songSuggestions[indexPath.row]["name"]
            cell?.detailTextLabel?.text = songSuggestions[indexPath.row]["artist"]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.isSearching){
            let message = "Suggest the following song to your host? \n \(searchResults[indexPath.row]["name"]!) by \(searchResults[indexPath.row]["artist"]!)"
            let alertController = UIAlertController(title: "Confirm Song Selection",
                                                    message: message,
                preferredStyle: UIAlertControllerStyle.alert)
            
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                let suggestion = self.searchResults[indexPath.row]
                
                // add to default list
                self.songSuggestions.append(suggestion)
                
                // end current search, they have found their song
                self.isSearching = false
                self.searchBar.text! = ""
                self.tableView.reloadData()
                self.searchBar.resignFirstResponder()
                
                self.searchResults.removeAll(keepingCapacity: false)
                
                // database call to suggest song
                DatabaseManagerSingleton.makeSuggestionToHost(UserInfoSingleton.hostID, suggestion)
            }
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    // MARK: - SpotifySearchNotification
    
    override func updateSearchResults(results: [[String : String]]) {
        DispatchQueue.main.async {
            self.searchResults = results
            self.tableView.reloadData()
            self.hideActivityIndicator()
        }
    }
    
    // helper
    
    func loadSearchResults(searchText : String){
        SpotifySearchManagerSingleton.loadSearchResults(searchText, self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
