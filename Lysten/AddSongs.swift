//
//  AddSongs.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import SwiftUI
import AVFoundation
import AVKit
import Combine

struct AddSongs: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: PlayMusic.fetchRequest()) var data: FetchedResults<PlayMusic>
    
    @State var showingSheet = false
    
    @State var songS3URL = ""
    @State var videoTitle = ""
    
    @State var player: AVPlayer?
    @State var playerItem: AVPlayerItem?
    
    @State var isPlaying = false
    
    @State var playValue: TimeInterval = 0.0
    
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
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
                              .background(colorScheme == .light ? Color.white : Color.black.opacity(0.1))
                              .padding()
                                .onTapGesture {
                                    
                                    showingSheet = true
                                    
                                    // stop playing lmfao
                                    if videoTitle != record.title && isPlaying {
                                        self.player!.pause()
                                        self.isPlaying = false
                                        player?.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
                                        playValue = 0.0
                                    }
                                    
                                    songS3URL = record.link
                                    videoTitle = record.title
                                   
                                    
                                    
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
                SheetView(songS3URL: self.$songS3URL, videoTitle: self.$videoTitle, player: self.$player, playerItem: self.$playerItem, isPlaying: self.$isPlaying, playValue: self.$playValue, timer: timer)
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
    
    @State var songDuration = ""
    
    @State var songIncrement: String = ""
    
    @Binding var playValue: TimeInterval
    
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    var body: some View {
        VStack {
            
            Image("m")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            
            HStack {
                Spacer()
                        Slider(value: $playValue, in: TimeInterval(0.0)...(CMTimeGetSeconds(player?.currentItem?.asset.duration ?? CMTime(seconds: 1, preferredTimescale: 1000000)))) {
                            Text("Song")
                        } minimumValueLabel: {
                            Text(self.songIncrement)
                        }
                        maximumValueLabel: {
                            Text(self.songDuration)
                        }
                        onEditingChanged: { _ in
                            if isPlaying == true {
                                    pauseSounds()
                                player?.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
                            }
                            
                            if isPlaying == false {
                                let url = NSURL(string: self.songS3URL)
                                self.play(url: url!)
                                
                                isPlaying = true
                            }
                        }
                                    .onReceive(timer) { _ in

                                        DispatchQueue.main.async {
                                            if isPlaying {
                                                
                                                let x = CMTimeGetSeconds(player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1000000))
                                                
                                                let a = TimeInterval(Float64(x))
                                                let max = CMTimeGetSeconds(player!.currentItem!.asset.duration)
                                                
                                                print(136, round(x), round(max))
                                                
                                                let minutes = Int(round(x) / 60)
                                                let seconds = Int(round(x)) - (minutes * 60)
                                                
                                                if seconds < 10 {
                                                    self.songIncrement = "\(minutes):0\(seconds)"
                                                } else {
                                                    self.songIncrement = "\(minutes):\(seconds)"
                                                }
                                                
                                                if round(x) >= round(max) {
                                                    playValue = 0.0
                                                    play(url: NSURL(string: self.songS3URL)!)
                                                } else {
                                                    self.playValue = a
                                                }
                                                
                                                let duration = Int(CMTimeGetSeconds(player!.currentItem!.asset.duration))
                                            
                                                let minutesx = Int(duration / 60)
                                                let secondsx = duration - (minutesx * 60)
                                                
                                                if secondsx < 10 {
                                                    self.songDuration = "\(minutesx):0\(secondsx)"
                                                } else {
                                                    self.songDuration = "\(minutesx):\(secondsx)"
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
                    Label(self.videoTitle.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".mp3", with: ""), systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.body, design: .rounded))
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
