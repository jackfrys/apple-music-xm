//
//  ViewController.swift
//  apple-music-xm
//
//  Created by Jack Frysinger on 9/21/17.
//  Copyright © 2017 Jack Frysinger. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, DataServiceDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var data: [Song]?
    private let dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataService.delegate = self
        tableView.dataSource = self
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = data?[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = data {
            return d.count
        } else {
            return 0
        }
    }
    
    func reload() {
        dataService.getTracks(channel: 53)
    }
    
    func trackListUpdated(songs: [Song]) {
        data = songs
        tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
    }
}

