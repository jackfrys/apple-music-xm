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

class ViewController: UITableViewController, DataServiceDelegate {
    
    private var data = [Song]()
    private let dataService = DataService()
    private var currentStation = 53
    private var currentName = ""
    
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
    
    @IBAction func back(_ sender: Any) {
        currentStation -= 1
        reload()
    }
    
    @IBAction func forward(_ sender: Any) {
        currentStation += 1
        reload()
    }
    
    @IBAction func refresh(_ sender: Any) {
        dataService.fetchFromSource(channel: currentStation)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SKCloudServiceController.authorizationStatus() == SKCloudServiceAuthorizationStatus.authorized {
            MPMusicPlayerController.systemMusicPlayer.setQueue(with: data[indexPath.row..<data.count].map({(song) in song.trackId}))
            MPMusicPlayerController.systemMusicPlayer.play()
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func reload() {
        data = [Song]()
        tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
        dataService.tracks(channel: currentStation)
    }
    
    func trackListUpdated(channel: Int, songs: [Song], stationName: String) {
        currentName = "\(String(currentStation)) - \(stationName)"
        if (channel == currentStation) {
            data = songs
            tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
            self.performSelector(onMainThread: #selector(self.updateLabel), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func updateLabel() {
        navigationController!.navigationBar.items?[0].title = currentName
    }
    
    func serverRefreshComplete(channel: Int) {
        self.refreshControl?.performSelector(onMainThread: #selector(refreshControl?.endRefreshing), with: nil, waitUntilDone: false)
        if currentStation == channel {
            dataService.fetchFromSource(channel: currentStation)
        }
    }
}

