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
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var songRecordArray: [SongRecord]
    
    @State var textLink = ""
    @State var vidTitle = ""
    @State var temp = ""
    
    @State var isLoading = false
    
    @State var status = ""
    
    var body: some View {
        ZStack {
            Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)
            
            VStack {
                
                VStack {
                    HStack {
                        Text("1. Open YouTube App").foregroundColor(Color.white)
                        Spacer()
                    }
                    HStack {
                        Text("2. Search up a music video").foregroundColor(Color.white)
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
                        
                        isLoading = true
                       
                        if textLink.contains("https://www.youtube.com/watch?v=") {
                            temp = textLink.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "")

                            // check for -
                            if temp.prefix(1) == "-" {
                                status = "Error processing URL. Find another video."
                                return
                            }
                            
                            status = "Song is loading..."
                            
                            sendApiCall(urlString: temp)

                            print(temp)


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

                            
                            sendApiCall(urlString: temp)
                        } else if textLink.contains("https://youtu.be/") {
                            temp = textLink.replacingOccurrences(of: "https://youtu.be/", with: "")

                            // check for -
                            if temp.prefix(1) == "-" {
                                status = "Error processing URL. Find another video."
                                return
                            }
                            
                            status = "Song is loading..."
                            
                            sendApiCall(urlString: temp)
                        }
                        

                        
                        textLink = ""
                    // https://www.youtube.com/watch?v=----asdasd
                        
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
                
               if !isLoading && vidTitle != "" && temp != "" {
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
                    self.status = ""
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
    
    var cml: String
    
    var videoTitle: String
    var date: Date
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
    var body: some View {
        
        return VStack {
            
            Image("m")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack {
                Spacer()
                
                
              
            Slider(value: $playValue, in: TimeInterval(0.0)...(CMTimeGetSeconds(player?.currentItem?.asset.duration ?? CMTime(seconds: 1, preferredTimescale: 1000000)))) {
                Text("song")
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
                  player!.play()
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
                    Label(videoTitle.replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: "_", with: " "), systemImage: "music.note")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
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

                       print("SAVED")
                   } catch {
                       print("\(error.localizedDescription)")
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
