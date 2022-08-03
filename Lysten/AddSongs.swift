//
//  AddSongs.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import SwiftUI
import AVFoundation
import AVKit
import ObjectiveC
import Combine

struct AddSongs: View {
    
    @ObservedObject var downloader = DownloadManager()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: PlayMusic.fetchRequest()) var data: FetchedResults<PlayMusic>
    
    @State var showingSheet = false
    
    @State var songS3URL = ""
    @State var videoTitle = ""
    
    @State var player: AVQueuePlayer = AVQueuePlayer()
    @State var playerLayer: AVPlayerLayer?
    @State var playerLooper: AVPlayerLooper?
    @State var playerItem: AVPlayerItem?
    
    @State var isPlaying = false
    
    @State var playValue: TimeInterval = 0.0
    
    @State var currentSongPlaying = "null"
    
    var body: some View {
        
        return ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
            
            
            VStack {
                
                List {
                    ForEach(self.data) { record in
                        
                        HStack {
                            
                            if (currentSongPlaying == record.link) {
                               Label("", systemImage: "waveform")
                                    .font(Font.title2)
                            }
                                
                            Text(record.title.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: "\"", with: ""))
                                      .font(.headline)
                                  Spacer()
                                Text(record.duration)
                                
                               
                                }
                        .background(colorScheme == .light ? Color.white : Color.black.opacity(0.04))
                              .padding()
                                .onTapGesture {
                                    
                                    showingSheet = true
                                  
                                    if videoTitle != record.title && isPlaying {
                                        self.player.pause()
                                        self.isPlaying = false
                                        player.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
                                        playValue = 0.0
                                    }
                                    
                                    songS3URL = record.link
                                    videoTitle = record.title
                                   
                                    
                                    
                                }
                                
                            }.onDelete(perform: { indexSet in
                                let di = data[indexSet.first!]
                                
                                self.viewContext.delete(di)
                                
                                downloader.deleteFile(url: di.link.replacingOccurrences(of: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/", with: ""))
                                
                                do {
                                    try self.viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            })
                }
            
            }
           
            .padding().navigationBarTitle("Your Youtube playlist")
            .sheet(isPresented: $showingSheet) {
                SheetView(songS3URL: self.$songS3URL, videoTitle: self.$videoTitle, player: self.$player, playerItem: self.$playerItem, playerLayer: self.$playerLayer, playerLooper: self.$playerLooper, isPlaying: self.$isPlaying, playValue: self.$playValue, currentSongPlaying: $currentSongPlaying)
                    }
            
            Spacer()
        }
    }
    
}

struct SheetView: View {
    
    @ObservedObject var downloader = DownloadManager()
    
    @Binding var songS3URL: String
    @Binding var videoTitle: String
    
    @Binding var player: AVQueuePlayer
    @Binding var playerItem: AVPlayerItem?
    @Binding var playerLayer: AVPlayerLayer?
    @Binding var playerLooper: AVPlayerLooper?
    
    @Binding var isPlaying: Bool
    
    @State var songDuration = ""
    
    @State var songIncrement: String = ""
    
    @Binding var playValue: TimeInterval
    
    @Binding  var currentSongPlaying: String
    
    var timer: Publishers.Autoconnect<Timer.TimerPublisher> =  Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
        
        VStack {
            
            Image("m")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            
            HStack {
                Spacer()
                        Slider(value: $playValue, in: TimeInterval(0.0)...(CMTimeGetSeconds(player.currentItem?.asset.duration ?? CMTime(seconds: 1, preferredTimescale: 1000000)))) {
                            Text("Song")
                        } minimumValueLabel: {
                            Text(self.songIncrement)
                                .foregroundColor(Color.white)
                        }
                        maximumValueLabel: {
                            Text(self.songDuration)
                                .foregroundColor(Color.white)
                        }
                        onEditingChanged: { _ in
                            if isPlaying == true {
                                    pauseSounds()
                                player.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
                               
                            }
                            
                            if isPlaying == false {
                                let url = NSURL(string: self.songS3URL)
                                self.play(url: url!)
                                
                                isPlaying = true
                            }
                        }
                        .disabled(true)
                                    .onReceive(timer) { _ in

                                        if player.currentItem != nil {
                                            
                                            if isPlaying {
                                              
                                                let x = CMTimeGetSeconds(player.currentTime())

                                                let a = TimeInterval(Float64(x))
                                              
                                                let minutes = Int(round(x) / 60)
                                                let seconds = Int(round(x)) - (minutes * 60)

                                                if seconds < 10 {
                                                    self.songIncrement = "\(minutes):0\(seconds)"
                                                } else {
                                                    self.songIncrement = "\(minutes):\(seconds)"
                                                }

                                             
                                                self.playValue = a
                                                

                                                if (player.currentItem?.asset != nil) {
                                                    let duration = Int(CMTimeGetSeconds(player.currentItem!.asset.duration))

                                                    let minutesx = Int(duration / 60)
                                                    let secondsx = duration - (minutesx * 60)

                                                    if secondsx < 10 {
                                                        self.songDuration = "\(minutesx):0\(secondsx)"
                                                    } else {
                                                        self.songDuration = "\(minutesx):\(secondsx)"
                                                    }
                                                }
                                               

                                            } else {
                                                isPlaying = false
                                            }
                                        }
                                    }
                Spacer()
            }

            HStack {
                VStack {
                    Label(self.videoTitle.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".mp3", with: ""), systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color.white)
                        .font(Font.headline.weight(.bold))
                }.padding()
            }
            
            HStack {
                
                Button(action: {
                    if isPlaying {
                        pauseSounds()
                    } else {
                        let url = NSURL(string: self.songS3URL)
                        self.play(url: url!)
                    }
                   
                }) {
                    
                    if isPlaying {
                        
                        Label("Pause", systemImage: "pause.fill")
                            .frame(width: 100, height: 100)
                            .background(Color.black)
                            .clipShape(Circle())
                            .font(Font.headline.weight(.light))
                            
                    } else {
                        Label("Play", systemImage: "play.fill")
                            .frame(width: 100, height: 100)
                            .background(Color.black)
                            .clipShape(Circle())
                            .font(Font.headline.weight(.light))
                        
                    }
                   
                    
                }
               
            }.padding(15)
        }
        
    }

    
    }
 
    func play(url:NSURL) {
        print("playing \(url)")
        
//        check if the URL is downloaded locally
        downloader.checkFileExists(url: url.absoluteString!.replacingOccurrences(of: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/", with: ""))
        if downloader.isDownloaded {
           
            do {

             
                let pitem = downloader.getVideoFileAsset(url: url.absoluteString!.replacingOccurrences(of: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/", with: ""))
                
                player = AVQueuePlayer()
                
                playerLayer = AVPlayerLayer(player: player)
   
                playerLooper = AVPlayerLooper(player: player, templateItem: pitem!)
                
                let audioSession = AVAudioSession.sharedInstance()
               
               do {
                   try audioSession.setCategory(AVAudioSession.Category.playback)
               } catch {
                   
               }
              
                player.play()
                
                self.currentSongPlaying = url.absoluteString!
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                  
                    self.isPlaying = true
                }
              
            } catch let error as NSError {
                print("EE" + error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        }
            
     
        if !downloader.isDownloaded {
            
            do {

             
                playerItem = AVPlayerItem(url: url as URL)
                
                player = AVQueuePlayer()
                
                playerLayer = AVPlayerLayer(player: player)
    //
                playerLooper = AVPlayerLooper(player: player, templateItem: playerItem!)
                
                let audioSession = AVAudioSession.sharedInstance()
               
               do {
                   try audioSession.setCategory(AVAudioSession.Category.playback)
               } catch {
                   
               }
              
                player.play()
                
                self.currentSongPlaying = url.absoluteString!
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                   
                    self.isPlaying = true
                }
              
            } catch let error as NSError {
                print("EE" + error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        }

    }
    
    func pauseSounds() {
        self.player.pause()
        self.isPlaying = false
        
        print("Stopped playing.")
    }
    
   
}
