//
//  DataService.swift
//  apple-music-xm
//
//  Created by Jack Frysinger on 9/21/17.
//  Copyright © 2017 Jack Frysinger. All rights reserved.
//

import Foundation
import SwiftSoup

class DataService {
    
    func getTracks(channel: Int, callback: ([Song]) -> Void) {
        let url = URL(string: "http://www.dogstarradio.com/search_playlist.php?artist=&title=&channel=\(channel)&month=&date=&shour=&sampm=&stz=&ehour=&eampm=")!
        let task = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: parseXM)
        task.resume()
    }
    
    func parseXM(data: Data?, response: URLResponse?, error: Error?) {
        do {
            let html = try! SwiftSoup.parse(String(describing: NSString(data: data!, encoding: String.Encoding.utf8.rawValue)))
            let text = try! html.text()
            let table = try! html.select("table").get(1).select("tr")
            var i = 0
            var songs = [Song]()
            for song in table {
                i += 1
                if i > 3 {
                    let artist = try! song.select("td").get(1).text()
                    let title = try! song.select("td").get(2).text()
                    songs.append(Song(artist: artist, title: title))
                }
            }
            print(songs)
        }
    }
}

struct Song {
    let artist: String
    let title: String
    
    init(artist: String, title: String) {
        self.artist = artist
        self.title = title
    }
}
