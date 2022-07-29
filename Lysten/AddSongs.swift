//
//  AddSongs.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import SwiftUI
import AVFoundation
import AVKit

struct AddSongs: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: PlayMusic.fetchRequest()) var data: FetchedResults<PlayMusic>
    
    @State var showingSheet = false
    
    @State var songS3URL = ""
    @State var videoTitle = ""
    
    @State var player: AVPlayer?
    @State var playerItem: AVPlayerItem?
    
    @State var isPlaying = false
    
    @State var songDuration = ""
    
    @State var playValue: TimeInterval = 0.0
    
    
    var body: some View {
        ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
            
            
            VStack {
                
                List {
                    ForEach(self.data) { record in
                            
                              HStack {
                                Text(record.title.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".mp3", with: ""))
                                        .font(.headline)
                                    Spacer()
                                  Text(record.duration)
                                }
                              .padding()
                                .onTapGesture {
                                    
                                    showingSheet = true
                                    songS3URL = record.link
                                    videoTitle = record.title
                                    
                                    // stop playing lmfao
                                    if isPlaying == true {
                                        self.player!.pause()
                                        self.isPlaying = false
                                        player?.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
                                        playValue = 0.0
                                    }
                                    
                                }
                                
                            }.onDelete(perform: { indexSet in
                                let di = data[indexSet.first!]
                                
                                self.viewContext.delete(di)
                                
                                do {
                                    try self.viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            })
                }
                
            }
            .padding().navigationBarTitle("Your playlist")
            .sheet(isPresented: $showingSheet) {
                SheetView(songS3URL: self.$songS3URL, videoTitle: self.$videoTitle, player: self.$player, playerItem: self.$playerItem, isPlaying: self.$isPlaying, songDuration: self.$songDuration, playValue: self.$playValue)
                    }
            
            Spacer()
        }
    }
    
}

struct SheetView: View {
    
    @Binding var songS3URL: String
    @Binding var videoTitle: String
    
    @Binding var player: AVPlayer?
    @Binding var playerItem: AVPlayerItem?
    
    @Binding var isPlaying: Bool
    
    @Binding var songDuration: String
    
    @Binding var playValue: TimeInterval
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            Image("m")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            Slider(value: $playValue, in: TimeInterval(0.0)...(CMTimeGetSeconds(player?.currentItem?.asset.duration ?? CMTime(seconds: 1, preferredTimescale: 1000000))), onEditingChanged: { _ in
                        if isPlaying == true {
                                pauseSounds()
                            player?.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
                        }
                        
                        if isPlaying == false {
                            player!.play()
                            isPlaying = true
                        }
                    })
                        .onReceive(timer) { _ in

                            if isPlaying {
                                
                                let x = CMTimeGetSeconds(player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1000000))
                                
                                let a = TimeInterval(Float64(x))
                                let max = CMTimeGetSeconds(player!.currentItem!.asset.duration)
                                
                                print(x,max)
                                
                                if x >= max || x + 2 >= max {
                                    playValue = 0.0
                                    play(url: NSURL(string: self.songS3URL)!)
                                    
                                } else {
                                    self.playValue = a
                                }

                            } else {
                                isPlaying = false
                                
                                print("what the hell")
                            }
                        }
//            https://api.opentennis.pro
            HStack {
                VStack {
                    Label(self.videoTitle.replacingOccurrences(of: ".mp3", with: ""), systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.body, design: .rounded))
                    Text(self.songDuration)
                        .font(.system(.headline, design: .rounded))
                        .padding()
                }.padding()
            }
            
            HStack {
                
                Button(action: {
                    if isPlaying {
                        pauseSounds()
                    } else {
                        print(self.songS3URL + " !!!!!!!!")
                        let url = NSURL(string: self.songS3URL)
                        self.play(url: url!)
                    }
                   
                }) {
                    
                    if isPlaying {
                        
                        Label("Pause", systemImage: "pause.fill")
                    } else {
                        Label("Play", systemImage: "play.fill")
                        
                    }
                   
                    
                }
               
            }.padding(15)
    }

    
}
    
    func play(url:NSURL) {
        print("playing \(url)")

        do {

            playerItem = AVPlayerItem(url: url as URL)

            self.player = try! AVPlayer(playerItem:playerItem)
            player!.volume = 1.0
            player?.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
            
            let audioSession = AVAudioSession.sharedInstance()
           
           do {
               try audioSession.setCategory(AVAudioSession.Category.playback)
           } catch {
               
           }
            
            player!.play()
            
            let duration = Int(CMTimeGetSeconds(player!.currentItem!.asset.duration))
            print(duration)
            
            let minutes = Int(duration / 60)
            let seconds = duration - (minutes * 60)
            
            if seconds < 10 {
                self.songDuration = "\(minutes):0\(seconds)"
            } else {
                self.songDuration = "\(minutes):\(seconds)"
            }
            
            self.isPlaying = true
            
            print("done")
        } catch let error as NSError {
            print("EE" + error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    func pauseSounds() {
        self.player!.pause()
        self.isPlaying = false
    }
    
   
}
