//
//  FindSongs.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import AVFoundation
import AVKit
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct FindSongs: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var songRecordArray: [SongRecord]
    
    @State var textLink = ""
    @State var vidTitle = ""
    @State var temp: String = ""
    
    @State var isLoading = false
    
    @State var status = ""
    @State var isTiktokSong = false
    
    @State private var timeRemaining = 90
    @State var countdown = Timer.publish(every: 1, on: .main, in: .common)
    @State private var isCountdownVisible = false
    
    var body: some View {
        ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
            
            VStack {
                
                VStack {
                    HStack {
                        Text("1. Open YouTube/Tiktok App").foregroundColor(Color.white)
                        Spacer()
                    }
                    HStack {
                        Text("2. Search up a music video/Tiktok audio").foregroundColor(Color.white)
                        Spacer()
                    }
                    HStack {
                        Text("3. Paste video link into Lysten and search").foregroundColor(Color.white)
                        Spacer()
                    }
                        
                }.padding(.bottom)
                
                Button(action: {
                  
                    let url = URL (string: "https://www.youtube.com")!
                     UIApplication.shared.open (url)
                    
                }) {
                    
                    HStack {
                        Text("Use YouTube")
                        Image(systemName: "video")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accentColor(Color.black)
                            .foregroundColor(Color.black)
                            .frame(width: 30, height: 30)
                           
                    }.font(.system(.headline, design: .rounded))
                    .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                    .background(Color.init(red: 60/255, green: 114/255, blue: 201/255))
                    .foregroundColor(.white)
                    .cornerRadius(13)
                }
                .padding(2)
                
                Button(action: {
                  
                    let url = URL (string: "https://www.tiktok.com")!
                     UIApplication.shared.open (url)
                    
                }) {
                    
                    HStack {
                        Text("Use Tiktok")
                        Image(systemName: "airpodsmax")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accentColor(Color.black)
                            .foregroundColor(Color.black)
                            .frame(width: 30, height: 30)
                           
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
                            status = "Please provide a link."
                            return
                        }
                        
                        isLoading = true
                        timeRemaining = 90
                        countdown = Timer.publish(every: 1, on: .main, in: .common)
                        countdown.connect()
                 
                        if textLink.contains("https://www.tiktok.com/t/") {
                            
                            temp = textLink.replacingOccurrences(of: "https://www.tiktok.com/t/", with: "").replacingOccurrences(of: "/?k=1", with: "")
                            status = "Song is loading..."
                            isCountdownVisible = true
                            sendApiCall_Tiktok(urlString: textLink)

                        } else if textLink.contains("https://www.youtube.com/watch?v=") {
                            temp = textLink.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "")

                            // check for -
                            if temp.prefix(1) == "-" {
                                status = "Error processing URL. Find another video."
                                return
                            }
                            
                            status = "Song is loading..."
                            isCountdownVisible = true
                            temp = String(temp.prefix(11))
                            sendApiCall(urlString: temp)

                        } else if textLink.contains("https://m.youtube.com/watch?v=") {
                            
                            temp = String(textLink.replacingOccurrences(of: "https://m.youtube.com/watch?v=", with: "").prefix(11))
                        
                            
                            // check for -
                            if temp.prefix(1) == "-" {
                                status = "Error processing URL. Find another video."
                                return
                            }
                            
                            status = "Song is loading..."
                            isCountdownVisible = true
                            
                            sendApiCall(urlString: temp)
                            
                        } else if textLink.contains("https://youtu.be/") && textLink.contains("?list=") {

                            temp = textLink.replacingOccurrences(of: "https://youtu.be/", with: "").replacingOccurrences(of: "?list=", with: " ")
                            let tt = temp.split(separator: " ")
                            temp = String(tt[0])
                            
                            // check for -
                            if temp.prefix(1) == "-" {
                                status = "Error processing URL. Find another video."
                                return
                            }
                            
                            status = "Song is loading..."
                            isCountdownVisible = true
                            
                            sendApiCall(urlString: temp)
                        } else if textLink.contains("https://youtu.be/") {
                            temp = textLink.replacingOccurrences(of: "https://youtu.be/", with: "")

                            // check for -
                            if temp.prefix(1) == "-" {
                                status = "Error processing URL. Find another video."
                                return
                            }
                            
                            status = "Song is loading..."
                            isCountdownVisible = true
                            sendApiCall(urlString: temp)
                        } else {
                            status = "Please find another video."
                        }
                        
                        textLink = ""
                        hideKeyboard()
                        
                    }) {
                        Image(systemName: "magnifyingglass")
                            .scaleEffect(1.5)
                            .accentColor(.white)
                    }
                }.padding(10)
                
                Spacer()
                
                Text(self.status)
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                if (isCountdownVisible) {
                    Text("Processing Request: " + String(timeRemaining))
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
               
               if !isLoading && vidTitle != "" && temp != "" {
                   SongView(songRecordArray: $songRecordArray, cml: temp, videoTitle: vidTitle, date: Date(), isTiktokSong: isTiktokSong)
                }
                
            }.navigationBarTitle("Find songs")
            .padding()
        }.onReceive(countdown) { time in
            if timeRemaining == 0 {
                self.status = "Error processing request. Please try another video."
                isCountdownVisible = false
                self.countdown.connect().cancel()
                timeRemaining = 90
            }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
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
        request.timeoutInterval = 90
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
                    
                    if dataString == "\"Video too long\"" {
                        self.status = "Your selected video is too long to be processed."
                        self.countdown.connect().cancel()
                        isCountdownVisible = false
                        timeRemaining = 90
                        return
                    }
                    
                    self.vidTitle = dataString
                    self.isLoading = false
                    self.status = ""
                    self.countdown.connect().cancel()
                    isCountdownVisible = false
                    timeRemaining = 90
                }
        }
        task.resume()
        
        
    }
    
    
    func sendApiCall_Tiktok(urlString: String) {
        
        if urlString == "" {
            return
        }
        
        self.isLoading = true
        
        let url = URL(string: "http://50.18.240.5:8080/uploadTiktok?q=" + urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.timeoutInterval = 90
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
                    self.status = ""
                    self.countdown.connect().cancel()
                    isCountdownVisible = false
                    timeRemaining = 90
                    isTiktokSong = true
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
    
    @State var songIncrement: String = ""
    
    @State var playValue: TimeInterval = 0.0
    
    @State var saved = false
    
    @State var isActive = false
    
    var cml: String
    
    var videoTitle: String
    var date: Date
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @ObservedObject var downloader = DownloadManager()
    
    var isTiktokSong: Bool
  
    var body: some View {
        
        return VStack {
            
            Image("m")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack {
             
            Slider(value: $playValue, in: TimeInterval(0.0)...(CMTimeGetSeconds(player?.currentItem?.asset.duration ?? CMTime(seconds: 1, preferredTimescale: 1000000)))) {
                Text("song")
            } minimumValueLabel: {
               Text(self.songIncrement) .foregroundColor(Color.white)
           }
           maximumValueLabel: {
               Text(self.songDuration) .foregroundColor(Color.white)
           }
           onEditingChanged: { _ in
               if isPlaying == true {
                      pauseSounds()
                  player?.seek(to: CMTime(seconds: playValue, preferredTimescale: 1000000))
              }
              
              if isPlaying == false {
                  if (player != nil) {
                      player?.play()
                      isPlaying = true
                  }
              }
           }
           .disabled(!isActive)
          .onReceive(timer) { _ in

              DispatchQueue.main.async {
                  if isPlaying {
                      
                      let x = CMTimeGetSeconds(player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1000000))
                      
                      let a = TimeInterval(Float64(x))
                      let max = CMTimeGetSeconds(player!.currentItem!.asset.duration)
                      
                      
                      let minutes = Int(round(x) / 60)
                      let seconds = Int(round(x)) - (minutes * 60)
                      
                      if seconds < 10 {
                          self.songIncrement = "\(minutes):0\(seconds)"
                      } else {
                          self.songIncrement = "\(minutes):\(seconds)"
                      }
                      
                      if round(x) >= round(max) {
                          playValue = 0.0
                          isPlaying = false
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
                    Label(videoTitle.replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "_", with: " "), systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                }.padding()
            }
            
            HStack {
                
                Button(action: {
                    isActive = true
                    if isPlaying {
                        pauseSounds()
                    } else {
                        let url = NSURL(string: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3")
                        self.play(url: url!)
                    }
                   
                }) {
                    
                    if isPlaying {
                        
                        Label("Pause", systemImage: "pause.fill")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .foregroundColor(Color.white)
                            .background(Color.black)
                            .accentColor(.white)
                            .font(Font.headline.weight(.bold))
                            .cornerRadius(45)
                        
                    } else {
                        Label("Play", systemImage: "play.fill")
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .foregroundColor(Color.white)
                            .background(Color.black)
                            .accentColor(.white)
                            .font(Font.headline.weight(.bold))
                            .cornerRadius(45)
                        
                    }
                   
                    
                }
                Spacer()
                
                Button(action: {
                    
                    if (saved) {
                        return
                    }
                    
                    // https://m.youtube.com/watch?v=Z3W0jKcv1SU&t=178s#dialog
                    // get song duration when user doesnt play song
                    let x = AVPlayerItem(url: NSURL(string: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3")! as URL)
                    let xplayer: AVPlayer? = try! AVPlayer(playerItem: x)
                    let duration = Int(CMTimeGetSeconds(xplayer!.currentItem!.asset.duration))
                
                    let minutesx = Int(duration / 60)
                    let secondsx = duration - (minutesx * 60)
                    
                    if secondsx < 10 {
                        self.songDuration = "\(minutesx):0\(secondsx)"
                    } else {
                        self.songDuration = "\(minutesx):\(secondsx)"
                    }
                    
                    if (isTiktokSong) {
                        let tkok: TiktokSongs
                        tkok = TiktokSongs(context: viewContext)
                        tkok.link = "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3"
                        tkok.title = videoTitle
                        tkok.duration = songDuration
                        tkok.date = date
                    }
                    if (!isTiktokSong) {
                       let playlist: PlayMusic
                       playlist = PlayMusic(context: viewContext)
                       playlist.link = "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + cml + ".mp3"
                       playlist.title = videoTitle
                       playlist.duration = songDuration
                       playlist.date = date
                    }
                 
                    do {
                       try self.viewContext.save()

                   } catch {
                       print("\(error.localizedDescription)")
                   }
                    
                    saved = true
                    
                    // download here
                    downloader.downloadFile(url: cml)
                    
                }) {
                    Label(saved == true ? "Downloaded song" : "Download song", systemImage: "checkmark")
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .accentColor(.white)
                        .font(Font.headline.weight(.bold))
                        .cornerRadius(45)
                    
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
