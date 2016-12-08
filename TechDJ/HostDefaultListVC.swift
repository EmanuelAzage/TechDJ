//
//  HostDefaultListVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 11/23/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

class HostDefaultListVC: SpotifySearchViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let ac = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var isSearching : Bool = false
    
    let cellId = "cellID"
    
    var searchResults : [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // read list from userDefaults
        let userDefaults = UserDefaults.standard
        if let defaultSongs = userDefaults.value(forKey: UtilSingleton.kDefaultListKey){
            DefaultSongListSingleton.shared = defaultSongs as! [[String : String]]
        }
        
    }
    
    func addActivityIndicatorOverTableView(){
        let activityIndicatorView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.width, height:tableView.frame.height))
        activityIndicatorView.addSubview(ac)
        ac.center = activityIndicatorView.center
        ac.startAnimating()
        tableView.tableHeaderView = activityIndicatorView
    }
    
    func hideActivityIndicator(){
//        print("ac stopped animating")
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
        return DefaultSongListSingleton.shared.count
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
            cell?.textLabel?.text = DefaultSongListSingleton.shared[indexPath.row]["name"]
            cell?.detailTextLabel?.text = DefaultSongListSingleton.shared[indexPath.row]["artist"]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.isSearching){
            // add to default list 
            DefaultSongListSingleton.shared.append(self.searchResults[indexPath.row])
            
            // update userDefaults
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(DefaultSongListSingleton.shared, forKey: UtilSingleton.kDefaultListKey)
            
            // end current search, they have found their song
            self.isSearching = false
            self.searchBar.text! = ""
            self.tableView.reloadData()
            self.searchBar.resignFirstResponder()
            
            self.searchResults.removeAll(keepingCapacity: false)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // delete from array
            if(!self.isSearching){
                DefaultSongListSingleton.shared.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
            
            // update userDefaults
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(DefaultSongListSingleton.shared, forKey: UtilSingleton.kDefaultListKey)
            
            // so that the index for musc player isn't messed up
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            weak var musicPlayer = storyBoard.instantiateViewController(withIdentifier: "musicPlayerVC") as? HostMusicPlayerVC
            musicPlayer!.sourceListDeletedRow(index: indexPath.row)
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
    
    func loadSearchResults(searchText : String){
        SpotifySearchManagerSingleton.loadSearchResults(searchText, self)
    }
}
