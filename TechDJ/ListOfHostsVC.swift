//
//  ListOfHostsVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/5/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

class ListOfHostsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var tableData : [[String:String]] = []
    
    let ac = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    let cellId = "hostListCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableData.removeAll()
        
        if(self.tableView != nil){
            print("tableView is not nil")
        }
        
        addActivityIndicatorOverTableView()
        DatabaseManagerSingleton.loadListOfAvailableHosts(self)
        
        //self.tableView.reloadData()
    }
    
    func updateHostsList(_ hosts : [[String:String]]){
        DispatchQueue.main.async {
            self.tableData = hosts
            self.hideActivityIndicator()
            self.tableView.reloadData() // getting a nil when unwraping an optional - fixed
        }
    }
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        }
        
        cell?.textLabel?.text! = tableData[indexPath.row]["full_name"]!
        
        print("tableData cell for row: \(tableData[indexPath.row])")

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Comfirm Host Selection",
                                                message: "Do you want to make \(tableData[indexPath.row]["full_name"]!) your host?",
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("didn't select as user")
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("Comfirmed host")
            UserInfoSingleton.hostID = self.tableData[indexPath.row]["user_key"]!
            UserInfoSingleton.hostName = self.tableData[indexPath.row]["full_name"]!
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // activity indicator 
    
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

}
