//
//  ViewController.swift
//  apple-music-xm
//
//  Created by Jack Frysinger on 9/21/17.
//  Copyright © 2017 Jack Frysinger. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataServiceDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var channel: UILabel!
    
    private var data = [Song]()
    private let dataService = DataService()
    private var currentStation = 53
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SKCloudServiceController.requestAuthorization({_ in return})
        dataService.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        dataService.tracks(channel: currentStation)
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func forward(_ sender: Any) {
        currentStation -= 1
        reload()
    }
    
    @IBAction func back(_ sender: Any) {
        currentStation += 1
        reload()
    }
    
    @IBAction func refresh(_ sender: Any) {
        dataService.fetchFromSource(channel: currentStation)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
            MPMusicPlayerController.systemMusicPlayer.setQueue(with: data[indexPath.row..<data.count].map({(song) in song.trackId}))
            MPMusicPlayerController.systemMusicPlayer.play()
        }
    }
    
    func reload() {
        channel.text = String(currentStation)
        data = [Song]()
        tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
        dataService.tracks(channel: currentStation)
    }
    
    func trackListUpdated(channel: Int, songs: [Song]) {
        if (channel == currentStation) {
            data = songs
            tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
        }
    }
}

