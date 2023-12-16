//
//  StartCaretakerTab.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/28/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import UserNotifications
import AWSSES

// This struct is the tab view that is shown when the app is opened after teminating, and it allows user to navigate to
// other screens
struct StartCaretakerTab: View {
    private let database = Database.database().reference()
    
    @State private var logout = false
    @State private var newaccount = false
    @State private var loginaccount = false

    @StateObject private var networkMonitor = NetworkMonitor()
    
    @Binding var path: NavigationPath
    
    @State private var tabSelected: CaretakerTab = .pill
    

    var body: some View {
        NavigationStack(path: $path)
        {
            if networkMonitor.isConnected
            {
                ZStack {
                    VStack {
                        TabView(selection: $tabSelected) {
                            ForEach(CaretakerTab.allCases, id: \.rawValue) { tab in
                                if (tab.rawValue.capitalized == "Pill") {
                                    CaretakerMedView()
                                        .animation(nil, value: tabSelected)
                                        .tag(tab)
                                }
                                else if (tab.rawValue.capitalized == "Folder") {
                                    ReportsView()
                                        .animation(nil, value: tabSelected)
                                        .tag(tab)
                                }
                                else if (tab.rawValue.capitalized == "Message") {
                                    CaretakerMessageView()
                                        .animation(nil, value: tabSelected)
                                        .tag(tab)
                                }
                                else {
                                    CaretakerProfileView()
                                        .animation(nil, value: tabSelected)
                                        .tag(tab)
                                }
                                
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        CustomTabBar(selectedTab: $tabSelected)
                    }
                }
                .navigationBarBackButtonHidden()
                .onAppear{
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    if let email = UserDefaults.standard.string(forKey: "email") {
                        if let password = UserDefaults.standard.string(forKey: "pass") {
                            login(email: email, password: password) // auto logs in the caretaker when they open app
                        }
                    }
                }
                .navigationDestination(for: String.self) { route in
                    switch route {
                    case "Senior":
                        SeniorTabView(path: $path)
                            .onAppear{
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                MedicationHomeView().sendMessage2()
                            }
                    case "Caretaker":
                        CaretakerTabView(path: $path)
                            .onAppear {
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.username)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.user)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.pass)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.apns)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.fname)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.lname)
                            }
                    default:
                        SeniorTabView(path: $path)
                            .onAppear{
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                MedicationHomeView().sendMessage2()
                            }
                    }
                    
                }
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button(action: {logout = true
                        }, label: {
                            Label("Logout", systemImage: "person.crop.circle.fill")
                        })
                        .confirmationDialog(
                            "Switch Accounts",
                            isPresented: $logout)
                        {
                            Button("Log into existing account") {
                                loginaccount = true
                            }
                            Button("Create new account") {
                                newaccount = true
                            }
                            
                            Button("Cancel", role: .cancel) {}
                            
                        }
                        .sheet(isPresented: $loginaccount)
                        {
                            SwitchSigninView(path: $path) // sheet for switching accounts via signin
                        }
                        .sheet(isPresented: $newaccount)
                        {
                            SwitchSignupView(path: $path) // sheet for creating a new account inside account then navigating to it
                        }
                    }
                }
            }
            else
            {
                LoadingView()
                    .navigationBarBackButtonHidden()
            }
        }
        
    }
    
    // this method logs a caretaker using their locally stored email and password in UserDefaults.
    // This is good for when the caretaker reopens the app, it just logs them into firebase so they can make changes to the
    // database
    func login(email: String, password: String)
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
        }
    }

}
