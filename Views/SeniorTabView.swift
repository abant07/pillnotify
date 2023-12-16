//
//  SeniorTabView.swift
//  Medimory
//
//  Created by Amogh Bantwal on 12/28/22.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import AWSSES

//This struct shows the initail tab view of the medicine taker when they are either switching between accounts
// or logging in/signing up from home screen
struct SeniorTabView: View {
    private let database = Database.database().reference()
    @State private var caretakerNeededAlert = false
    @State private var newaccount = false
    @State private var logout = false
    @State private var loginaccount = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @Binding var path: NavigationPath
    @State private var tabSelected: SeniorTab = .pill

    var body: some View {
        if networkMonitor.isConnected
        {
            ZStack {
                VStack {
                    TabView(selection: $tabSelected) {
                        ForEach(SeniorTab.allCases, id: \.rawValue) { tab in
                            if (tab.rawValue.capitalized == "Pill") {
                                MedicationHomeView()
                                    .animation(nil, value: tabSelected)
                                    .tag(tab)
                            }
                            else if (tab.rawValue.capitalized == "Waveform") {
                                SiriView()
                                    .animation(nil, value: tabSelected)
                                    .tag(tab)
                            }
                            else if (tab.rawValue.capitalized == "Message") {
                                SeniorMessageView()
                                    .animation(nil, value: tabSelected)
                                    .tag(tab)
                            }
                            else {
                                ProfileView()
                                    .animation(nil, value: tabSelected)
                                    .tag(tab)
                            }
                            
                        }
                    }
                }
                VStack {
                    Spacer()
                    CustomTabView2(selectedTab: $tabSelected)
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear{
                UIApplication.shared.applicationIconBadgeNumber = 0
                if let email = UserDefaults.standard.string(forKey: "email") {
                    if let password = UserDefaults.standard.string(forKey: "pass") {
                        login(email: email, password: password)
                    }
                }
            }
            .alert(isPresented: $caretakerNeededAlert) {
                Alert(
                    title: Text("Caretaker Advised!"),
                    message: Text("Your caretaker hasn't signed up! Siri will be disabled until they sign up, however you will still be able to schedule meds."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: {logout = true
                    }, label: {
                        Label("Logout", systemImage: "person.crop.circle.fill")
                    })
                    .foregroundStyle(.white)
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
                        SwitchSigninView(path: $path) // display singin view as a sheet to login to another account
                    }
                    .sheet(isPresented: $newaccount)
                    {
                        SwitchSignupView(path: $path) // display singin view as a sheet to signup for another account
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
    

    // this method logs a user using their locally stored email and password in UserDefaults.
    // This is good for when the user reopens the app, it just logs them into firebase so they can make changes to the
    // database
    func login(email: String, password: String)
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
            else
            {
                getAPN()
            }
        }
    }
    
    // this method gets the APNS id of the medicine taker, and then gets the apns id of their caretaker
    // it replaces the apns of the caretaker with their own, so that the caretaker can send push notifications to the medicine taker
    func getAPN()
    {
        let apnsId = UserDefaults.standard.string(forKey: "apnsToken") ?? "No APNS"

        let userID = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        let userDatabase = database.child("users").child(userID)
        
        var UID = ""

        userDatabase.observeSingleEvent(of: .value) { userSnapshot in
            if userSnapshot.exists() {
                guard let userData = userSnapshot.value as? [String: Any] else {
                    return
                }
                
                if let caretakerID = userData["accountid"] as? String
                {
                    UID = caretakerID
                    
                    let apnsRef = database.child("caretaker").child(UID).child("apnsid")

                    // Observe the value at the accountid location
                    apnsRef.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            // Retrieve the accountid value
                            if let apnsValue = snapshot.value as? String {
                                if apnsValue != "None"
                                {
                                    let caretakerDatabase = database.child("caretaker").child(UID)
                                    caretakerDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
                                        if caretakerSnapshot.exists() {
                                            let apnsUpdate: [String: Any] = [
                                                "apnsid": apnsId
                                                // Add other fields to be updated
                                            ]
                                            
                                            caretakerDatabase.updateChildValues(apnsUpdate) { error, _ in
                                                if let error = error {
                                                    // Handle the error case
                                                    print("Failed to update caretaker apns: \(error.localizedDescription)")
                                                } else {
                                                    // Caretaker data updated successfully
                                                    print("Caretaker apns updated successfully")
                                                }
                                            }
                                        }
                                        else
                                        {
                                            print("No caretaker exists for this id")
                                            caretakerNeededAlert = true
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            print("No apn exists fro this caretaker")
                            caretakerNeededAlert = true
                        }
                    }
                    
                    
                }
            } else {
                print("No data found in user node")
                caretakerNeededAlert = true
            }
        }

    }

}
