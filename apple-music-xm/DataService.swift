//
//  DataService.swift
//  apple-music-xm
//
//  Created by Jack Frysinger on 9/21/17.
//  Copyright © 2017 Jack Frysinger. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftyJSON

class DataService {
    
    var delegate: DataServiceDelegate?
    
    func getTracks(channel: Int) {
        let url = URL(string: "http://www.dogstarradio.com/search_playlist.php?artist=&title=&channel=\(channel)&month=&date=&shour=&sampm=&stz=&ehour=&eampm=")!
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {(data, response, error) in self.parseXM(data: data)}
        task.resume()
    }
    
    func parseXM(data: Data?) {
        do {
            let html = try! SwiftSoup.parse(String(describing: NSString(data: data!, encoding: String.Encoding.utf8.rawValue)))
            let table = try! html.select("table").get(1).select("tr")
            var i = 0
            var songs = [Song]()
            for song in table {
                i += 1
                if i > 3 {
                    let artist = try! song.select("td").get(1).text()
                    let title = try! song.select("td").get(2).text()
                    let song: Song = Song(artist: artist, title: title)
                    songs.append(song)
                    getAppleMusicData(song: song, songs: songs)
                }
            }
        }
    }
    
    func getAppleMusicData(song: Song, songs: [Song]) {
        let url = URL(string: "https://itunes.apple.com/search?term=\(song.title.replacingOccurrences(of: " ", with: "+"))+\(song.artist.replacingOccurrences(of: " ", with: "+"))&entity=song")
        if let u = url {
            let task = URLSession.shared.dataTask(with: u) {(data, response, error) in
                if let d = data {
                    let results = JSON(d)["results"]
                    do {
                        let result = results[0]
                        song.trackId = String(describing: result["trackId"])
                        song.title = String(describing: result["trackName"])
                        song.artist = String(describing: result["artistName"])
                        
                        self.delegate?.trackListUpdated(songs: songs.filter({song in
                            if let tid = song.trackId {
                                return tid != "null"
                            } else {
                                return false
                            }
                        }))
                    }
                }
            }
            task.resume()
        }
    }
}

class Song {
    var artist: String
    var title: String
    var trackId: String?
    
    init(artist: String, title: String) {
        self.artist = artist
        self.title = title
    }
}

protocol DataServiceDelegate {
    func trackListUpdated(songs: [Song])
}
