//
//  swiftsignup.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/26/23.
//

import SwiftUI
import FirebaseDatabase
import Combine
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import AWSSES

let sharedDefaults = UserDefaults(suiteName: ShareDefaults.suitName)

struct swiftsignup: View {
    private let database = Database.database().reference()
    @Environment(\.presentationMode) var presentationMode
    
    private let roles: [String] = ["Medicine Taker", "Caretaker"]
    @State private var role = "Medicine Taker"
    @State private var firstname = ""
    @State private var id = ""
    @State private var fillid = ""
    @State private var UID = ""
    @State private var lastname = ""
    @State private var password = ""
    @State private var email = ""
    @State private var caretakerfirstname = ""
    @State private var caretakerlastname = ""
    @State private var caretakeremail = ""
    @State private var carereceiversemail = ""
    @State private var buttonLabel = "Send Signup Code"
    
    @State private var showAlert = false
    @State private var emailAlert = false
    @State private var caretakerEmailAlert = false
    @State private var invalidEmailAlert = false
    @State private var idTwiceAlert = false
    @State private var idAlert = false
    @State private var determineRole = false
    @State private var showSeniorTab = false
    @State private var invalidCodeAlert = false
    
    @State private var code = ""
    @State private var randomNum = ""
    @State private var emailChange = "-1"
    @State private var errors = ""
    @State private var codeTrue = true
    @State private var showText = true
    private var isSignUpButtonDisabled: Bool
    {
        if role == "Medicine Taker"
        {
            return [firstname, lastname, password, email, caretakerfirstname, caretakerlastname, caretakeremail].contains(where:\.isEmpty)
        }
        else
        {
            return [firstname, lastname, password, email, fillid].contains(where:\.isEmpty)
        }
    }
    private var isSignUpButtonDisabled2: Bool
    {
        if role == "Medicine Taker"
        {
            return [firstname, lastname, password, email, caretakerfirstname, caretakerlastname, caretakeremail, code].contains(where:\.isEmpty)
        }
        else
        {
            return [firstname, lastname, password, email, fillid].contains(where:\.isEmpty)
        }
    }
    @State private var elapsedTime: TimeInterval = 300
    @State private var isRunning = false
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private var formattedElapsedTime: String {
            let minutes = Int(elapsedTime / 60)
            let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
            return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationStack
        {
            ScrollView 
            {
                if networkMonitor.isConnected
                {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color(red: 0/255, green: 47/255, blue: 100/255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .foregroundStyle(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 1000, height: 1000)
                            .rotationEffect(.degrees(135))
                            .offset(y: -750)
                        
                        
                        VStack(spacing: 20) {
                            
                            Text("Create Account")
                                .foregroundStyle(.white)
                                .font(.custom("AmericanTypewriter-Bold", size: 35))
                                .shadow(color: .black, radius: 5)
                            
                            
                            Picker("Role", selection: $role)
                            {
                                ForEach(roles, id:\.self)
                                {
                                    Text("\($0)").tag("\($0)")
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Text("Swipe to Select Your Role")
                                .font(.custom("AmericanTypewriter-Bold", size: 15))
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 5)
                            
                            
                            Rectangle()
                                .frame(width: 350, height: 1)
                                .foregroundStyle(.white)
                            
                            
                            TextField("", text: $email)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .placeholder(when: email.isEmpty) {
                                    Text("Email")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: 350, height: 1)
                                .foregroundStyle(.white)
                            
                            SecureTextField(text: $password)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: 350, height: 1)
                                .foregroundStyle(.white)
                            
                            
                            Text("Enter Your Name")
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 5)
                                .font(.custom("AmericanTypewriter-Bold", size: 15)) // Squiggly font
                            
                            
                            TextField("", text: $firstname)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .placeholder(when: firstname.isEmpty) {
                                    Text("Firstname")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: 350, height: 1)
                                .foregroundStyle(.white)
                            
                            TextField("", text: $lastname)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .placeholder(when: lastname.isEmpty) {
                                    Text("Lastname")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: 350, height: 1)
                                .foregroundStyle(.white)

                            
                            if role == "Medicine Taker"
                            {
                                Text("Enter Your Caretaker's Details")
                                    .foregroundStyle(.white)
                                    .shadow(color: .black, radius: 5)
                                    .font(.custom("AmericanTypewriter-Bold", size: 15)) // Squiggly font
                                
                                TextField("", text: $caretakerfirstname)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                                    .placeholder(when: caretakerfirstname.isEmpty) {
                                        Text("Caretaker Firstname")
                                            .foregroundStyle(.white)
                                            .bold()
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: 350, height: 1)
                                    .foregroundStyle(.white)
                                
                                TextField("", text: $caretakerlastname)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                                    .placeholder(when: caretakerlastname.isEmpty) {
                                        Text("Caretaker Lastname")
                                            .foregroundStyle(.white)
                                            .bold()
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: 350, height: 1)
                                    .foregroundStyle(.white)
                                
                                TextField("", text: $caretakeremail)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                                    .placeholder(when: caretakeremail.isEmpty) {
                                        Text("Caretaker Email")
                                            .foregroundStyle(.white)
                                            .bold()
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: 350, height: 1)
                                    .foregroundStyle(.white)
                                
                                
                                if email != emailChange
                                {
                                    Text("Verify Your Email")
                                        .foregroundStyle(.white)
                                        .font(.custom("AmericanTypewriter-Bold", size: 15)) // Squiggly font
                                        .shadow(color: .black, radius: 5)
                                        .onAppear{
                                            showText = true
                                        }
                                    
                                    TextField("", text: $code)
                                        .foregroundStyle(.white)
                                        .textFieldStyle(.plain)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled(true)
                                        .disabled(codeTrue)
                                        .keyboardType(.numberPad)
                                        .placeholder(when: code.isEmpty) {
                                            Text("Signup Code")
                                                .foregroundStyle(codeTrue ? .red : .white)
                                                .bold()
                                                .shadow(color: .black, radius: 5)
                                        }
                                    
                                    Rectangle()
                                        .frame(width: 350, height: 1)
                                        .foregroundStyle(.white)
                                    
                                    
                                    Button(action: {
                                        if invalidEmail(value: email)
                                        {
                                            codeTrue = false
                                            isRunning = true
                                            showAlert = false
                                            emailAlert = false
                                            elapsedTime = 300
                                            code = ""
                                            buttonLabel = "Resend Signup Code"
                                            randomNum = String(Int.random(in: 100000..<999999))
                                            sendSES(recipients: [email], code: randomNum)
                                        }
                                        else
                                        {
                                            showAlert = true
                                            emailAlert = true
                                            errors = "Invalid email"
                                            isRunning = false
                                            codeTrue = true
                                            buttonLabel = "Send Signup Code"
                                        }
                                        
                                    }, label: {
                                        Text(buttonLabel)
                                            .bold()
                                            .frame(width: 200, height: 40)
                                            .background {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                            }
                                            .foregroundStyle(isSignUpButtonDisabled ? .red : .green)
                                        }
                                    )
                                    .disabled(isSignUpButtonDisabled)
                                    
                                }
                                else
                                {
                                    Text("Code Valid!")
                                }
                                Spacer()
                                
                                Button(action: {
                                    showAlert = false
                                    idAlert = false
                                    idTwiceAlert = false
                                    invalidEmailAlert = false
                                    invalidCodeAlert = false

                                    if email == emailChange
                                    {
                                        codeTrue = true
                                        register()
                                        isRunning = false
                                    }
                                    else
                                    {
                                        if code == randomNum
                                        {
                                            codeTrue = true
                                            register()
                                            isRunning = false
                                            emailChange = email
                                        }
                                        else
                                        {
                                            showAlert = true
                                            invalidCodeAlert = true
                                            code = ""
                                            isRunning = false
                                        }
                                    }
                                    
                                }, label: {
                                    Text("Create Account")
                                        .bold()
                                        .frame(width: UIScreen.main.bounds.width, height: 90)
                                        .background {
                                            RoundedRectangle(cornerRadius: 0, style: .continuous)
                                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                        }
                                        .foregroundStyle(isSignUpButtonDisabled2 ? .red : .green)
                                })
                                .disabled(isSignUpButtonDisabled2)
                                .alert(isPresented: $showAlert) {
                                    if idAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Invalid ID"),
                                            dismissButton: .default(Text("OK")
                                                                   )
                                        )
                                    }
                                    else if idTwiceAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Id in use"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else if invalidEmailAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Invalid caretaker email address format"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else if invalidCodeAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Invalid signup code"),
                                            dismissButton: .default(Text("OK"),
                                                                    action:{
                                                                        isRunning = true
                                                                    })
                                        )
                                    }
                                    else if emailAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text(errors),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Cannot use same email"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                }
                            }
                            else
                            {
                                Text("Paste Care Receiver's ID From Email")
                                    .foregroundStyle(.white)
                                    .font(.custom("AmericanTypewriter-Bold", size: 15)) // Squiggly font
                                    .shadow(color: .black, radius: 5)
                                    .onAppear{
                                        showText = false
                                    }
                                
                                TextField("", text: $fillid)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                                    .placeholder(when: fillid.isEmpty) {
                                        Text("Care Receiver's ID")
                                            .foregroundStyle(.white)
                                            .bold()
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: 350, height: 1)
                                    .foregroundStyle(.white)
                                
                                
                                Button(action: {
                                    showAlert = false
                                    idAlert = false
                                    idTwiceAlert = false
                                    invalidEmailAlert = false
                                    register()
                                }, label: {
                                    Text("Create Account")
                                        .bold()
                                        .frame(width: 200, height: 40)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                        }
                                        .foregroundStyle(isSignUpButtonDisabled ? .red : .green)
                                }).disabled(isSignUpButtonDisabled2)
                                .alert(isPresented: $showAlert) {
                                    if idAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Invalid ID"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else if idTwiceAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Id in use"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else if invalidEmailAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Invalid email address"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else if invalidCodeAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Invalid signup code"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else if emailAlert == true
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text(errors),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    else
                                    {
                                        return Alert(
                                            title: Text("Error!"),
                                            message: Text("Cannot use same email"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                }
                                Spacer()
                            }
                            
                            
                        }
                        .frame(width: 350)
                    }
                    .toolbarBackground(Color.pink, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing)
                        {
                            Text("Signup Code Timer: " + formattedElapsedTime)
                                .bold()
                                .foregroundStyle(.black)
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .opacity(showText ? 1.0 : 0.0)
                        }
                        
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .onReceive(timer) { _ in
                        guard isRunning else { return }
                        if Int(elapsedTime) == 0
                        {
                            code = ""
                            isRunning = false
                            codeTrue = true
                        }
                        else
                        {
                            elapsedTime -= 0.1
                        }
                    }
                    .navigationDestination(isPresented: $showSeniorTab)
                    {
                        SeniorTabView()
                    }
                    .navigationDestination(isPresented: $determineRole)
                    {
                        CaretakerTabView()
                            .onAppear
                            {
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.username)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.user)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.pass)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.apns)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.fname)
                                sharedDefaults?.removeObject(forKey: ShareDefaults.Keys.lname)
                            }
                    }
                }
                else {
                    LoadingView()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        
    }
    
    func login()
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
                isRunning = false
            }
            else
            {
                print("logged in with \(email) \(password)")
            }
        }
    }
    
    func getAuthenticatedUserUID() {
        if let currentUser = Auth.auth().currentUser {
            UID = currentUser.uid
            print("Authenticated user UID: \(UID)")
        } else {
            print("No user is currently logged in.")
        }
    }
    
    func register()
    {
        showAlert = false
        emailAlert = false
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                errors = error!.localizedDescription
                showAlert = true
                emailAlert = true
                codeTrue = true
                print (error!.localizedDescription)
                isRunning = false
            }
            else
            {
                login()
                addUser()
            }
        }
    }
    
    func deleteUserAccount() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("Error deleting user: \(error.localizedDescription)")
                } else {
                    // User account deleted successfully
                    print("User account deleted")
                }
            }
        } else {
            // No user is currently logged in
            print("No user is currently logged in.")
        }
    }

    
    func invalidEmail(value: String) -> Bool
    {
        let regEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", regEx)
        if emailTest.evaluate(with: value)
        {
            return true
        }
        else
        {
            return false
        }

    }


    func sendSES(recipients: [String], fname: String, lname: String, id: String)
    {
        let formattedMessage = AWSSESMessage()
        let messageBody = AWSSESContent()
        messageBody?.data = "\(fname) \(lname) wants to invite you to be their caretaker for PillNotify!\n\nPaste this id in the textbox that says 'Care Receivers's Id': \(id)\n\nDownload PillNotify: https://testflight.apple.com/join/yWP1M8WU"

        let subjectContent = AWSSESContent()
        subjectContent?.data = "Download PillNotify"

        let body = AWSSESBody()
        body?.text = messageBody

        formattedMessage?.subject = subjectContent
        formattedMessage?.body = body
        
        let destination = AWSSESDestination()
        destination?.toAddresses = recipients

        let request = AWSSESSendEmailRequest()
        request?.source = "pillnotify2023@gmail.com"
        request?.destination = destination
        request?.message = formattedMessage

        AWSSES.default().sendEmail(request!) { (response, error) in
            if let response = response {
                print(response)
                let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(UID, forKey: "usernameKey")
                UserDefaults.standard.set(UID, forKey: "id")
                UserDefaults.standard.set(password, forKey: "pass")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(false, forKey: "role")
                UserDefaults.standard.set(firstname, forKey: "fname")
                UserDefaults.standard.set(lastname, forKey: "lname")
                sharedDefaults?.set(UID, forKey: ShareDefaults.Keys.username)
                sharedDefaults?.set(email, forKey: ShareDefaults.Keys.user)
                sharedDefaults?.set(password, forKey: ShareDefaults.Keys.pass)
                sharedDefaults?.set(ap, forKey: ShareDefaults.Keys.apns)
                sharedDefaults?.set(firstname, forKey: ShareDefaults.Keys.fname)
                sharedDefaults?.set(lastname, forKey: ShareDefaults.Keys.lname)
                showSeniorTab = true
            }
            if let _ = error {
                showAlert = true
                emailAlert = true
                errors = "Invalid caretaker email"
                let childReference = database.child("users").child(UID)
                
                childReference.removeValue { error, _ in
                    if let error = error {
                        print("Failed to delete child node: \(error.localizedDescription)")
                    } else {
                        print("Child node deleted successfully")
                        deleteUserAccount()
                    }
                }
            }
        }
    }
    
    func sendSES(recipients: [String], code: String)
    {
        let formattedMessage = AWSSESMessage()
        let messageBody = AWSSESContent()
        messageBody?.data = "Your signup code is \(code)"

        let subjectContent = AWSSESContent()
        subjectContent?.data = "Create Your PillNotify Account"

        let body = AWSSESBody()
        body?.text = messageBody

        formattedMessage?.subject = subjectContent
        formattedMessage?.body = body
        
        let destination = AWSSESDestination()
        destination?.toAddresses = recipients

        let request = AWSSESSendEmailRequest()
        request?.source = "pillnotify2023@gmail.com"
        request?.destination = destination
        request?.message = formattedMessage

        AWSSES.default().sendEmail(request!) { (response, error) in
            if let response = response {
                print(response)
            }
            if let _ = error {
                showAlert = true
                emailAlert = true
                errors = "Invalid email"
                isRunning = false
                codeTrue = true
                buttonLabel = "Send Signup Code"
            }
        }
    }
    
    func sendPushNotification(body: String, subtitle: String, phoneId: String) {
        var service = ""
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let configData = FileManager.default.contents(atPath: configPath),
            let config = try? PropertyListSerialization.propertyList(from: configData, options: [], format: nil) as? [String: Any] {
            if let serviceToken = config["ServiceToken"] as? String {
                service = serviceToken
            }
        }
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(service)", forHTTPHeaderField: "Authorization") // Replace YOUR_SERVER_KEY with your Firebase Server Key
        
        let body: [String: Any] = [
            "to": phoneId, // Replace DEVICE_TOKEN with the device token of the target device(s)
            "notification": [
                "title": "PillNotify",
                "subtitle": subtitle,
                "body": body
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error sending push notification: \(error.localizedDescription)")
                } else {
                    print("Push notification sent successfully")
                }
            }
            task.resume()
        } catch {
            print("Error creating push notification request: \(error.localizedDescription)")
        }
    }
    
    func addUser()
    {
        showAlert = false
        idAlert = false
        idTwiceAlert = false
        invalidEmailAlert = false
        getAuthenticatedUserUID()
        if role == "Medicine Taker"
        {
            if invalidEmail(value: caretakeremail)
            {
                if email == caretakeremail
                {
                    showAlert = true
                    isRunning = false
                    codeTrue = true
                    deleteUserAccount()
                }
                else
                {
                    let userData: [String: Any] = [
                        "apnsid" : UserDefaults.standard.string(forKey: "apnsToken") ?? "None",
                        "username": UID,
                        "accountid": UID
                    ]
                    let usersReference = database.child("users").child(UID)
                    usersReference.setValue(userData) { error, _ in
                        if let error = error {
                            // Handle the error case
                            print("Failed to create object: \(error.localizedDescription)")
                        } else {
                            // Object created successfully
                            sendSES(recipients: [caretakeremail], fname: firstname, lname: lastname, id: UID)
                            
                            print("Object created successfully")
                        }
                    }
                }
            }
            else
            {
                showAlert = true
                invalidEmailAlert = true
                codeTrue = true
                deleteUserAccount()
                isRunning = false
            }
        }
        else
        {
            caretakeremail = ""
            caretakerlastname = ""
            caretakerfirstname = ""

            // Get a reference to the user's path in the database
            let userData: [String: Any] = [
                "apnsid" : "None",
                "username": UID,
                "caretakeeID": fillid,
                fillid: true,
                "paid": false
            ]
            
            let caretakerReference = database.child("caretaker").child(UID)
            caretakerReference.setValue(userData) { error, _ in
                if let error = error {
                    // Handle the error case
                    print("Failed to create object: \(error.localizedDescription)")
                    showAlert = true
                    isRunning = false
                    // Handle the error and show appropriate alert
                } else {
                    // Object created successfully

                    print("Object created successfully")
                    
                    let userReference = database.child("users").child(fillid)

                    // Check if the user data exists
                    userReference.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            let accountIDReference = database.child("users").child(fillid).child("accountid")
                            
                            let emailRef = database.child("users").child(fillid).child("apnsid")

                            // Observe the value at the accountid location
                            accountIDReference.observeSingleEvent(of: .value) { snapshot in
                                if snapshot.exists() {
                                    // Retrieve the accountid value
                                    if let accountIDValue = snapshot.value as? String {
                                        if accountIDValue == fillid
                                        {
                                            let updateData = ["accountid": UID,
                                                              UID: true] as [String : Any]

                                            // Update the firstname in the database
                                            userReference.updateChildValues(updateData) { error, _ in
                                                if let error = error {
                                                    print("Error updating UID: \(error.localizedDescription)")
                                                } else {
                                                    print("UID updated successfully.")
                                                    emailRef.observeSingleEvent(of: .value) { snapshot in
                                                        if snapshot.exists() {
                                                            // Retrieve the accountid value
                                                            if let emailVal = snapshot.value as? String {
                                                                sendPushNotification(body: "\(firstname) \(lastname) has signed up to be your caretaker!", subtitle: "Caretaker Signup", phoneId: emailVal)
                                                            }
                                                        }
                                                    }
                                                    
                                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                                    UserDefaults.standard.set(UID, forKey: "usernameKey")
                                                    UserDefaults.standard.set(true, forKey: "role")
                                                    UserDefaults.standard.set(email, forKey: "email")
                                                    UserDefaults.standard.set(password, forKey: "pass")
                                                    UserDefaults.standard.set(firstname, forKey: "fname")
                                                    UserDefaults.standard.set(lastname, forKey: "lname")
                                                    UserDefaults.standard.set(UID, forKey: "userid")
                                                    determineRole = true
                                                }
                                            }
                                        }
                                        else
                                        {
                                            showAlert = true
                                            idTwiceAlert = true
                                            codeTrue = true
                                            isRunning = false
                                            let childReference = database.child("caretaker").child(UID)
                                            
                                            childReference.removeValue { error, _ in
                                                if let error = error {
                                                    print("Failed to delete child node: \(error.localizedDescription)")
                                                } else {
                                                    print("Child node deleted successfully")
                                                    deleteUserAccount()
                                                }
                                            }
                                        }

                                        // You can perform further actions based on the accountid value here
                                    } else {
                                        print("accountid does not exist or is not a string value.")
                                    }
                                } else {
                                    print("accountid does not exist.")
                                }
                            }

                            
                        } else {
                            showAlert = true
                            idAlert = true
                            codeTrue = true
                            isRunning = false
                            let childReference = database.child("caretaker").child(UID)
                            
                            childReference.removeValue { error, _ in
                                if let error = error {
                                    print("Failed to delete child node: \(error.localizedDescription)")
                                } else {
                                    print("Child node deleted successfully")
                                    deleteUserAccount()
                                }
                            }
                            
                        }
                    }
                    
                    
                    
                }
            }

        }
    }
}

struct SecureTextField: View {
    @State private var isSecureField: Bool = true
    
    @Binding var text: String
    
    var body: some View
    {
        HStack {
            if isSecureField
            {
                SecureField("", text: $text)
            }
            else
            {
                TextField(text, text: $text)
            }
        }.overlay(alignment: .trailing){
            Image(systemName: isSecureField ? "eye.slash":"eye")
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}

struct SecureTextField2: View{
    @State private var isSecureField: Bool = true
    
    @Binding var text: String
    
    var body: some View
    {
        HStack {
            if isSecureField
            {
                SecureField("Old Password", text: $text)
            }
            else
            {
                TextField(text, text: $text)
            }
        }.overlay(alignment: .trailing){
            Image(systemName: isSecureField ? "eye.slash":"eye")
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}

struct SecureTextField3: View{
    @State private var isSecureField: Bool = true
    
    @Binding var text: String
    
    var body: some View
    {
        HStack {
            if isSecureField
            {
                SecureField("New Password", text: $text)
            }
            else
            {
                TextField(text, text: $text)
            }
        }.overlay(alignment: .trailing){
            Image(systemName: isSecureField ? "eye.slash":"eye")
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}

#Preview {
    swiftsignup()
}
