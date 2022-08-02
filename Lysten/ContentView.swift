//
//  ContentView.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import SwiftUI
import Combine

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var isMP3: Bool { typeIdentifier == "public.mp3" }
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}

struct ContentView: View {
    
    @State var songRecordArray = [SongRecord]()
    
    init() {
            //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Copperplate", size: 30)!, .foregroundColor: UIColor.white]

        }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)

                VStack {
                    
                    ScrollView(showsIndicators: false) {
                                  
                        NavigationLink(destination: FindSongs(songRecordArray: $songRecordArray)) {
                            VStack(alignment: .trailing ) {
                                HStack(alignment: .top){
                                    VStack(alignment: .leading) {
                                        Text("Find Songs")
                                            .foregroundColor(.white)
                                            .font(.title)
                                            .bold()
                                        Text("Use Youtube and Tiktok to find your favorite songs!")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(Color.secondary)
                                        
                                        HStack {
                                            Spacer()
                                        Image("a")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            Spacer()
                                        }
                                    }.padding(.horizontal, 0)
                                    Spacer()
                                }.padding()
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width - 40, height: 280)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("C1"), Color("C4")]), startPoint: .top, endPoint: .bottomTrailing))
                            .cornerRadius(20)
                            .shadow(radius: 12)
                            .padding(.bottom, 20)  
                        }
                        
                        NavigationLink(destination: AddSongs()) {
                            VStack(alignment: .trailing ) {
                                HStack(alignment: .top){
                                    VStack(alignment: .leading) {
                                        Text("Your YouTube Playlist")
                                            .foregroundColor(.white)
                                            .font(.title)
                                            .bold()
                                        Text("Play songs straight from YouTube!")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(Color.secondary)
                                        
                                        HStack {
                                            Spacer()
                                        Image("b")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            Spacer()
                                        }
                                            
                                    }.padding(.horizontal, 0)
                                    Spacer()
                                }.padding()
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width - 40, height: 280)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("C3"), Color("C2")]), startPoint: .top, endPoint: .bottomTrailing))
                            .cornerRadius(20)
                            .shadow(radius: 12)
                            .padding(.bottom, 20)
                        }
                        
                        NavigationLink(destination: TiktokView()) {
                            VStack(alignment: .trailing ) {
                                HStack(alignment: .top){
                                    VStack(alignment: .leading) {
                                        Text("Your Tiktok Playlist")
                                            .foregroundColor(.white)
                                            .font(.title)
                                            .bold()
                                        Text("Play audios straight from TikTok!")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(Color.secondary)
                                        
                                        
                                        HStack {
                                            Spacer()
                                        Image("b")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            Spacer()
                                        }
                                            
                                    }.padding(.horizontal, 0)
                                    Spacer()
                                }.padding()
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width - 40, height: 280)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("C5"), Color("C4")]), startPoint: .top, endPoint: .bottomTrailing))
                            .cornerRadius(20)
                            .shadow(radius: 12)
                            .padding(.bottom, 20)
                        }
                                    
                    }.padding(.top)

                }.navigationBarTitle("Lysten")

            }.onAppear {
                do {
                    // Get the document directory url
                    let documentDirectory = try FileManager.default.url(
                        for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true
                    )
                 
                    let directoryContents = try FileManager.default.contentsOfDirectory(
                        at: documentDirectory,
                        includingPropertiesForKeys: nil
                    )
                 
                    // if you would like to hide the file extension
                    for var url in directoryContents {
                        url.hasHiddenExtension = true
                    }
                 
                    // if you want to get all mp3 files located at the documents directory:
                    let mp3s = directoryContents.filter(\.isMP3).map { $0.localizedName ?? $0.lastPathComponent }
                    print("mp3s:", mp3s)
                    
                } catch {
                    print(error)
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct SongRecord: Identifiable {
    let id = UUID()
    var name: String
    var duration: String
    var linkToS3: String
}
