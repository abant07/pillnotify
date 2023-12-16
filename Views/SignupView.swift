//
//  SignupView.swift
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

struct SignupView: View {
    private let database = Database.database().reference()
    @Environment(\.presentationMode) var presentationMode
    
    private let roles: [String] = ["Medicine Taker", "Caretaker"]
    @State private var role = "Medicine Taker"
    @State private var firstname = ""
    @State private var fillid = ""
    @State private var UID = ""
    @State private var lastname = ""
    @State private var password = ""
    @State private var email = ""
    @State private var caretakerfirstname = ""
    @State private var caretakerlastname = ""
    @State private var caretakeremail = ""
    @State private var buttonLabel = "Send Signup Code"
    
    @State private var errorsAlert = false
    @State private var signupAlert = false
    @State private var invalidEmailFormatAlert = false
    @State private var idInUseAlert = false
    @State private var invalidIdAlert = false
    @State private var invalidCodeAlert = false
    
    @State private var code = ""
    @State private var randomNum = ""
    @State private var emailChange = "-1"
    @State private var errors = ""
    @State private var codeTrue = true
    @State private var showTimer = true
    
    private var isCodeButtonDisabled: Bool
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
    private var isSignupButtonDisabled: Bool
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
    @State private var isTimerRunning = false
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path)
        {
            if networkMonitor.isConnected
            {
                ScrollView
                {
                    LazyVStack(spacing: 20) {
                        
                        Text("Create Account")
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 35))
                            .shadow(color: .black, radius: 5)
                        
                        Text("Select Your Role")
                            .font(.custom("AmericanTypewriter-Bold", size: 15))
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                        
                        Picker("Role", selection: $role)
                        {
                            ForEach(roles, id:\.self)
                            {
                                Text("\($0)").tag("\($0)")
                            }
                        }
                        .padding()
                        .pickerStyle(SegmentedPickerStyle())
                        .colorMultiply(.blue)
                        
                        
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
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
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
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
                        
                        
                        Text("Enter Your Name")
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                            .font(.custom("AmericanTypewriter-Bold", size: 15)) // Squiggly font
                        
                        
                        TextField("", text: $firstname)
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
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

                        
                        if role == "Medicine Taker"
                        {
                            Text("Enter Your Caretaker's Details")
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 5)
                                .font(.custom("AmericanTypewriter-Bold", size: 15))
                            
                            TextField("", text: $caretakerfirstname)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled(true)
                                .padding(.leading, 20)
                                .placeholder(when: caretakerfirstname.isEmpty) {
                                    Text("Caretaker Firstname")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(.leading, 20)
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                .foregroundStyle(.white)
                            
                            TextField("", text: $caretakerlastname)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled(true)
                                .padding(.leading, 20)
                                .placeholder(when: caretakerlastname.isEmpty) {
                                    Text("Caretaker Lastname")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(.leading, 20)
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                .foregroundStyle(.white)
                            
                            TextField("", text: $caretakeremail)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
                                .padding(.leading, 20)
                                .placeholder(when: caretakeremail.isEmpty) {
                                    Text("Caretaker Email")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(.leading, 20)
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                .foregroundStyle(.white)
                            
                            
                            if email != emailChange
                            {
                                Text("Verify Your Email")
                                    .foregroundStyle(.white)
                                    .font(.custom("AmericanTypewriter-Bold", size: 15))
                                    .shadow(color: .black, radius: 5)
                                    .onAppear{
                                        code = ""
                                        codeTrue = true
                                        showTimer = true
                                    }
                                
                                TextField("", text: $code)
                                    .foregroundStyle(.white)
                                    .textFieldStyle(.plain)
                                    .autocorrectionDisabled(true)
                                    .disabled(codeTrue)
                                    .keyboardType(.numberPad)
                                    .padding(.leading, 20)
                                    .placeholder(when: code.isEmpty) {
                                        Text("Signup Code")
                                            .foregroundStyle(codeTrue ? .red : .white)
                                            .bold()
                                            .padding(.leading, 20)
                                            .shadow(color: .black, radius: 5)
                                    }
                                
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                    .foregroundStyle(.white)
                                
                                
                                Button(action: {
                                    if invalidEmail(value: email)
                                    {
                                        codeTrue = false
                                        isTimerRunning = true
                                        errorsAlert = false
                                        signupAlert = false
                                        elapsedTime = 300
                                        code = ""
                                        buttonLabel = "Resend Signup Code"
                                        randomNum = String(Int.random(in: 100000..<999999))
                                        sendSES(recipients: [email], code: randomNum)
                                    }
                                    else
                                    {
                                        errorsAlert = true
                                        signupAlert = true
                                        errors = "Invalid email"
                                        isTimerRunning = false
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
                                        .foregroundStyle(isCodeButtonDisabled ? .red : .green)
                                    }
                                )
                                .disabled(isCodeButtonDisabled)
                                
                            }
                            else
                            {
                                Text("Code Valid!")
                                    .font(.custom("AmericanTypewriter-Bold", size: 15))
                                    .foregroundStyle(.white)
                                    .onAppear {
                                        code = randomNum
                                        codeTrue = false
                                    }
                            }
                            Spacer()
                            
                            Button(action: {
                                errorsAlert = false
                                invalidIdAlert = false
                                idInUseAlert = false
                                invalidEmailFormatAlert = false
                                invalidCodeAlert = false

                                if email == emailChange
                                {
                                    codeTrue = true
                                    register()
                                    isTimerRunning = false
                                }
                                else
                                {
                                    if code == randomNum
                                    {
                                        codeTrue = true
                                        register()
                                        isTimerRunning = false
                                        emailChange = email
                                    }
                                    else
                                    {
                                        errorsAlert = true
                                        invalidCodeAlert = true
                                        isTimerRunning = false
                                    }
                                }
                                
                            }, label: {
                                Text("Create Account")
                                    .bold()
                                    .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                    }
                                    .foregroundStyle(isSignupButtonDisabled ? .red : .green)
                            })
                            .disabled(isSignupButtonDisabled)
                            .alert(isPresented: $errorsAlert) {
                                if invalidIdAlert == true
                                {
                                    return Alert(
                                        title: Text("Error!"),
                                        message: Text("Invalid ID"),
                                        dismissButton: .default(Text("OK")
                                                               )
                                    )
                                }
                                else if idInUseAlert == true
                                {
                                    return Alert(
                                        title: Text("Error!"),
                                        message: Text("Id in use"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                                else if invalidEmailFormatAlert == true
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
                                        action: {
                                            isTimerRunning = true
                                        })
                                    )
                                }
                                else if signupAlert == true
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
                            Spacer()
                            Text("Paste Medicine Taker's ID From Email")
                                .foregroundStyle(.white)
                                .font(.custom("AmericanTypewriter-Bold", size: 15))
                                .shadow(color: .black, radius: 5)
                                .onAppear{
                                    showTimer = false
                                }
                            
                            TextField("", text: $fillid)
                                .foregroundStyle(.white)
                                .textFieldStyle(.plain)
                                .autocorrectionDisabled(true)
                                .padding(.leading, 20)
                                .placeholder(when: fillid.isEmpty) {
                                    Text("Medicine Taker's ID")
                                        .foregroundStyle(.white)
                                        .bold()
                                        .padding(.leading, 20)
                                        .shadow(color: .black, radius: 5)
                                }
                            
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                                .foregroundStyle(.white)
                            
                            
                            Button(action: {
                                errorsAlert = false
                                invalidIdAlert = false
                                idInUseAlert = false
                                invalidEmailFormatAlert = false
                                register()
                            }, label: {
                                Text("Create Account")
                                    .bold()
                                    .frame(width: UIScreen.main.bounds.width - 50, height: 60)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                    }
                                    .foregroundStyle(isSignupButtonDisabled ? .red : .green)
                            })
                            .disabled(isSignupButtonDisabled)
                            .alert(isPresented: $errorsAlert) {
                                if invalidIdAlert == true
                                {
                                    return Alert(
                                        title: Text("Error!"),
                                        message: Text("Invalid ID"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                                else if idInUseAlert == true
                                {
                                    return Alert(
                                        title: Text("Error!"),
                                        message: Text("ID in use"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                                else if invalidEmailFormatAlert == true
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
                                else if signupAlert == true
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
                        Spacer()
                        
                        Text("PillNotify is not responsible for any health mishaps. This is solely for the purpose of reminding.")
                            .multilineTextAlignment(.center)
                            .font(.custom("AmericanTypewriter-Bold", size: 10))
                            .foregroundColor(.red)
                        
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing)
                        {
                            Text("Signup Code Timer: " + formattedElapsedTime)
                                .bold()
                                .foregroundStyle(.white)
                                .padding(.leading, 20)
                                .font(.system(size: 17, weight: .bold, design: .default))
                                .opacity(showTimer ? 1.0 : 0.0)
                        }
                        
                    }
                    .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .ignoresSafeArea()
                    .onReceive(timer) { _ in
                        guard isTimerRunning else { return }
                        if Int(elapsedTime) == 0
                        {
                            code = ""
                            isTimerRunning = false
                            codeTrue = true
                        }
                        else
                        {
                            elapsedTime -= 0.1
                        }
                    }
                    .navigationDestination(for: String.self) { route in
                        switch route {
                            case "Senior":
                                SeniorTabView(path: $path)
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
            else
            {
                LoadingView()
            }
        }
        
    }
    
    // log the user in when they sign up, which stops the timer for the signup code
    func login()
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
                isTimerRunning = false
            }
            else
            {
                print("logged in with \(email) \(password)")
            }
        }
    }
    
    //gets the UserID of the user who has signed up
    func getAuthenticatedUserUID() {
        if let currentUser = Auth.auth().currentUser {
            UID = currentUser.uid
            print("Authenticated user UID: \(UID)")
        } else {
            print("No user is currently logged in.")
        }
    }
    
    // when a user signs up, the will use their email and password to register them under a account in
    // firebase. This will allow them in the future to make changes to the database while being authenticated.
    // If the user successfully registers, it will log them in as a user, and will add their name to the database.
    // If there is an error, like an email already exists, a error is thrown.
    func register()
    {
        errorsAlert = false
        signupAlert = false
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                errors = error!.localizedDescription
                errorsAlert = true
                signupAlert = true
                codeTrue = true
                print (error!.localizedDescription)
                isTimerRunning = false
            }
            else
            {
                login()
                addUser()
            }
        }
    }
    
    // this deletes a person's account immediently if its found that after signing up
    // The reason this is a seperate function, because as part of my code I am chacking validity
    // of ID's for the caretaker, so if that is invalid, it deletes the account that was registered immediently.
    // User must be logged in to delete
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

    // Checks the validity of a email by its format xxxxx@domain.com
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

    
    // This method is pass a list of emails, a name of the person sigingup, and the User ID
    // that a medicine taker wants to share with a caretaker. Sends a email via AWS SES service. And also navigates to
    // new page if a medicine taker. 
    func sendSES(recipients: [String], fname: String, lname: String, id: String)
    {
        let formattedMessage = AWSSESMessage()
        let messageBody = AWSSESContent()
        messageBody?.data = "\(fname) \(lname) wants to invite you to be their caretaker for PillNotify!\n\nPaste this ID in the textbox that says 'Medicine Taker ID': \(id) when signing up\n\nYou can download PillNotify from App Store now!"

        let subjectContent = AWSSESContent()
        subjectContent?.data = "\(fname) \(lname) invited you!"

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
                let apnsToken = UserDefaults.standard.string(forKey: "apnsToken") ?? "No APNS"
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(UID, forKey: "usernameKey")
                UserDefaults.standard.set(password, forKey: "pass")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(false, forKey: "role")
                UserDefaults.standard.set(firstname, forKey: "fname")
                UserDefaults.standard.set(lastname, forKey: "lname")
                sharedDefaults?.set(UID, forKey: ShareDefaults.Keys.username)
                sharedDefaults?.set(email, forKey: ShareDefaults.Keys.user)
                sharedDefaults?.set(password, forKey: ShareDefaults.Keys.pass)
                sharedDefaults?.set(apnsToken, forKey: ShareDefaults.Keys.apns)
                sharedDefaults?.set(firstname, forKey: ShareDefaults.Keys.fname)
                sharedDefaults?.set(lastname, forKey: ShareDefaults.Keys.lname)
                path.append("Senior")
            }
            if let _ = error {
                errorsAlert = true
                signupAlert = true
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
    
    // send a AWS SES email to the person who is signing up as a medicine taker to see if their
    // email is a valid email. This is to prevent people from creating a mass amounts of accounts
    // overflooding the database
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
                errorsAlert = true
                signupAlert = true
                errors = "Invalid email"
                isTimerRunning = false
                codeTrue = true
                buttonLabel = "Send Signup Code"
            }
        }
    }
    
    // This sends a push notification to anyone's device as part of the app with a customizable message
    // Using a firebase service of FCM
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
    
    // This method add a user to the firebase database based on if they are a caretaker or medicine taker
    // It first checks if the user is logged in and authenticated to write into the database. If not, it deletes their account
    // If successful, it send a email to caretaker (if role is medicine taker) to signup with PillNotify.
    // Does checks for correct id, if id is already taken, if email is valid, signup code is valid, if time ran out
    // Else, the database is written to and UserDeafults contain come temporary data that will be helpful later.
    func addUser()
    {
        errorsAlert = false
        invalidIdAlert = false
        idInUseAlert = false
        invalidEmailFormatAlert = false
        getAuthenticatedUserUID()
        if role == "Medicine Taker"
        {
            if invalidEmail(value: caretakeremail)
            {
                if email == caretakeremail
                {
                    errorsAlert = true
                    isTimerRunning = false
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
                    let usersDatabase = database.child("users").child(UID)
                    usersDatabase.setValue(userData) { error, _ in
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
                errorsAlert = true
                invalidEmailFormatAlert = true
                codeTrue = true
                deleteUserAccount()
                isTimerRunning = false
            }
        }
        else
        {
            caretakeremail = ""
            caretakerlastname = ""
            caretakerfirstname = ""

            // Get a reference to the user's path in the database
            let caretakerData: [String: Any] = [
                "apnsid" : "None",
                "username": UID,
                "caretakeeID": fillid,
                fillid: true,
                "paid": false
            ]
            
            let caretakerDatabase = database.child("caretaker").child(UID)
            caretakerDatabase.setValue(caretakerData) { error, _ in
                if let error = error {
                    // Handle the error case
                    print("Failed to create object: \(error.localizedDescription)")
                    errorsAlert = true
                    isTimerRunning = false
                    // Handle the error and show appropriate alert
                } else {
                    // Object created successfully

                    print("Object created successfully")
                    
                    let userDatabase = database.child("users").child(fillid)

                    // Check if the user data exists
                    userDatabase.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            let accountIDReference = database.child("users").child(fillid).child("accountid")
                            
                            let apnsRef = database.child("users").child(fillid).child("apnsid")

                            // Observe the value at the accountid location
                            accountIDReference.observeSingleEvent(of: .value) { snapshot in
                                if snapshot.exists() {
                                    // Retrieve the accountid value
                                    if let accountIDValue = snapshot.value as? String {
                                        if accountIDValue == fillid
                                        {
                                            let updateAccountIDData = ["accountid": UID,
                                                              UID: true] as [String : Any]

                                            // Update the firstname in the database
                                            userDatabase.updateChildValues(updateAccountIDData) { error, _ in
                                                if let error = error {
                                                    print("Error updating UID: \(error.localizedDescription)")
                                                } else {
                                                    print("UID updated successfully.")
                                                    apnsRef.observeSingleEvent(of: .value) { snapshot in
                                                        if snapshot.exists() {
                                                            // Retrieve the accountid value
                                                            if let apns = snapshot.value as? String {
                                                                sendPushNotification(body: "\(firstname) \(lastname) has signed up to be your caretaker!", subtitle: "Caretaker Signup", phoneId: apns)
                                                            }
                                                        }
                                                    }
                                                    
                                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                                    UserDefaults.standard.set(true, forKey: "role")
                                                    UserDefaults.standard.set(email, forKey: "email")
                                                    UserDefaults.standard.set(password, forKey: "pass")
                                                    UserDefaults.standard.set(firstname, forKey: "fname")
                                                    UserDefaults.standard.set(lastname, forKey: "lname")
                                                    UserDefaults.standard.set(UID, forKey: "userid")
                                                    path.append("Caretaker")
                                                }
                                            }
                                        }
                                        else
                                        {
                                            errorsAlert = true
                                            idInUseAlert = true
                                            codeTrue = true
                                            isTimerRunning = false
                                            let caretakerAccountIDReference = database.child("caretaker").child(UID)
                                            
                                            caretakerAccountIDReference.removeValue { error, _ in
                                                if let error = error {
                                                    print("Failed to delete child node: \(error.localizedDescription)")
                                                } else {
                                                    print("Child node deleted successfully")
                                                    deleteUserAccount()
                                                }
                                            }
                                        }

                                    } else {
                                        print("accountid does not exist or is not a string value.")
                                    }
                                } else {
                                    print("accountid does not exist.")
                                }
                            }

                            
                        } else {
                            errorsAlert = true
                            invalidIdAlert = true
                            codeTrue = true
                            isTimerRunning = false
                            let caretakerAccountIDReference = database.child("caretaker").child(UID)
                            
                            caretakerAccountIDReference.removeValue { error, _ in
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

// creates a textfield that can appear as a secure text field with click of a eye image
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
                .padding(.trailing, 20)
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}
// creates a textfield that can appear as a secure text field with click of a eye image
struct SecureTextField2: View{
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
                .padding(.trailing, 20)
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}
// creates a textfield that can appear as a secure text field with click of a eye image
struct SecureTextField3: View{
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
                .padding(.trailing, 20)
                .onTapGesture {
                    isSecureField.toggle()
                }
        }
    }
}


#Preview {
    SignupView()
}
