//
//  HostMusicPlayerVC.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/2/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import UIKit

class HostMusicPlayerVC: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var numClicked = 0
    var currSongIndex = 0
    
    var usingDefaultList = true
    
    var shouldResumePlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        SPTAudioStreamingController.sharedInstance().delegate = self
        
        SpotifyPlayerManagerSingleton.setUp()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update default list from userDefaults
        let userDefaults = UserDefaults.standard
        if let defaultSongs = userDefaults.value(forKey: UtilSingleton.kDefaultListKey){
            DefaultSongListSingleton.shared = defaultSongs as! [[String : String]]
        }
        
        var dataCount = DefaultSongListSingleton.shared.count
        if(!usingDefaultList){
            dataCount = ContributorsSongsSingleton.shared.count
        }
        
        if(currSongIndex >= 0 && currSongIndex < dataCount){
            updateUI()
        }
 
    }

    @IBAction func listTypeDidChange(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 1){
            self.usingDefaultList = false
        }else{
            self.usingDefaultList = true
        }
        
        if(SpotifyPlayerManagerSingleton.isPlaying){
            SpotifyPlayerManagerSingleton.stopPlaying()
        }
        self.currSongIndex = 0
        self.numClicked = 0
        self.updateUI()
    }

    
    @IBAction func playPauseButtonClicked(_ sender: Any) {
        var songsList = getCurrentList()
        
        if(songsList.count == 0){
            return
        }
        if(playPauseButton.titleLabel!.text == "Play" ){
            if(numClicked == 0){
                SpotifyPlayerManagerSingleton.startPlaying(uri: songsList[self.currSongIndex]["uri"]!)
            } else {
                SpotifyPlayerManagerSingleton.resumePlaying()
            }
        }else{
            SpotifyPlayerManagerSingleton.stopPlaying()
        }
        numClicked += 1
        updateUI()
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        var songsList = getCurrentList()
        
        incrementCurrIndex()
        numClicked = 1
        SpotifyPlayerManagerSingleton.startPlaying(uri: songsList[self.currSongIndex]["uri"]!)
        self.updateUI()
    }
    
    @IBAction func stopButtonClicked(_ sender: Any) {
        SpotifyPlayerManagerSingleton.stopPlaying()
        numClicked = 0;
        updateUI()
    }
    
    // if a source list has element deleted, update currIndex
    func sourceListDeletedRow(index : Int){
        if(currSongIndex >= index){
            if(currSongIndex != 0){
                currSongIndex -= 1
            }
        }
        updateUI()
    }
    
    // MARK: - SPT Audio
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("TDJ:: spotify audio streaming logined in")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("audio logged out")
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("audio endcounter temp error")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("audio recieved error")
        print("error: \(error)") // spotify premium required
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("audio recieve message")
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("Stopped playing track")
        let songsList = getCurrentList()
        
        //play next song
        incrementCurrIndex()
        SpotifyPlayerManagerSingleton.startPlaying(uri: songsList[self.currSongIndex]["uri"]!)
        numClicked = 1
        SpotifyPlayerManagerSingleton.resumePlaying()
        shouldResumePlaying=true
        updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        SpotifyPlayerManagerSingleton.isPlaying = isPlaying
        print("playback status changed to: \(isPlaying)")
        if(shouldResumePlaying){
            SpotifyPlayerManagerSingleton.resumePlaying()
            shouldResumePlaying = false
        }
        updateUI()
    }
    
    // helper
    func getCurrentList()->[[String: String]]{
        if(usingDefaultList){
            return DefaultSongListSingleton.shared
        }
        return ContributorsSongsSingleton.shared
    }
    
    func updateUI(){
        let songList = getCurrentList()
        if songList.count == 0 || playPauseButton == nil{
            return
        }
        
        loadCurrImage()
        if(usingDefaultList){
            artistLabel.text! = DefaultSongListSingleton.shared[currSongIndex]["artist"]!
            songNameLabel.text! = DefaultSongListSingleton.shared[currSongIndex]["name"]!
        }else{
            artistLabel.text! = ContributorsSongsSingleton.shared[currSongIndex]["artist"]!
            songNameLabel.text! = ContributorsSongsSingleton.shared[currSongIndex]["name"]!
        }
    
        if(SpotifyPlayerManagerSingleton.isPlaying){
            playPauseButton.setTitle("Pause", for: .normal)
        }else{
            playPauseButton.setTitle("Play", for: .normal)
        }
    }
    
    func incrementCurrIndex(){
        var dataCount = DefaultSongListSingleton.shared.count
        if(!usingDefaultList){
            dataCount = ContributorsSongsSingleton.shared.count
        }
        
        self.currSongIndex+=1
        if(self.currSongIndex >= dataCount){
            self.currSongIndex = 0
        }
    }
    
    func loadCurrImage(){
        if(songImage == nil){
            return
        }
        var url = URL(string: "")
        if(!usingDefaultList){
            url = URL(string: ContributorsSongsSingleton.shared[currSongIndex]["image_url"]!)
        }else{
            url = URL(string: DefaultSongListSingleton.shared[currSongIndex]["image_url"]!)
        }
        
        let imageData = try? Data(contentsOf: url!)
        let image = UIImage(data: imageData!)
        songImage.image = image
    }

}
