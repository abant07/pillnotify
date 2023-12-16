//
//  ProfileView.swift
//  Medimory
//
//  Created by Amogh Bantwal on 12/28/22.
//

import SwiftUI
import CoreData
import Combine
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AWSSES

//This is the class for the profile of a medicine taker
struct ProfileView: View {
    private let database = Database.database().reference()
    
    @State private var firstname = ""
    @State private var id = ""
    @State private var previd = ""
    @State private var apnid = ""
    @State private var lastname = ""
    @State private var newpassword = ""
    @State private var password = ""
    @State private var email = ""

    @State private var successAlert = false
    @State private var passwordSheet = false
    @State private var errorAlert = false
    @State private var invalidPassword = false
    
    @State private var errorMessage = ""
    @State private var newaccount = false
    @State private var loginaccount = false

    private var isSignInButtonDisabled: Bool
    {
        [firstname, lastname].contains(where:\.isEmpty) //apn
    }
    
    private var newPasswordDisabled: Bool
    {
        [password, newpassword].contains(where:\.isEmpty)
    }
    
    @State private var isCopied = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("Account Settings")
                    .foregroundStyle(.white)
                    .font(.custom("AmericanTypewriter-Bold", size: 40))
                    .shadow(color: .black, radius: 5)
                
                Text("Accout User (Uneditable)")
                    .foregroundStyle(.white)
                    .bold()
                    .shadow(color: .black, radius: 5)
                
                TextField("", text: $email)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading, 20)
                    .placeholder(when: email.isEmpty) {
                        Text("Email")
                            .bold()
                            .padding(.leading, 20)
                            .shadow(color: .black, radius: 5)
                    }
                    .disabled(true)
                    .foregroundStyle(Color.red)
                
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                    .foregroundStyle(.red)
                    .padding(.bottom, 40)
                
                
                
                Text("Copy and Paste this ID to your Caretaker")
                    .foregroundStyle(.white)
                    .bold()
                    .shadow(color: .black, radius: 5)
                
                HStack {
                    TextField("AccountID", text: $id)
                        .disabled(true)
                        .padding(.leading, 20)
                        .foregroundStyle(.white)
                }.overlay(alignment: .trailing){
                    Button(action: {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = id
                        isCopied = true
                        previd = id
                        id = "ID copied"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isCopied = false
                            id = previd
                        }
                    }) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .foregroundStyle(isCopied ? .green : .white)
                            .padding(.trailing, 20)
                        
                    }
                }
                
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                    .foregroundStyle(.white)
                    .padding(.bottom, 20)
                
                
                
                Text("Account Name")
                    .foregroundStyle(.white)
                    .bold()
                    .shadow(color: .black, radius: 5)
                
                
                TextField("", text: $firstname)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading, 20)
                    .placeholder(when: firstname.isEmpty) {
                        Text("Firstname")
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.leading, 20)
                            .shadow(color: .black, radius: 5)
                    }
                
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                    .foregroundStyle(.white)
                
                TextField("", text: $lastname)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.leading, 20)
                    .placeholder(when: lastname.isEmpty) {
                        Text("Lastname")
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
                    Text("Update Name")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                        }
                        .foregroundStyle(isSignInButtonDisabled ? .red : .green)
                })
                .disabled(isSignInButtonDisabled)
                .alert(isPresented: $successAlert) {
                    Alert(
                        title: Text("Success!"),
                        message: Text("Your profile has been updated"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Button(action: {
                    passwordSheet = true
                    password = ""
                    newpassword = ""
                }, label: {
                    Text("Change Password?")
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5)
                })
                .sheet(isPresented: $passwordSheet)
                {
                    NavigationStack
                    {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                Text("Change Password")
                                    .foregroundStyle(.white)
                                    .font(.custom("AmericanTypewriter-Bold", size: 30))
                                    .padding(.top, 20)
                                    .shadow(color: .black, radius: 5)
                                
                                
                                SecureTextField2(text: $password)
                                    .autocorrectionDisabled(true)
                                    .autocapitalization(.none)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .padding(.leading, 20)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Old Password")
                                            .foregroundStyle(.white)
                                            .bold()
                                            .padding(.leading, 20)
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                    .foregroundStyle(.white)
                                
                                SecureTextField3(text: $newpassword)
                                    .autocorrectionDisabled(true)
                                    .autocapitalization(.none)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .padding(.leading, 20)
                                    .placeholder(when: newpassword.isEmpty) {
                                        Text("New Password")
                                            .foregroundStyle(.white)
                                            .bold()
                                            .padding(.leading, 20)
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                    .foregroundStyle(.white)
                                
                                Button(action: {
                                    loginToCheckOldPassword()
                                }, label: {
                                    Text("Change")
                                        .bold()
                                        .frame(width: 200, height: 40)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                        }
                                        .foregroundStyle(newPasswordDisabled ? .red : .green)
                                })
                                .alert(isPresented: $errorAlert) {
                                    if invalidPassword == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text(errorMessage),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else
                                    {
                                        return Alert(
                                            title: Text("Success!"),
                                            message: Text("Your profile has been updated"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                }

                                
                                
                            }
                            .ignoresSafeArea()
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading)
                                {
                                    Button(action: {
                                        passwordSheet = false
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
            }
            .ignoresSafeArea()
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                fillForm()
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
    
    // This method logs a user in with the old password the user enters when changing their password on the Change Password Sheet
    // to see if they have the right password. Errors if not the same password.
    func loginToCheckOldPassword()
    {
        errorAlert = false
        invalidPassword = false
        email = UserDefaults.standard.string(forKey: "email") ?? "No Email"
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
                errorMessage =  "Invalid old password"
                errorAlert = true
                invalidPassword = true
            }
            else
            {
                print("logged in with \(email) \(password)")
                changePassword(newPassword: newpassword)
                
            }
        }
    }
    
    // this method logs a user in if they want to update their name. It just autenticates them so that they
    // are authorized to make changes to Firebase
    func login()
    {
        successAlert = false
        email = UserDefaults.standard.string(forKey: "email") ?? "No Email"
        Auth.auth().signIn(withEmail: email, password: UserDefaults.standard.string(forKey: "pass")!) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
            else
            {
                updateUserData()
                print("logged in with \(email) \(password)")
            }
        }
    }
    
    // this method is used for changing the password in firebase to the password that a user
    // wants to change their password to
    func changePassword(newPassword: String) {
        if let currentUser = Auth.auth().currentUser {
            currentUser.updatePassword(to: newPassword) { error in
                if let error = error {
                    errorMessage =  error.localizedDescription
                    errorAlert = true
                    invalidPassword = true
                } else {
                    print("Password changed successfully")
                    errorAlert = true
                    loginWithNewPassword()
                    
                }
            }
        } else {
            print("No user is currently logged in.")
        }
    }
    
    // This methods a logs a user in with the new password that they have set once they change their password
    func loginWithNewPassword()
    {
        Auth.auth().signIn(withEmail: email, password: newpassword) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
            else
            {
                passwordSheet = false
                UserDefaults.standard.set(newpassword, forKey: "pass")
                sharedDefaults?.set(password, forKey: ShareDefaults.Keys.pass)
                print("logged in with \(email) \(newpassword)")
            }
        }
    }

    // this method is to fill the profile page with information of the medicine taker from the information that they sign up with.
    // It rerieves information from the firebase realtime db to fill the form.
    func fillForm()
    {
        if let user = UserDefaults.standard.object(forKey: "usernameKey") as? String
        {
            id = user
            email = (UserDefaults.standard.object(forKey: "email") as? String)!
            let userDatabase = database.child("users").child(user)
            userDatabase.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    guard let usersData = snapshot.value as? [String: Any] else {
                        return
                    }
                    
                    firstname = UserDefaults.standard.string(forKey: "fname")!
                    lastname = UserDefaults.standard.string(forKey: "lname")!
                    
                    if let ids = usersData["apnsid"] as? String {
                        apnid = ids
                    }
                }
            }
        }
        
    }

    // this method updates the name of the user for the medicine taker
    func updateUserData() {
        successAlert = false
        let userID = UserDefaults.standard.string(forKey: "usernameKey") ?? "No ID"
        let updatedData: [String: Any] = [
            "apnsid" : apnid
        ]
        
        let userDatabase = database.child("users").child(userID)
        userDatabase.updateChildValues(updatedData) { error, _ in
            if let error = error {
                // Handle the error case
                print("Failed to update user data: \(error.localizedDescription)")
            } else {
                // User data updated successfully
                print("User data updated successfully")
                successAlert = true
                UserDefaults.standard.set(firstname, forKey: "fname") // store the new name
                UserDefaults.standard.set(lastname, forKey: "lname")
                sharedDefaults?.set(firstname, forKey: ShareDefaults.Keys.fname)
                sharedDefaults?.set(lastname, forKey: ShareDefaults.Keys.lname)

            }
        }
    }
}
