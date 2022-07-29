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
    
    @Binding var songRecordArray: [SongRecord]
    
    @State var textLink = ""
    @State var vidTitle = ""
    @State var temp = ""
    
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
            
            VStack {
                
                Button(action: {
                  
                    let url = URL (string: "https://www.youtube.com")!
                     UIApplication.shared.open (url)
                    
                }) {
                    
                    HStack {
                        Text("Use YouTube")
                        Image("yt")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                           
                    }.font(.system(.headline, design: .rounded))
                    .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                    .background(Color.init(red: 60/255, green: 114/255, blue: 201/255))
                    .foregroundColor(.white)
                    .cornerRadius(13)
                }
                .padding(2)
             
                HStack {
                TextField("Please enter the link", text: $textLink)
                    .padding(10)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                  
                    Spacer()
                    
                    Button(action: {
                        
                        if textLink == "" {
                            print("EMPTY")
                            return
                        }
                        
                       
                        if textLink.contains("https://www.youtube.com/watch?v=") {
                            temp = textLink.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "")

                            sendApiCall(urlString: temp)

                            print(temp)


                        } else if textLink.contains("https://youtu.be/") && textLink.contains("?list=") {

                            temp = textLink.replacingOccurrences(of: "https://youtu.be/", with: "").replacingOccurrences(of: "?list=", with: " ")
                            let tt = temp.split(separator: " ")

                            print(tt[0])

                            temp = String(tt[0])
                            sendApiCall(urlString: String(tt[0]))
                        } else if textLink.contains("https://youtu.be/") {
                            temp = textLink.replacingOccurrences(of: "https://youtu.be/", with: "")

                            print(temp)
                            sendApiCall(urlString: temp)
                        }
                        

                        
                        textLink = ""
                        
                        
                    }) {
                        Image(systemName: "magnifyingglass")
                            .scaleEffect(1.5)
                            .accentColor(.white)
                    }
                }.padding(10)
                    
                
                Spacer()
                
                if isLoading {
                    Text("Song is still loading...")
                        .font(.title)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if isLoading == false && vidTitle != "" && temp != "" {
                    SongView(songRecordArray: $songRecordArray, cml: temp, videoTitle: vidTitle, date: Date())
                }
                
            }.navigationBarTitle("Find songs")
            .padding()
        }
    }

    
    func sendApiCall(urlString: String) {
        
        if urlString.count != 11 || urlString == "" {
            return
        }
        
        self.isLoading = true
        
        let url = URL(string: "http://50.18.240.5:8080/upload?q=" + urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.timeoutInterval = 10000000
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    
                    self.vidTitle = dataString
                    self.isLoading = false
                }
        }
        task.resume()
        
        
    }

}


struct SongView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var songRecordArray: [SongRecord]
    
    @State var player: AVPlayer?
    @State var playerItem: AVPlayerItem?
    
    @State var isPlaying = false
    
    @State var songDuration = ""
    
    @State var playValue: TimeInterval = 0.0
    
    @State var saved = false
    
    var cml: String
    
    var videoTitle: String
    var date: Date
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
    var body: some View {
        
        return VStack {
            
            Image("m")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
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
                                print(x,a)
                                
                                let max = CMTimeGetSeconds(player!.currentItem!.asset.duration)
                                print(max)
                                if x >= max {
                                    playValue = 0.0
                                    isPlaying = false
                                } else {
                                    self.playValue = a
                                }

                            } else {
                                isPlaying = false
                                
                                print("what the hell")
                            }
                        }
   
            HStack {
                VStack {
                    Label(videoTitle.replacingOccurrences(of: ".mp3", with: ""), systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                    Text(self.songDuration)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                }.padding()
            }
            
            HStack {
                
                Button(action: {
                    if isPlaying {
                        pauseSounds()
                    } else {
                        let url = NSURL(string: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3")
                        self.play(url: url!)
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
                
                Button(action: {
                    
                    if (saved) {
                        return
                    }
                    
                    let sr = SongRecord(name: videoTitle, duration: songDuration, linkToS3: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3")
                    
                    songRecordArray.append(sr)
                    
//                  replace this with core data
                    let playlist: PlayMusic
                    playlist = PlayMusic(context: viewContext)
                    playlist.link = "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3"
                    playlist.title = videoTitle
                    playlist.duration = songDuration
                    playlist.date = date
                    
                    do {
                       try self.viewContext.save()

                       print("playlist shit SAVED")
                   } catch {
                       print("280 shit - \(error.localizedDescription)")
                   }
                    
                    saved = true
                    
                }) {
                    Label(saved == true ? "Saved song/audio" : "Save song/audio", systemImage: "checkmark")
                        .accentColor(.white)
                }
               
            }.padding()
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
