//
//  MessageView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 12/5/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseMessaging

// This struct is to allow a caretaker to communicate with their medicine taker
// through push notifications
struct CaretakerMessageView: View {
    @State private var message = ""
    @State private var recap = ""
    @State private var increment = 0
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text("Messages")
                    .foregroundStyle(.white)
                    .font(.custom("AmericanTypewriter-Bold", size: 40))
                    .shadow(color: .black, radius: 5)
                
                Text("Send a message to your medicine taker")
                    .foregroundStyle(.white)
                    .bold()
                    .shadow(color: .black, radius: 5)
                
                TextField("Message", text: $message, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .lineLimit(6)
                
                Text("Note: All Messages Are Unsaved After Closing App")
                    .foregroundStyle(.red)
                    .font(.custom("AmericanTypewriter-Bold", size: 14))
                    .bold()
                    .shadow(color: .black, radius: 5)

                
                Button(action: {
                    increment += 1
                    recap += "\(increment). \(message)\n"
                    sendMessage(message: message)
                    message = ""
                }, label: {
                    Text("Send")
                        .bold()
                        .frame(width: 200, height: 40)
                        .foregroundStyle(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                        }
                })
                Spacer()
                Text("Current Message History")
                    .foregroundStyle(.white)
                    .bold()
                    .font(.custom("AmericanTypewriter-Bold", size: 20))
                    .shadow(color: .black, radius: 5)
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                    .foregroundStyle(.white)
                
                Text("\(recap)\n")
                    .foregroundStyle(.white)
                    .bold()
                    .padding()
                    .shadow(color: .black, radius: 5)
                
            }
            .ignoresSafeArea()
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    // This method retreives the apns token from the caretaker. Since the caretaker will contain
    // the apns of the medicine taker (look at how getAPN() works), it will then send a push notification to the medicine taker
    // using firebase service FCM
    func sendMessage(message: String) {
        let database = Database.database().reference()
        let id = UserDefaults.standard.string(forKey: "userid") ?? "NO ID"
        let caretakerDatabase = database.child("caretaker").child(id)
        var fullname = ""
        var apn = ""
        
        caretakerDatabase.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let caretakerData = snapshot.value as? [String: Any] else {
                    return
                }
                
                if let apns = caretakerData["apnsid"] as? String {
                    apn = apns
                }
                
                fullname += UserDefaults.standard.string(forKey: "fname")!
                fullname += " "
                fullname += UserDefaults.standard.string(forKey: "lname")!
                
                sendPushNotification(body: message, subtitle: "Message from \(fullname)", phoneId: apn)
            }
        }
    }
}
