//
//  ContentView.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import SwiftUI

struct ContentView: View {
    
    init() {
            //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Copperplate", size: 45)!, .foregroundColor: UIColor.white]

        }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.init(red: 30/255, green: 37/255, blue: 84/255).ignoresSafeArea(.all)

                VStack {
                    
                    ScrollView(showsIndicators: false) {
                                  
                        NavigationLink(destination: FindSongs()) {
                            VStack(alignment: .trailing ) {
                                HStack(alignment: .top){
                                    VStack(alignment: .leading) {
                                        Text("Find Songs")
                                            .foregroundColor(.white)
                                            .font(.title)
                                            .bold()
                                        Text("Use Youtube and TikTok to find your favorite songs!")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
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
                                        Text("Add songs to playlist")
                                            .foregroundColor(.white)
                                            .font(.title)
                                            .bold()
                                        
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
                        
                        NavigationLink(destination: LiveRecord()) {
                            VStack(alignment: .trailing ) {
                                HStack(alignment: .top){
                                    VStack(alignment: .leading) {
                                        Text("Live Record")
                                            .foregroundColor(.white)
                                            .font(.title)
                                            .bold()
                                        Text("Use music recognition")
                                            .foregroundColor(.white)
                                            .font(.subheadline)
                                            .foregroundColor(Color.secondary)
                                        
                                        HStack {
                                            Spacer()
                                        Image("c")
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
                            .background(LinearGradient(gradient: Gradient(colors: [Color("C3"), Color("C4")]), startPoint: .top, endPoint: .bottomTrailing))
                            .cornerRadius(20)
                            .shadow(radius: 12)
                            .padding(.bottom, 20)
                        }
                            
                                    
                    }.padding(.top)

                }.navigationBarTitle("Lysten")

            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
