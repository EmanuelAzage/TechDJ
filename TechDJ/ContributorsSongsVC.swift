//
//  ContributorsSongsVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/2/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

class ContributorsSongsVC: SpotifySearchViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let ac = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var isSearching : Bool = false
    
    let cellId = "contributorsCellID"
    
    var searchResults : [[String: String]] = []
    
    var hostsSongs : [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addActivityIndicatorOverTableView()
        loadContributorsSuggestions()
    }
    
    func addActivityIndicatorOverTableView(){
        let activityIndicatorView = UIView(frame: CGRect(x:0,
                                                         y:0,
                                                         width:tableView.frame.width,
                                                         height:tableView.frame.height))
        activityIndicatorView.addSubview(ac)
        ac.center = activityIndicatorView.center
        ac.startAnimating()
        tableView.tableHeaderView = activityIndicatorView
    }
    
    func hideActivityIndicator(){
        ac.stopAnimating()
        tableView.tableHeaderView = nil
    }
    
    // MARK: - Database Notification
    
    func updateContributorsSuggestions(result: [[String: String]]){
        DispatchQueue.main.async {
            ContributorsSongsSingleton.shared = result
            ContributorsSongsSingleton.shared.append(contentsOf: self.hostsSongs)
            self.hideActivityIndicator()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - SpotifySearchNotification
    
    override func updateSearchResults(results: [[String : String]]) {
        DispatchQueue.main.async {
            self.searchResults = results
            self.hideActivityIndicator()
            self.tableView.reloadData()
        }
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
        return ContributorsSongsSingleton.shared.count
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
            cell?.textLabel?.text = ContributorsSongsSingleton.shared[indexPath.row]["name"]
            cell?.detailTextLabel?.text = ContributorsSongsSingleton.shared[indexPath.row]["artist"]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.isSearching){
            // add to default list
            ContributorsSongsSingleton.shared.append(self.searchResults[indexPath.row])
            self.hostsSongs.append(self.searchResults[indexPath.row])
            
            // end current search, they have found their song
            self.isSearching = false
            self.searchBar.text! = ""
            self.tableView.reloadData()
            self.searchBar.resignFirstResponder()
            
            self.searchResults.removeAll(keepingCapacity: false)
        }
    }
    
    //I don't think I will allow deletion from this list.
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if(self.isSearching){
                //self.searchResults.remove(at: indexPath.row)
            }else{
                let toDelete = tableViewData[indexPath.row]
                if(arrayContainsDict(contributorsSongs, toDelete)){
                    // remove from data base and remove from contributorsSongs
                    var index = 0
                    for song in self.contributorsSongs{
                        if(dictIsEqual(song, toDelete)){
                            self.contributorsSongs.remove(at: index)
                            break
                        }
                        index+=1
                    }
                    
                    //remove from database TODO, i might not do this
                    //DatabaseManagerSingleton.removeSongFromContributorsList(toDelete) // need to implement this function
                }else{
                    //remove from tableData
                    var index = 0
                    for song in self.tableData{
                        if(dictIsEqual(song, toDelete)){
                            self.tableData.remove(at: index)
                            break
                        }
                        index+=1
                    }
                }
                
            }
            self.tableView.reloadData()
            
            // so that the index for musc player isn't messed up
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            weak var musicPlayer = storyBoard.instantiateViewController(withIdentifier: "musicPlayerVC") as? HostMusicPlayerVC
            musicPlayer!.sourceListDeletedRow(index: indexPath.row)
        }
 
    }
    */
    
    
    // MARK: helper methods
    
    func loadSearchResults(searchText : String){
        SpotifySearchManagerSingleton.loadSearchResults(searchText, self)
    }
    
    func loadContributorsSuggestions(){
        // get data from firebase database
        DatabaseManagerSingleton.loadSuggestionsForHost(UserInfoSingleton.fbID, sender: self)
    }
    
    func arrayContainsDict(_ array: [[String: String]], _ dict: [String : String]) -> Bool{
        for element in array{
            if(dictIsEqual(element,dict)){
                return true
            }
        }
        return false
    }
    
    func dictIsEqual(_ lhs : [String:String], _ rhs : [String:String]) -> Bool{
        let lhsKeys = lhs.keys
        for key in rhs.keys{
            if(!lhsKeys.contains(key)){
                return false
            }
        }
        for key in lhs.keys{
            if(lhs[key] != rhs[key]){
                return false
            }
        }
        return true
    }

}
