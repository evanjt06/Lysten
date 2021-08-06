//
//  FindSongs.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import AVFoundation
import AVKit
import SwiftUI

struct FindSongs: View {
    
    @State var which = ""
    @State var textLink = ""
    
    @State var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
            
            VStack {
                
                Button(action: {
                    
                    which = "YouTube"
                    
                }) {
                    
                    HStack {
                        Text("Use YouTube")
                        Image("yt")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                           
                    }.font(.system(.headline, design: .rounded))
                    .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                    .background(which == "YouTube" ? Color.green : Color.init(red: 60/255, green: 114/255, blue: 201/255))
                    .foregroundColor(.white)
                    .cornerRadius(13)
                }
                .padding(2)
                
                Button(action: {
                    
                    which = "TikTok"
                    
                }) {
                    HStack {
                        Text("Use TikTok")
                        Image("tiktok")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                    }.font(.system(.headline, design: .rounded))
                    .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                    .background(which == "TikTok" ? Color.green : Color.init(red: 60/255, green: 114/255, blue: 201/255))
                    .foregroundColor(.white)
                    .cornerRadius(13)
                }
                .padding(2)
               
                Divider()
                
                HStack {
                TextField("Please enter the link", text: $textLink)
                    .padding(10)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                  
                    Spacer()
                    
                    Button(action: {
                        print("play")
                        let url = NSURL(string: "https://s3.us-west-2.amazonaws.com/calc.masa.space/hello.mp3")
                        self.play(url: url!)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .scaleEffect(1.5)
                            .accentColor(.white)
                    }
                }.padding(10)
                    
                
                Spacer()
                    
                
//                SongView()
                
            }.navigationBarTitle("Find songs")
            .padding()
        }
    }
    
    
    func play(url:NSURL) {
        print("playing \(url)")

        do {

            let playerItem = AVPlayerItem(url: url as URL)

            self.player = try! AVPlayer(playerItem:playerItem)
            player!.volume = 1.0
            player!.play()
            
            print("done")
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }

}

struct FindSongs_Previews: PreviewProvider {
    static var previews: some View {
        FindSongs()
    }
}

struct SongView: View {
    
    @State var audioPlayer: AVAudioPlayer!
    @State var isPlaying = false
    
    var body: some View {
        
        return VStack {
            
            Image("sample1")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
//            TODO: implement slider for music player!!!, repeat loop!!!
            
            HStack {
                VStack {
                    Label("bossa nova - billie eilish", systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                }.padding()
                Spacer()
                Text("3:43")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
            }
            
            HStack {
                
                Button(action: {
                    if isPlaying {
                        pauseSounds()
                    } else {
                        playSounds("bossa.mp3")
                    }
                    
                }) {
                    
                    if isPlaying {
                        
                        Label("Pause", systemImage: "pause.fill")
                            .accentColor(.white)
                    } else {
                        Label("Play", systemImage: "play.fill")
                            .accentColor(.white)
                        
                    }
                   
                    
                }
                Spacer()
                
                Button(action: {}) {
                    Label("Save song/audio", systemImage: "checkmark")
                        .accentColor(.white)
                }
               
            }.padding()
        }
    }
    
    func playSounds(_ soundFileName : String) {
            guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
                fatalError("Unable to find \(soundFileName) in bundle")
            }
        
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer.prepareToPlay()
                
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setCategory(AVAudioSession.Category.playback)
                } catch {
                    
                }
                
            } catch {
                print(error.localizedDescription)
            }
          
        audioPlayer.play()
        self.isPlaying = true
        }
    
    func pauseSounds() {
        audioPlayer.pause()
        self.isPlaying = false
    }
}
