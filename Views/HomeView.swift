//
//  HomeView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 7/15/23.
// This class is the home screen of the app that the user will be presented
// when they open the app

import SwiftUI

struct HomeView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var UID = ""
    @State private var isAnimationCompleted = false
    let youtubeURL = URL(string: "https://www.youtube.com/@amoghbantwal8179")!
    
    var body: some View {
        NavigationStack 
        {
            if networkMonitor.isConnected {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0/255, green: 47/255, blue: 100/255),
                            Color.white,
                            Color(red: 0/255, green: 47/255, blue: 100/255),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .opacity(isAnimationCompleted ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: isAnimationCompleted)
                    .edgesIgnoringSafeArea(.all)

                    VStack {
                        Spacer()
                        Text("PILLNOTIFY")
                            .font(.custom("AmericanTypewriter-Bold", size: 40))
                            .foregroundColor(.white)
                            .padding(20)
                            .onAppear {
                                UIApplication.shared.applicationIconBadgeNumber = 0
                                withAnimation(.easeInOut(duration: 1)) {
                                    isAnimationCompleted = true
                                }
                            }
                            .opacity(isAnimationCompleted ? 1 : 0)
                            .shadow(color: .black, radius: 5)

                        Text("Take your meds, and have a peaceful life ahead")
                            .multilineTextAlignment(.center)
                            .font(.custom("Arial", size: 20))
                            .foregroundColor(.white)
                            .padding(30)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1)) {
                                    isAnimationCompleted = true
                                }
                            }
                            .opacity(isAnimationCompleted ? 1 : 0)
                            .shadow(color: .black, radius: 5)

                        
                        Button(action: {
                            openYouTubeVideo()
                        }, label: {
                            Image(systemName: "heart.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.pink)
                                .overlay(
                                    Image(systemName: "pill.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(Color.pink)
                                )
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1)) {
                                        isAnimationCompleted = true
                                    }
                                }
                                .opacity(isAnimationCompleted ? 1 : 0)
                                .shadow(color: .black, radius: 5)
                        })
                        
                        Text("Click YouTube Tutorial Here!")
                            .multilineTextAlignment(.center)
                            .font(.custom("AmericanTypewriter-Bold", size: 23))
                            .foregroundColor(.white)
                            .shadow(color: .pink, radius: 5)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1)) {
                                    isAnimationCompleted = true
                                }
                            }
                            .opacity(isAnimationCompleted ? 1 : 0)
                        
                        Spacer()

                        NavigationLink(destination: SignupView(),
                        label: {
                            BottomTextView(str: "GET STARTED")
                                .clipShape(Capsule())
                                .shadow(color: .white, radius: 5)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1)) {
                                        isAnimationCompleted = true
                                    }
                                }
                                .opacity(isAnimationCompleted ? 1 : 0)
                        })
                        .padding(30)

                        Text("Already have an account?")
                            .bold()
                            .multilineTextAlignment(.center)
                            .font(.custom("Arial", size: 22))
                            .foregroundColor(.white)
                            .padding(-10)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1)) {
                                    isAnimationCompleted = true
                                }
                            }
                            .opacity(isAnimationCompleted ? 1 : 0)

                        NavigationLink(destination: SigninView(),
                        label: {
                            BottomTextView(str: "Log in")
                                .clipShape(Capsule())
                                .shadow(color: .white, radius: 5)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1)) {
                                        isAnimationCompleted = true
                                    }
                                }
                                .opacity(isAnimationCompleted ? 1 : 0)
                        }).padding(30)
                        
                        Text("PillNotify is not responsible for any health mishaps. This is solely for the purpose of reminding.")
                            .multilineTextAlignment(.center)
                            .font(.custom("AmericanTypewriter-Bold", size: 10))
                            .foregroundColor(.red)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1)) {
                                    isAnimationCompleted = true
                                }
                            }
                            .opacity(isAnimationCompleted ? 1 : 0)
                    }
                }
            } 
            else {
                LoadingView()
            }
        }
    }
    
    func openYouTubeVideo() {
        if UIApplication.shared.canOpenURL(youtubeURL) {
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
