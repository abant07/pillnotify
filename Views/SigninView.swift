//
//  SigninView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/26/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth

struct SigninView: View {
    private let database = Database.database().reference()
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var UID = ""
    @State private var firstname = ""
    @State private var lastname = ""
    
    @State private var confirmNameAlert = false
    @State private var invalidCredentialsAlert = false
    
    @State private var roleName = ""

    private var isSignInButtonDisabled: Bool
    {
        [email, password].contains(where:\.isEmpty)
    }
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path)
        {
            if networkMonitor.isConnected
            {
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
                        
                        Button {
                            login()
                        } label: {
                            Text("Login")
                                .bold()
                                .frame(width: 200, height: 40)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                }
                                .foregroundStyle(isSignInButtonDisabled ? .red : .green)
                        }
                        .disabled(isSignInButtonDisabled)
                        .alert(
                            Text("Confirm Your Name"),
                            isPresented: $confirmNameAlert
                        ) {
                            TextField("Firstname", text: $firstname)
                            TextField("Lastname", text: $lastname)
                            
                            Button("Confirm", action: {
                                if roleName == "User" {
                                    sharedDefaults?.set(firstname, forKey: ShareDefaults.Keys.fname)
                                    sharedDefaults?.set(lastname, forKey: ShareDefaults.Keys.lname)
                                    UserDefaults.standard.set(firstname, forKey: "fname")
                                    UserDefaults.standard.set(lastname, forKey: "lname")
                                    path.append("Senior")
                                }
                                else {
                                    UserDefaults.standard.set(firstname, forKey: "fname")
                                    UserDefaults.standard.set(lastname, forKey: "lname")
                                    path.append("Caretaker")
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
                        
                        
                        NavigationLink(destination: {ForgotPasswordView()}, label: {
                            Text("Forgot Password?")
                                .bold()
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 5)
                        })
                        
                        
                        Text("PillNotify is not responsible for any health mishaps. This is solely for the purpose of reminding.")
                            .multilineTextAlignment(.center)
                            .font(.custom("AmericanTypewriter-Bold", size: 10))
                            .foregroundColor(.white)
                        
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
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .ignoresSafeArea()
                    .onAppear
                    {
                        firstname = ""
                        lastname = ""
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
            else {
                LoadingView()
            }
        }
    }
    
    // Logs a user in thorugh firebase so that they can make state changes to the database later on
    func login()
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
                invalidCredentialsAlert = true
                logoutUser()
            }
            else
            {
                getAuthenticatedUserUID()
                authenticate()
            }
        }
    }
    
    // Logs a user out in case they login, but they get invalid credentials,
    // so they get auto logged out
    func logoutUser() {
        do {
            try Auth.auth().signOut()
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
    
    
    // authenticates a user based on if it can retrieve the logged in user's UID
    // via the getAuthenticatedUserUID() method. If successful, it writes the data of the user to
    // the database
    func authenticate()
    {
        invalidCredentialsAlert = false
        let apnsToken = UserDefaults.standard.string(forKey: "apnsToken") ?? "No APNS"

        let usersDatabase = database.child("users").child(UID)
        let caretakerDatabase = database.child("caretaker").child(UID)
        getAuthenticatedUserUID()
        
        usersDatabase.observeSingleEvent(of: .value) { userSnapshot in
            if userSnapshot.exists() {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(UID, forKey: "usernameKey")
                UserDefaults.standard.set(false, forKey: "role")
                UserDefaults.standard.set(password, forKey: "pass")
                UserDefaults.standard.set(email, forKey: "email")
                sharedDefaults?.set(UID, forKey: ShareDefaults.Keys.username)
                sharedDefaults?.set(email, forKey: ShareDefaults.Keys.user)
                sharedDefaults?.set(password, forKey: ShareDefaults.Keys.pass)
                sharedDefaults?.set(apnsToken, forKey: ShareDefaults.Keys.apns)
                roleName = "User"
                confirmNameAlert = true
            } else {
                caretakerDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
                    if caretakerSnapshot.exists() {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(true, forKey: "role")
                        UserDefaults.standard.set(password, forKey: "pass")
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(UID, forKey: "userid") // may need to delete
                        roleName = "Caretaker"
                        confirmNameAlert = true
                    } else {
                        logoutUser()
                    }
                }
            }
        }

    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    SigninView()
}
