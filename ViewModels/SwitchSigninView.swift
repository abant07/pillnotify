//
//  SwitchSigninView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 9/11/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth

// A sheet that allows a user to navigate to new account
struct SwitchSigninView: View {
    
    @Environment(\.presentationMode) var presentationMode
    private let database = Database.database().reference()
    
    @State var email = ""
    @State var password = ""
    @State var UID = ""
    @State var roleName = ""
    @State var firstname = ""
    @State var lastname = ""
    
    @State var confirmNameAlert = false
    @State var invalidCredentialsAlert = false
    
    @Binding var path: NavigationPath
    
    var isSignInButtonDisabled: Bool
    {
        [email, password].contains(where:\.isEmpty)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    Text("Sign in")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 40))
                        .shadow(color: .black, radius: 5)
                    
                    TextField("", text: $email)
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .padding(.leading, 20)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.leading, 20)
                                .shadow(color: .black, radius: 5)
                        }
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                        .foregroundStyle(.white)
                    
                    SecureTextField(text: $password)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .padding(.leading, 20)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.leading, 20)
                                .shadow(color: .black, radius: 5)
                        }
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                        .foregroundStyle(.white)
                    
                    Button(action: {
                        login()
                    }, label: {
                        Text("Login")
                            .bold()
                            .frame(width: 200, height: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                            }
                            .foregroundStyle(isSignInButtonDisabled ? .red : .green)
                    })
                    .disabled(isSignInButtonDisabled)
                    .alert(
                        Text("Confirm Your Name"),
                        isPresented: $confirmNameAlert
                    ) {
                        TextField("Firstname", text: $firstname)
                        TextField("Lastname", text: $lastname)
                        
                        Button("Confirm", action: {
                            if roleName == "User" {
                                UserDefaults.standard.set(firstname, forKey: "fname")
                                UserDefaults.standard.set(lastname, forKey: "lname")
                                sharedDefaults?.set(firstname, forKey: ShareDefaults.Keys.fname)
                                sharedDefaults?.set(lastname, forKey: ShareDefaults.Keys.lname)
                                path.append("Senior")
                                presentationMode.wrappedValue.dismiss()
                                
                            }
                            else {
                                UserDefaults.standard.set(firstname, forKey: "fname")
                                UserDefaults.standard.set(lastname, forKey: "lname")
                                path.append("Caretaker")
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                        
                        Button("Cancel", role: .cancel) {}
                        .foregroundColor(Color.red)
                    } message: {
                        Text("Please confirm your fullname for this account.")
                    }
                    .alert(isPresented: $invalidCredentialsAlert) {
                        Alert(
                            title: Text("Invalid Credentials"),
                            message: Text("Email or password is incorrect"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    NavigationLink(value: "String") {
                        Text("Forgot Password?")
                            .bold()
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                    }
                    .padding(.top)
                    
                }
                .navigationDestination(for: String.self) { _ in
                    SwitchForgotPassword()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing)
                            {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack(spacing: 3) {
                                        Text("Cancel")
                                            .bold()
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            
                        }
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onAppear
                {
                    firstname = ""
                    lastname = ""
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading)
                    {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 3) {
                                Text("Cancel")
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0/255, green: 47/255, blue: 100/255),
                        Color.white,
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
        }
    }
    
    // Logs a user in thorugh firebase so that they can make state changes to the database later on
    // if fails, relogin to current account, otherwise authenticates them and navigates to new account
    func login()
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
                invalidCredentialsAlert = true
                logoutUser()
                if let email = UserDefaults.standard.string(forKey: "email") {
                    if let password = UserDefaults.standard.string(forKey: "pass") {
                        relogin(email: email, password: password)
                    }
                }
            }
            else
            {
                getAuthenticatedUserUID()
                authenticate()
            }
        }
    }
    
    // Logs a user in thorugh firebase so that they can make state changes to the database later on.
    // Occurs when a user is trying to log into another account, but fails, so then it relogs them into their current account.
    func relogin(email: String, password: String)
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
        }
    }
    
    // Logs a user out in case they login, but they get invalid credentials,
    // so they get auto logged out
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            // The user is now logged out
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    // Retrieves the UserID (UID) of a user once they log in. This will help keep track of their data
    func getAuthenticatedUserUID() {
        if let currentUser = Auth.auth().currentUser {
            UID = currentUser.uid
            print("Authenticated user UID: \(UID)")
        } else {
            print("No user is currently logged in.")
        }
    }
    
    // authenticates a user to navigate to their new account once it retrives the UID
    // via the getAuthenticatedUserUID() method. If successful, it writes the data of the user to
    // the database
    func authenticate()
    {
        invalidCredentialsAlert = false
        let ap = UserDefaults.standard.string(forKey: "apnsToken")!
        let usersReference = database.child("users").child(UID)
        let caretakerReference = database.child("caretaker").child(UID)
        getAuthenticatedUserUID()
        
        usersReference.observeSingleEvent(of: .value) { userSnapshot in
            if userSnapshot.exists() {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(UID, forKey: "usernameKey")
                UserDefaults.standard.set(false, forKey: "role")
                UserDefaults.standard.set(password, forKey: "pass")
                UserDefaults.standard.set(email, forKey: "email")
                sharedDefaults?.set(UID, forKey: ShareDefaults.Keys.username)
                sharedDefaults?.set(email, forKey: ShareDefaults.Keys.user)
                sharedDefaults?.set(password, forKey: ShareDefaults.Keys.pass)
                sharedDefaults?.set(ap, forKey: ShareDefaults.Keys.apns)
                confirmNameAlert = true
                roleName = "User"
            } else {
                caretakerReference.observeSingleEvent(of: .value) { caretakerSnapshot in
                    if caretakerSnapshot.exists() {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(true, forKey: "role")
                        UserDefaults.standard.set(password, forKey: "pass")
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(UID, forKey: "userid")
                        confirmNameAlert = true
                        roleName = "Caretaker"
                    } else {
                        logoutUser()
                        if let email = UserDefaults.standard.string(forKey: "email") {
                            if let password = UserDefaults.standard.string(forKey: "pass") {
                                relogin(email: email, password: password)
                            }
                        }
                    }
                }
            }
        }

    }
}

