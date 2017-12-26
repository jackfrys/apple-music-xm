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
    var allSongs = [Int:[Song]]()
    
    func tracks(channel: Int) {
        if let tr = allSongs[channel] {
            delegate?.trackListUpdated(channel: channel, songs: tr)
        } else {
            getTracks(channel: channel)
        }
    }
    
    func fetchFromSource(channel: Int) {
        let url = URL(string: "http://radio-service.herokuapp.com/api/update/\(channel)")!
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {(data, response, error) in
            
        }
        task.resume()
    }
    
    private func getTracks(channel: Int) {
        let url = URL(string: "http://radio-service.herokuapp.com/api/tracks/\(channel)")!
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) {(data, response, error) in self.parseXM(data: data, channel: channel)}
        task.resume()
    }
    
    private func parseXM(data: Data?, channel: Int) {
        var songs = [Song]()
        if let d = data {
            let results = JSON(d)
            do {
                if (results.count > 0) {
                    let result = results[0]
                    for track in result["tracks"].array! {
                        let trackId = String(describing: track["trackId"])
                        let title = String(describing: track["title"])
                        let artist = String(describing: track["artist"])
                        songs.append(Song(artist: artist, title: title, trackId: trackId))
                    }
                }
            }
            
            delegate?.trackListUpdated(channel: channel, songs: songs)
        }
    }
    
    private func getApplsMusicAllSongs(songIndex: Int, completed: [Song], callback: @escaping (([Song]) -> Void)) {
        if songIndex == completed.count {
            callback(completed)
            return
        }
        
        getAppleMusicData(song: completed[songIndex], callback: {song in
            self.getApplsMusicAllSongs(songIndex: songIndex + 1, completed: completed, callback: callback)
        })
    }
    
    private func getAppleMusicData(song: Song, callback: @escaping ((Song) -> Void)) {
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
                        callback(song)
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
    var trackId: String
    
    init(artist: String, title: String, trackId: String) {
        self.artist = artist
        self.title = title
        self.trackId = trackId
    }
}

protocol DataServiceDelegate {
    func trackListUpdated(channel: Int, songs: [Song])
}
