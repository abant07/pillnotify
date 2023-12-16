//
//  IntentViewController.swift
//  ViewMedsUI
//
//  Created by Amogh Bantwal on 7/15/23.
//

import IntentsUI
import IntentKit
import Intents
import os.log
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

let sharedDefaults = UserDefaults(suiteName: ShareDefaults.suitName)

// This class is a siri intent class that allows the medicine taker to trigger shortcuts that can confirm,
// delete, and view meds without opening the app
class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure() // this configures firebase so that we can access the database
    }
    
    // This method configures what view should be presented to the user depending on what they said to Siri.
    // For example, if the user wants to view their meds, then it will trigger the ViewMyMedsIntent to display the meds
    // If the user says view my meds, it will go to the state of success, however, if they say delete my meds or confirm my meds,
    // it will go to a state of ready where it needs confirmation from the user to continue to prevent invalid triggers.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        

        if interaction.intentHandlingStatus == .success {
            if let _ = interaction.intentResponse as? ViewMyMedsIntentResponse {
                if let email = sharedDefaults?.string(forKey: ShareDefaults.Keys.user),
                   let password = sharedDefaults?.string(forKey: ShareDefaults.Keys.pass) {
                    viewMedsLogin(email: email, password: password) { [weak self] isLoggedIn in
                        guard let self = self else {
                            // Handle the case when self has been deallocated before the closure is executed
                            completion(false, parameters, self?.desiredSize ?? CGSize.zero)
                            return
                        }
                        
                        if isLoggedIn {
                            self.getMedsString { medsArray in
                                let medView = MedsView()
                                self.view.addSubview(medView)
                                medView.translatesAutoresizingMaskIntoConstraints = false
                                NSLayoutConstraint.activate([
                                    medView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                    self.view.trailingAnchor.constraint(equalTo: medView.trailingAnchor),
                                    medView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                ])
                                medView.setNeedsLayout()
                                medView.layoutIfNeeded()
                                medView.update(meds: medsArray)
                                completion(true, parameters, CGSize(width: self.desiredSize.width, height: medView.frame.height))
                            }
                        } else {
                            // Handle the case when login fails
                            completion(false, parameters, self.desiredSize)
                        }
                    }
                } else {
                    // Handle the case when email or password is not available
                    completion(false, parameters, desiredSize)
                    let content = UNMutableNotificationContent()
                    content.title = "PillNotify"
                    content.subtitle = "Siri Permissions"
                    content.body = "Sorry, you have to be logged in as a user to use siri shortcuts."
                    content.sound = UNNotificationSound.default
                    content.badge = 1
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            // Handle the error
                            print("Error adding notification1 request:", error)
                        } else {
                            // Notification request added successfully
                            print("Notification1 request added successfully")
                        }
                    }
                }
                return
            }
            
            if let _ = interaction.intentResponse as? DeleteMedsIntentResponse {
                if let deleteMedsIntent = interaction.intent as? DeleteMedsIntent {
                    if let medicationName = deleteMedsIntent.medicationName {
                        if let email = sharedDefaults?.string(forKey: ShareDefaults.Keys.user) {
                            if let password = sharedDefaults?.string(forKey: ShareDefaults.Keys.pass) {
                                deleteMedsLogin(email: email, password: password, medication: medicationName.uppercased())
                            }
                        }
                    } else {
                        // The user didn't provide the medication name, handle the situation accordingly.
                        print("No medication name provided.")
                        let content = UNMutableNotificationContent()
                        content.title = "PillNotify"
                        content.subtitle = "Siri Permissions"
                        content.body = "Sorry, you have to be logged in as a user to use siri shortcuts."
                        content.sound = UNNotificationSound.default
                        content.badge = 1
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                // Handle the error
                                print("Error adding notification1 request:", error)
                            } else {
                                // Notification request added successfully
                                print("Notification1 request added successfully")
                            }
                        }
                    }
                }
                return
            }
            
            if let _ = interaction.intentResponse as? ConfirmMedsIntentResponse {
                if let confirmMedsIntent = interaction.intent as? ConfirmMedsIntent {
                    if let medicationName = confirmMedsIntent.medicationName {
                        if let email = sharedDefaults?.string(forKey: ShareDefaults.Keys.user) {
                            if let password = sharedDefaults?.string(forKey: ShareDefaults.Keys.pass) {
                                confirmMedsLogin(email: email, password: password, medication: medicationName.uppercased())
                            }
                        }
                    } else {
                        // The user didn't provide the medication name, handle the situation accordingly.
                        print("No medication name provided.")
                        let content = UNMutableNotificationContent()
                        content.title = "PillNotify"
                        content.subtitle = "Siri Permissions"
                        content.body = "Sorry, you have to be logged in as a user to use siri shortcuts."
                        content.sound = UNNotificationSound.default
                        content.badge = 1
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                // Handle the error
                                print("Error adding notification1 request:", error)
                            } else {
                                // Notification request added successfully
                                print("Notification1 request added successfully")
                            }
                        }
                    }
                }
                return
            }
        }
        
        // All the views show the medications, its only that both confirmmymeds and deletemymeds ask
        // a follow up to make sure the user specifies what med to delete/confirm
        if interaction.intentHandlingStatus == .ready {
            if let _ = interaction.intentResponse as? ConfirmMedsIntentResponse {
                getMedsString { [weak self] medsArray in
                    guard let self = self else {
                        // Handle the case when self has been deallocated before the closure is executed
                        completion(false, parameters, self?.desiredSize ?? CGSize.zero)
                        return
                    }
                    
                    let medView = MedsView()
                    self.view.addSubview(medView)
                    medView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        medView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        self.view.trailingAnchor.constraint(equalTo: medView.trailingAnchor),
                        medView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    ])
                    medView.setNeedsLayout()
                    medView.layoutIfNeeded()
                    medView.update(meds: medsArray)
                    completion(true, parameters, CGSize(width: self.desiredSize.width, height: medView.frame.height))
                }
                return
            }
            
            if let _ = interaction.intentResponse as? DeleteMedsIntentResponse {
                getMedsString { [weak self] medsArray in
                    guard let self = self else {
                        // Handle the case when self has been deallocated before the closure is executed
                        completion(false, parameters, self?.desiredSize ?? CGSize.zero)
                        return
                    }
                    
                    let medView = MedsView()
                    self.view.addSubview(medView)
                    medView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        medView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        self.view.trailingAnchor.constraint(equalTo: medView.trailingAnchor),
                        medView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    ])
                    medView.setNeedsLayout()
                    medView.layoutIfNeeded()
                    medView.update(meds: medsArray)
                    completion(true, parameters, CGSize(width: self.desiredSize.width, height: medView.frame.height))
                }
                return
            }
        }

        completion(false, parameters, self.desiredSize)
    }
    
    
    // This method takes a medication name in all uppercase since that is what it is in firebase.
    // Then it iterates through all the medicines for the specific user that is logged in and deletes the medicine
    // that matches the med name passed in. It also deletes any reports associated with that pill and images from Firebase Storage
    func deleteItems(med: String) {
        if let _ = Auth.auth().currentUser {
            if let username = sharedDefaults?.string(forKey: ShareDefaults.Keys.username)
            {
                
                let database = Database.database().reference()
                let medicineReference = database.child("medicines").child(username)
                
                medicineReference.child(med).removeValue { error, _ in
                    if let error = error {
                        print("Failed to delete medicine: \(error.localizedDescription)")
                        
                    } else {
                        print("Medicine deleted successfully")
                        var picname = med.replacingOccurrences(of: " ", with: "-")
                        picname = picname.replacingOccurrences(of: "\\", with: "")
                        

                        let imageDatabase = Storage.storage().reference().child("images").child(username).child("\(picname).jpg")
                        var fullname = ""
                        var apn = ""

                        // Delete the file
                        imageDatabase.delete { error in
                            if let error = error {
                                // Handle the error case
                                print("Failed to delete file: \(error.localizedDescription)")
                                let content = UNMutableNotificationContent()
                                content.title = "PillNotify"
                                content.subtitle = "Med Not Found"
                                content.body = "Sorry, couldn't find that medicine. Make sure Siri's spelling matches what is inputted in the app. If not, change the name in the app to match how Siri spells it."
                                content.sound = UNNotificationSound.default
                                content.badge = 1
                                
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                
                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                
                                UNUserNotificationCenter.current().add(request) { error in
                                    if let error = error {
                                        // Handle the error
                                        print("Error adding notification1 request:", error)
                                    } else {
                                        // Notification request added successfully
                                        print("Notification1 request added successfully")
                                    }
                                }
                            } else {
                                // File deleted successfully
                                print("File deleted successfully")


                                let reportsReference = database.child("reports").child(username).child(med)
                                reportsReference.removeValue { error, _ in
                                    if let error = error {
                                        print("Failed to delete report: \(error.localizedDescription)")
                                    } else {
                                        print ("Successful deleted report")
                                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                        let content = UNMutableNotificationContent()
                                        content.title = "PillNotify"
                                        content.subtitle = "Deletion"
                                        content.body = "Deletion successful"
                                        content.sound = UNNotificationSound.default
                                        content.badge = 1
                                        
                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                        
                                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                        
                                        UNUserNotificationCenter.current().add(request) { error in
                                            if let error = error {
                                                // Handle the error
                                                print("Error adding notification1 request:", error)
                                            } else {
                                                // Notification request added successfully
                                                print("Notification1 request added successfully")
                                            }
                                        }
                                        
                                        self.sendMessage()
                                        
                                        let usersReference = database.child("users").child(username)
                                        usersReference.observeSingleEvent(of: .value) { snapshot in
                                            if snapshot.exists() {
                                                guard let usersData = snapshot.value as? [String: Any] else {
                                                    return
                                                }
                                                
                                                

                                                if let fname = sharedDefaults?.string(forKey: ShareDefaults.Keys.fname)
                                                {
                                                    fullname = fname
                                                }
                                                
                                                if let apns = usersData["apnsid"] as? String {
                                                    apn = apns
                                                }
                                                if let ap = sharedDefaults?.string(forKey: ShareDefaults.Keys.apns) {
                                                    if ap != apn
                                                    {
                                                        self.sendPushNotification(body: "\(fullname) has deleted \(med.uppercased()).", subtitle: "Deleted Medication", phoneId: apn)
                                                    }
                                                }
                                                
                                            } else {
                                                print("No data found in users node")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                let content = UNMutableNotificationContent()
                content.title = "PillNotify"
                content.subtitle = "Siri Permissions"
                content.body = "Sorry, you have to be logged in as a user to use siri shortcuts."
                content.sound = UNNotificationSound.default
                content.badge = 1
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        // Handle the error
                        print("Error adding notification1 request:", error)
                    } else {
                        // Notification request added successfully
                        print("Notification1 request added successfully")
                    }
                }
            }
        }
        
    }
    
    //This method inputs a date, a userID, and medication name and createss UNUserNotification that will
    // go off at the time the parameters specified on a specific day in the week
    // It also creates a notificatio with a image that was queried using the userID;
    func scheduleNotification(med: String, user: String, day: Date, week: Int)
    {
        let database = Database.database().reference()
        var color = ""
        var shape = ""
        var amount = 0
        var unit = ""
        var fullname = ""
        
        if let user = sharedDefaults?.string(forKey: ShareDefaults.Keys.username)
        {
            let usersReference = database.child("users").child(user)
            usersReference.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    guard let _ = snapshot.value as? [String: Any] else {
                        return
                    }
                    
                    
                    if let fname = sharedDefaults?.string(forKey: ShareDefaults.Keys.fname)
                    {
                        fullname = fname
                    }
                } else {
                    print("No data found in users node")
                }
            }
        }
        
        
        let username = sharedDefaults?.string(forKey: ShareDefaults.Keys.username)
        let medicineDatabase = database.child("medicines").child(username!).child(med)
        
        medicineDatabase.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let medicineData = snapshot.value as? [String: Any] else {
                    return
                }
                
                if let medcolor = medicineData["medcolor"] as? String
                {
                    color = medcolor
                }
                if let medshape = medicineData["medshape"] as? String
                {
                    shape = medshape
                }
                
                if let dose = medicineData["dosage"] as? Int
                {
                    amount = dose
                }
                
                if let measure = medicineData["unit"] as? String
                {
                    unit = measure
                }
                
                var picname = med.replacingOccurrences(of: " ", with: "-")
                picname = picname.replacingOccurrences(of: "\\", with: "")
                
                let imageDatabase = Storage.storage().reference().child("images").child(username!).child("\(picname).jpg")

                imageDatabase.downloadURL { (url, error) in
                    if let error = error {
                        // Handle the error case
                        print("Failed to retrieve download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let downloadURL = url else {
                        // Handle the case where download URL is nil
                        return
                    }
                    
                    let imageUrlString = downloadURL.absoluteString
                    
                    if let imageUrl = URL(string: imageUrlString) {
                        if let imageData = try? Data(contentsOf: imageUrl),
                           let uiImage = UIImage(data: imageData) {
                                // Update your UI with the loaded image
                                let content = UNMutableNotificationContent()
                                content.title = "PillNotify"
                                content.subtitle = med
                                content.body = "Hey \(fullname)! It's time to take your \(med).\nDescription: (Color: \(color), Shape: \(shape), Dosage: \(amount)\(unit)). Make sure to confirm in the app!"
                                content.sound = UNNotificationSound.default
                                content.badge = 1
                                
                                let suffix = day
                                let calendar = Calendar.current
                                let components = calendar.dateComponents([.hour, .minute], from: suffix)
                                
                                let hour = components.hour ?? 0
                                let minute = components.minute ?? 0
                                
                                
                                // Get the UIImage from your source, e.g. the camera roll
                                let image = uiImage
                                let uuid = UUID().uuidString
                                let filename = "\(uuid).jpg"

                                // Compress the image data to reduce the file size
                                if let compressedImageData = image.jpegData(compressionQuality: 0.5) {

                                    // Create a URL for the compressed image data
                                    let temporaryDirectory = NSTemporaryDirectory()
                                    let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(filename)
                                    try? compressedImageData.write(to: temporaryFileURL, options: [.atomic])

                                    // Create a UNNotificationAttachment with the image URL
                                    do {
                                        let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: temporaryFileURL, options: nil)
                                        content.attachments = [attachment]
                                    } catch {
                                        print("Error creating notification attachment: \(error.localizedDescription)")
                                    }
                                } else {
                                    print("Error compressing image data")
                                }
                                
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute, weekday: week), repeats: true)

                                
                                // choose a random identifier
                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                
                                
                                // add our notification request
                                UNUserNotificationCenter.current().add(request) { error in
                                    if let error = error {
                                        // Handle the error
                                        print("Error adding notification1 request:", error)
                                    } else {
                                        // Notification request added successfully
                                        print("Notification1 request added successfully")
                                    }
                                }
                        } else {
                            // Failed to convert the image data to UIImage or retrieve the image data
                            // Handle the error case
                            print ("Failed to convert the image data to UIImage or retrieve the image data")
                        }
                    } else {
                        // Handle the case where image URL is invalid
                        print ("image URL is invalid")
                    }
                }
            }
        }
    }

    // This method sends a push notification serviced by Firebase when passed in a APNS token of a device and message body
    // and title
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
    
    // This method confirms the medicine that the user said to Siri. It runs through edge cases such as if the user confirms twice,
    // if the user wants to confirm their dose early, if they confirm late, if they update a medicine time after confirming their med
    func confirmMed(med: String)
    {
        let database = Database.database().reference()
        var countOfReminders = false
        var confirmingDate: [Date] = []
        var pillsleft = 0
        var amount = 0
        var unit = ""
        var secondunit = ""
        var count = 0
        var inputImage: UIImage = UIImage()
        var fullnameU = ""
        var apn = ""
        var repeats = false
        var updateReportsCount = false
        var confirmTime = Date()
        var dates: [Int: [Int: Date]] = [:]
        var idcount = 1
        var userid = ""
        if let _ = Auth.auth().currentUser {
            if let user = sharedDefaults?.string(forKey: ShareDefaults.Keys.username)
            {
                let userDatabase = database.child("users").child(user)
                userDatabase.observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        guard let userData = snapshot.value as? [String: Any] else {
                            return
                        }
                        
                        if let id = userData["accountid"] as? String {
                            userid = id
                            let caretakerDatabase = database.child("caretaker").child(userid)
                            caretakerDatabase.observeSingleEvent(of: .value) { snapshot in
                                if snapshot.exists()
                                {
                                    guard snapshot.value is [String: Any] else {
                                        return
                                    }
                                    
                                    let paidReference = database.child("caretaker").child(userid).child("paid")
                                    
                                    paidReference.observeSingleEvent(of: .value) { (snapshot, error) in
                                        if let error = error {
                                            print("Error getting paid value: \(error)")
                                        } else {
                                            if let paidValue = snapshot.value as? Bool {
                                                if paidValue
                                                {

                                                    // Access and use other fields from userData dictionary
                                                    userDatabase.observeSingleEvent(of: .value) { snapshot in
                                                        if snapshot.exists() {
                                                            guard let userData = snapshot.value as? [String: Any] else {
                                                                return
                                                            }
                                                            
                                                            if let fname = sharedDefaults?.string(forKey: ShareDefaults.Keys.fname)
                                                            {
                                                                if let lname = sharedDefaults?.string(forKey: ShareDefaults.Keys.lname)
                                                                {
                                                                    fullnameU += fname
                                                                    fullnameU += " "
                                                                    fullnameU += lname
                                                                }
                                                            }
                                                            if let id = userData["apnsid"] as? String {
                                                                apn = id
                                                            }
                                                            
                                                            let medicineDatabase = database.child("medicines").child(user).child(med)
                                                            medicineDatabase.observeSingleEvent(of: .value) { snapshot in
                                                                if snapshot.exists(), let medicineData = snapshot.value as? [String: Any] {
                                                                    if let medremain = medicineData["remaining"] as? Int
                                                                    {
                                                                        pillsleft = medremain
                                                                    }
                                                                    
                                                                    if let dose = medicineData["dosage"] as? Int
                                                                    {
                                                                        amount = dose
                                                                    }
                                                                    
                                                                    if let measure = medicineData["unit"] as? String
                                                                    {
                                                                        unit = measure
                                                                    }
                                                                    if let measure = medicineData["secondunit"] as? String
                                                                    {
                                                                        secondunit = measure
                                                                    }
                                                                    if let counttimes = medicineData["count"] as? Int
                                                                    {
                                                                        count = counttimes
                                                                    }
                                                                    
                                                                    if let reape = medicineData["repeatMissed"] as? Bool
                                                                    {
                                                                        repeats = reape
                                                                    }
                                                                    
                                                                    if let time = medicineData["lastconfirm"] as? String {
                                                                        let dateFormatter = DateFormatter()
                                                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                                        confirmTime = dateFormatter.date(from: time)!
                                                                    }
                                                                    
                                                                    
                                                                    if let reminders = medicineData["reminders"] as? [String: [String]] {
                                                                        var count2 = 1
                                                                        for (day, times) in reminders {
                                                                            count2 = 1
                                                                            for time in times {
                                                                                let dateFormatter = DateFormatter()
                                                                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                                                if let date = dateFormatter.date(from: time) {
                                                                                    switch day {
                                                                                    case "Monday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [2:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [2:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [2:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    case "Tuesday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [3:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [3:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [3:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    case "Wednesday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [4:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [4:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [4:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    case "Thursday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [5:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [5:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [5:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    case "Friday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [6:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [6:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [6:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    case "Saturday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [7:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [7:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [7:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    case "Sunday":
                                                                                        if count2 == 1 {
                                                                                            dates[idcount] = [1:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 2 {
                                                                                            dates[idcount] = [1:date]
                                                                                            idcount += 1
                                                                                            count2 += 1
                                                                                        } else if count2 == 3 {
                                                                                            dates[idcount] = [1:date]
                                                                                            idcount += 1
                                                                                        }
                                                                                    default:
                                                                                        break
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                        // sort the dates by weekday and then earliest to latest by time
                                                                        let calendar = Calendar.current
                                                                        let today = Date()
                                                                        let currentWeekday = calendar.component(.weekday, from: today)
                                                                        
                                                                        let datesDict = dates
                                                                        
                                                                        // Step 1: Filter the dictionary entries based on the current weekday integer.
                                                                        let filteredDates = datesDict.filter { (_, weekdayDateDict) in
                                                                            return weekdayDateDict.keys.contains(currentWeekday)
                                                                        }
                                                                        
                                                                        // Step 2: Sort the remaining entries by the dates in ascending order.
                                                                        let sortedDictionary = filteredDates.sorted { (entry1, entry2) in
                                                                            let date1 = entry1.value[currentWeekday]!
                                                                            let date2 = entry2.value[currentWeekday]!
                                                                            return date1 < date2
                                                                        }.map { (id, weekdayDateDict) in
                                                                            return (key: id, value: weekdayDateDict[currentWeekday]!)
                                                                        }
                                                                        print (sortedDictionary)
                                                                        
                                                                        for (_, value) in sortedDictionary {
                                                                            let calendar = Calendar.current
                                                                            let components = calendar.dateComponents([.hour, .minute], from: value)
                                                                            let dateWithSameTime = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: today)!
                                                                            
                                                                            
                                                                            if dateWithSameTime.compare(confirmTime) == .orderedDescending {
                                                                                // date is after confirm
                                                                                countOfReminders = true
                                                                                confirmingDate.append(dateWithSameTime)
                                                                            }
                                                                            
                                                                        }
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                    let medicinesReference = database.child("medicines").child(user)
                                                                    medicinesReference.observeSingleEvent(of: .value) { snapshot in
                                                                        var shouldUpdateMedicine = false
                                                                        
                                                                        if snapshot.exists() {
                                                                            // Medication name already exists, check if it belongs to the same username
                                                                            if let medicinesData = snapshot.value as? [String: [String: Any]] {
                                                                                for (_, medicineData) in medicinesData {
                                                                                    if let existingUsername = medicineData["username"] as? String, existingUsername == user {
                                                                                        // Medicine with the same name and username exists
                                                                                        shouldUpdateMedicine = true
                                                                                        break
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                        if shouldUpdateMedicine {
                                                                            if countOfReminders
                                                                            {
                                                                                for remind in confirmingDate
                                                                                {
                                                                                    if pillsleft == 0
                                                                                    {
                                                                                        let content = UNMutableNotificationContent()
                                                                                        content.title = "PillNotify"
                                                                                        content.subtitle = "Refill"
                                                                                        content.body = "Sorry, you have no supply left for \(med)."
                                                                                        content.sound = UNNotificationSound.default
                                                                                        content.badge = 1
                                                                                        
                                                                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                        
                                                                                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                        
                                                                                        UNUserNotificationCenter.current().add(request) { error in
                                                                                            if let error = error {
                                                                                                // Handle the error
                                                                                                print("Error adding notification1 request:", error)
                                                                                            } else {
                                                                                                // Notification request added successfully
                                                                                                print("Notification1 request added successfully")
                                                                                            }
                                                                                        }
                                                                                        self.sendPushNotification(body: "Hey! it looks like \(fullnameU) tried to confirm \(med) for \(self.dateToString(count:remind)), but ran out of supply. Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                                                                    }
                                                                                    else if unit == "pills" || unit == "puffs" || unit == "injections"
                                                                                    {
                                                                                        if pillsleft - amount < 0
                                                                                        {
                                                                                            let content = UNMutableNotificationContent()
                                                                                            content.title = "PillNotify"
                                                                                            content.subtitle = "Refill"
                                                                                            content.body = "Sorry, you don't have enough supply to confirm \(med). \(pillsleft)\(secondunit) left."
                                                                                            content.sound = UNNotificationSound.default
                                                                                            content.badge = 1
                                                                                            
                                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                            
                                                                                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                            
                                                                                            UNUserNotificationCenter.current().add(request) { error in
                                                                                                if let error = error {
                                                                                                    // Handle the error
                                                                                                    print("Error adding notification1 request:", error)
                                                                                                } else {
                                                                                                    // Notification request added successfully
                                                                                                    print("Notification1 request added successfully")
                                                                                                }
                                                                                            }
                                                                                            self.sendPushNotification(body: "Hey! it looks like \(fullnameU) doesn't have enough supply for \(med) to confirm at \(self.dateToString(count:remind)). Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            if updateReportsCount == false && repeats == true
                                                                                            {
                                                                                                self.updateReports(med: med, date: confirmingDate)
                                                                                                updateReportsCount = true
                                                                                            }
                                                                                            
                                                                                            pillsleft -= amount
                                                                                            count += 1
                                                                                            
                                                                                            let medicineRef = database.child("medicines").child(user).child(med)
                                                                                            let updatedData: [String: Any] = [
                                                                                                "remaining": pillsleft,
                                                                                                "count": count,
                                                                                                "lastconfirm": self.dateToString(count: remind)
                                                                                            ]
                                                                                            
                                                                                           
                                                                                            
                                                                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                                                                if let error = error {
                                                                                                    // Handle the error case
                                                                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                                                                } else {
                                                                                                    
                                                                                                    if (pillsleft / amount >= 0) && (pillsleft / amount <= 10)
                                                                                                    {
                                                                                                        let picname = med.replacingOccurrences(of: " ", with: "-")
                                                                                                        let imageDatabase = Storage.storage().reference().child("images").child(user).child("\(picname).jpg")
                                                                                                        
                                                                                                        imageDatabase.downloadURL { (url, error) in
                                                                                                            if let error = error {
                                                                                                                // Handle the error case
                                                                                                                print("Failed to retrieve download URL: \(error.localizedDescription)")
                                                                                                                return
                                                                                                            }
                                                                                                            
                                                                                                            guard let downloadURL = url else {
                                                                                                                // Handle the case where download URL is nil
                                                                                                                return
                                                                                                            }
                                                                                                            
                                                                                                            let imageUrlString = downloadURL.absoluteString
                                                                                                            
                                                                                                            if let imageUrl = URL(string: imageUrlString) {
                                                                                                                DispatchQueue.global().async {
                                                                                                                    if let imageData = try? Data(contentsOf: imageUrl),
                                                                                                                       let uiImage = UIImage(data: imageData) {
                                                                                                                        DispatchQueue.main.async {
                                                                                                                            // Update your UI with the loaded image
                                                                                                                            inputImage = uiImage
                                                                                                                            let content = UNMutableNotificationContent()
                                                                                                                            content.title = "PillNotify"
                                                                                                                            content.subtitle = "Refill"
                                                                                                                            content.body = "Hi, \(fullnameU), you're supply for \(med) is getting low. \(pillsleft)\(secondunit) left."
                                                                                                                            content.sound = UNNotificationSound.default
                                                                                                                            content.badge = 1
                                                                                                                            
                                                                                                                            // Get the UIImage from your source, e.g. the camera roll
                                                                                                                            let image = inputImage
                                                                                                                            let uuid = UUID().uuidString
                                                                                                                            let filename = "\(uuid).jpg"
                                                                                                                            
                                                                                                                            // Compress the image data to reduce the file size
                                                                                                                            if let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                                                                                                                                
                                                                                                                                // Create a URL for the compressed image data
                                                                                                                                let temporaryDirectory = NSTemporaryDirectory()
                                                                                                                                let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(filename)
                                                                                                                                try? compressedImageData.write(to: temporaryFileURL, options: [.atomic])
                                                                                                                                
                                                                                                                                // Create a UNNotificationAttachment with the image URL
                                                                                                                                do {
                                                                                                                                    let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: temporaryFileURL, options: nil)
                                                                                                                                    content.attachments = [attachment]
                                                                                                                                } catch {
                                                                                                                                    print("Error creating notification attachment: \(error.localizedDescription)")
                                                                                                                                }
                                                                                                                            } else {
                                                                                                                                print("Error compressing image data")
                                                                                                                            }
                                                                                                                            
                                                                                                                            
                                                                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                                                            
                                                                                                                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                                                            
                                                                                                                            UNUserNotificationCenter.current().add(request) { error in
                                                                                                                                if let error = error {
                                                                                                                                    // Handle the error
                                                                                                                                    print("Error adding notification1 request:", error)
                                                                                                                                } else {
                                                                                                                                    // Notification request added successfully
                                                                                                                                    print("Notification1 request added successfully")
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                                self.sendPushNotification(body: "Hey! \(fullnameU) is running low on supply for \(med). \(pillsleft)\(secondunit) left.", subtitle: "Refill Medications", phoneId: apn)
                                                                                                            } else {
                                                                                                                // Handle the case where image URL is invalid
                                                                                                                print ("image URL is invalid")
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        
                                                                                                    }
                                                                                                    print("Medicine updated successfully")
                                                                                                    /*
                                                                                                    if repeats == true
                                                                                                    {
                                                                                                        self.sendPushNotification(body: "\(fullnameU) has confirmed thier \(self.dateToString(count:remind)) dose for \(med). \(pillsleft)\(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        self.sendPushNotification(body: "\(fullnameU) has confirmed thier \(self.dateToString(count:remind)) dose for \(med) late. \(pillsleft)\(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                                                                    }
                                                                                                     */
                                                                                                    
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    else if (unit != "pills" && unit != "puffs" && unit != "injections") && (secondunit != "pills" && secondunit != "puffs" && secondunit != "injections")
                                                                                    {
                                                                                        if pillsleft - amount < 0
                                                                                        {
                                                                                            if pillsleft - amount < 0
                                                                                            {
                                                                                                let content = UNMutableNotificationContent()
                                                                                                content.title = "PillNotify"
                                                                                                content.subtitle = "Refill"
                                                                                                content.body = "Sorry, you don't have enough supply to confirm \(med). \(pillsleft)\(secondunit) left."
                                                                                                content.sound = UNNotificationSound.default
                                                                                                content.badge = 1
                                                                                                
                                                                                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                                
                                                                                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                                
                                                                                                UNUserNotificationCenter.current().add(request) { error in
                                                                                                    if let error = error {
                                                                                                        // Handle the error
                                                                                                        print("Error adding notification1 request:", error)
                                                                                                    } else {
                                                                                                        // Notification request added successfully
                                                                                                        print("Notification1 request added successfully")
                                                                                                    }
                                                                                                }
                                                                                                self.sendPushNotification(body: "Hey! it looks like \(fullnameU) doesn't have enough supply for \(med) to confirm at \(self.dateToString(count:remind)). Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                if updateReportsCount == false && repeats == true
                                                                                                {
                                                                                                    self.updateReports(med: med, date: confirmingDate)
                                                                                                    updateReportsCount = true
                                                                                                }
                                                                                                
                                                                                                pillsleft -= amount
                                                                                                count += 1
                                                                                                
                                                                                                let medicineRef = database.child("medicines").child(user).child(med)
                                                                                                let updatedData: [String: Any] = [
                                                                                                    "remaining": pillsleft,
                                                                                                    "count": count,
                                                                                                    "lastconfirm": self.dateToString(count: remind)
                                                                                                ]
                                                                                                
                                                                                               
                                                                                                
                                                                                                medicineRef.updateChildValues(updatedData) { error, _ in
                                                                                                    if let error = error {
                                                                                                        // Handle the error case
                                                                                                        print("Failed to update medicine: \(error.localizedDescription)")
                                                                                                    } else {
                                                                                                        
                                                                                                        if (pillsleft / amount >= 0) && (pillsleft / amount <= 10)
                                                                                                        {
                                                                                                            let picname = med.replacingOccurrences(of: " ", with: "-")
                                                                                                            let imageDatabase = Storage.storage().reference().child("images").child(user).child("\(picname).jpg")
                                                                                                            
                                                                                                            imageDatabase.downloadURL { (url, error) in
                                                                                                                if let error = error {
                                                                                                                    // Handle the error case
                                                                                                                    print("Failed to retrieve download URL: \(error.localizedDescription)")
                                                                                                                    return
                                                                                                                }
                                                                                                                
                                                                                                                guard let downloadURL = url else {
                                                                                                                    // Handle the case where download URL is nil
                                                                                                                    return
                                                                                                                }
                                                                                                                
                                                                                                                let imageUrlString = downloadURL.absoluteString
                                                                                                                
                                                                                                                if let imageUrl = URL(string: imageUrlString) {
                                                                                                                    DispatchQueue.global().async {
                                                                                                                        if let imageData = try? Data(contentsOf: imageUrl),
                                                                                                                           let uiImage = UIImage(data: imageData) {
                                                                                                                            DispatchQueue.main.async {
                                                                                                                                // Update your UI with the loaded image
                                                                                                                                inputImage = uiImage
                                                                                                                                let content = UNMutableNotificationContent()
                                                                                                                                content.title = "PillNotify"
                                                                                                                                content.subtitle = "Refill"
                                                                                                                                content.body = "Hi, \(fullnameU), you're supply for \(med) is getting low. \(pillsleft)\(secondunit) left."
                                                                                                                                content.sound = UNNotificationSound.default
                                                                                                                                content.badge = 1
                                                                                                                                
                                                                                                                                // Get the UIImage from your source, e.g. the camera roll
                                                                                                                                let image = inputImage
                                                                                                                                let uuid = UUID().uuidString
                                                                                                                                let filename = "\(uuid).jpg"
                                                                                                                                
                                                                                                                                // Compress the image data to reduce the file size
                                                                                                                                if let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                                                                                                                                    
                                                                                                                                    // Create a URL for the compressed image data
                                                                                                                                    let temporaryDirectory = NSTemporaryDirectory()
                                                                                                                                    let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(filename)
                                                                                                                                    try? compressedImageData.write(to: temporaryFileURL, options: [.atomic])
                                                                                                                                    
                                                                                                                                    // Create a UNNotificationAttachment with the image URL
                                                                                                                                    do {
                                                                                                                                        let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: temporaryFileURL, options: nil)
                                                                                                                                        content.attachments = [attachment]
                                                                                                                                    } catch {
                                                                                                                                        print("Error creating notification attachment: \(error.localizedDescription)")
                                                                                                                                    }
                                                                                                                                } else {
                                                                                                                                    print("Error compressing image data")
                                                                                                                                }
                                                                                                                                
                                                                                                                                
                                                                                                                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                                                                
                                                                                                                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                                                                
                                                                                                                                UNUserNotificationCenter.current().add(request) { error in
                                                                                                                                    if let error = error {
                                                                                                                                        // Handle the error
                                                                                                                                        print("Error adding notification1 request:", error)
                                                                                                                                    } else {
                                                                                                                                        // Notification request added successfully
                                                                                                                                        print("Notification1 request added successfully")
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                    self.sendPushNotification(body: "Hey! \(fullnameU) is running low on supply for \(med). \(pillsleft)\(secondunit) left.", subtitle: "Refill Medications", phoneId: apn)
                                                                                                                } else {
                                                                                                                    // Handle the case where image URL is invalid
                                                                                                                    print ("image URL is invalid")
                                                                                                                }
                                                                                                            }
                                                                                                            
                                                                                                            
                                                                                                        }
                                                                                                        print("Medicine updated successfully")
                                                                                                        /*
                                                                                                        if repeats == true
                                                                                                        {
                                                                                                            self.sendPushNotification(body: "\(fullnameU) has confirmed thier \(self.dateToString(count:remind)) dose for \(med). \(pillsleft)\(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            self.sendPushNotification(body: "\(fullnameU) has confirmed thier \(self.dateToString(count:remind)) dose for \(med) late. \(pillsleft)\(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                                                                        }
                                                                                                         */
                                                                                                        
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        if pillsleft - 1 < 0
                                                                                        {
                                                                                            let content = UNMutableNotificationContent()
                                                                                            content.title = "PillNotify"
                                                                                            content.subtitle = "Refill"
                                                                                            content.body = "Sorry, you don't have enough supply to confirm \(med). \(pillsleft)\(secondunit) left."
                                                                                            content.sound = UNNotificationSound.default
                                                                                            content.badge = 1
                                                                                            
                                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                            
                                                                                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                            
                                                                                            UNUserNotificationCenter.current().add(request) { error in
                                                                                                if let error = error {
                                                                                                    // Handle the error
                                                                                                    print("Error adding notification1 request:", error)
                                                                                                } else {
                                                                                                    // Notification request added successfully
                                                                                                    print("Notification1 request added successfully")
                                                                                                }
                                                                                            }
                                                                                            self.sendPushNotification(body: "Hey! it looks like \(fullnameU) doesn't have enough supply for \(med) to confirm at \(self.dateToString(count:remind)). Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            if updateReportsCount == false && repeats == true
                                                                                            {
                                                                                                self.updateReports(med: med, date: confirmingDate)
                                                                                                updateReportsCount = true
                                                                                            }
                                                                                            
                                                                                            pillsleft -= 1
                                                                                            count += 1
                                                                                            let medicineRef = database.child("medicines").child(user).child(med)
                                                                                            let updatedData: [String: Any] = [
                                                                                                "remaining": pillsleft,
                                                                                                "count": count,
                                                                                                "lastconfirm": self.dateToString(count: remind)
                                                                                            ]
                                                                                            
                                                                                            
                                                                                            
                                                                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                                                                if let error = error {
                                                                                                    // Handle the error case
                                                                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                                                                } else {
                                                                                                    
                                                                                                    if (pillsleft / amount >= 0) && (pillsleft / amount <= 10)
                                                                                                    {
                                                                                                        let picname = med.replacingOccurrences(of: " ", with: "-")
                                                                                                        let imageDatabase = Storage.storage().reference().child("images").child(user).child("\(picname).jpg")
                                                                                                        
                                                                                                        imageDatabase.downloadURL { (url, error) in
                                                                                                            if let error = error {
                                                                                                                // Handle the error case
                                                                                                                print("Failed to retrieve download URL: \(error.localizedDescription)")
                                                                                                                return
                                                                                                            }
                                                                                                            
                                                                                                            guard let downloadURL = url else {
                                                                                                                // Handle the case where download URL is nil
                                                                                                                return
                                                                                                            }
                                                                                                            
                                                                                                            let imageUrlString = downloadURL.absoluteString
                                                                                                            
                                                                                                            if let imageUrl = URL(string: imageUrlString) {
                                                                                                                DispatchQueue.global().async {
                                                                                                                    if let imageData = try? Data(contentsOf: imageUrl),
                                                                                                                       let uiImage = UIImage(data: imageData) {
                                                                                                                        DispatchQueue.main.async {
                                                                                                                            // Update your UI with the loaded image
                                                                                                                            inputImage = uiImage
                                                                                                                            let content = UNMutableNotificationContent()
                                                                                                                            content.title = "PillNotify"
                                                                                                                            content.subtitle = "Refill"
                                                                                                                            content.body = "Hi, \(fullnameU), you're supply for \(med) is getting low. \(pillsleft)\(secondunit) left."
                                                                                                                            content.sound = UNNotificationSound.default
                                                                                                                            content.badge = 1
                                                                                                                            
                                                                                                                            // Get the UIImage from your source, e.g. the camera roll
                                                                                                                            let image = inputImage
                                                                                                                            let uuid = UUID().uuidString
                                                                                                                            let filename = "\(uuid).jpg"
                                                                                                                            
                                                                                                                            // Compress the image data to reduce the file size
                                                                                                                            if let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                                                                                                                                
                                                                                                                                // Create a URL for the compressed image data
                                                                                                                                let temporaryDirectory = NSTemporaryDirectory()
                                                                                                                                let temporaryFileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(filename)
                                                                                                                                try? compressedImageData.write(to: temporaryFileURL, options: [.atomic])
                                                                                                                                
                                                                                                                                // Create a UNNotificationAttachment with the image URL
                                                                                                                                do {
                                                                                                                                    let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: temporaryFileURL, options: nil)
                                                                                                                                    content.attachments = [attachment]
                                                                                                                                } catch {
                                                                                                                                    print("Error creating notification attachment: \(error.localizedDescription)")
                                                                                                                                }
                                                                                                                            } else {
                                                                                                                                print("Error compressing image data")
                                                                                                                            }
                                                                                                                            
                                                                                                                            
                                                                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                                                            
                                                                                                                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                                                            
                                                                                                                            UNUserNotificationCenter.current().add(request) { error in
                                                                                                                                if let error = error {
                                                                                                                                    // Handle the error
                                                                                                                                    print("Error adding notification1 request:", error)
                                                                                                                                } else {
                                                                                                                                    // Notification request added successfully
                                                                                                                                    print("Notification1 request added successfully")
                                                                                                                                }
                                                                                                                            }
                                                                                                                            
                                                                                                                            
                                                                                                                            // ...
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
                                                                                                                self.sendPushNotification(body: "Hey! \(fullnameU) is running low on supply for \(med). \(pillsleft)\(secondunit) left.", subtitle: "Refill Medications", phoneId: apn)
                                                                                                            } else {
                                                                                                                // Handle the case where image URL is invalid
                                                                                                                print ("image URL is invalid")
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        
                                                                                                    }
                                                                                                    print("Medicine updated successfully")
                                                                                                    /*
                                                                                                    if repeats == true
                                                                                                    {
                                                                                                        self.sendPushNotification(body: "\(fullnameU) has confirmed thier \(self.dateToString(count:remind)) dose for \(med). \(pillsleft)\(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        self.sendPushNotification(body: "\(fullnameU) has confirmed thier \(self.dateToString(count:remind)) dose for \(med) late. \(pillsleft)\(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                                                                    }
                                                                                                     */
                                                                                                    
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        
                                                                                    }
                                                                                }
                                                                                
                                                                                
                                                                            }
                                                                            else
                                                                            {
                                                                                let content = UNMutableNotificationContent()
                                                                                content.title = "PillNotify"
                                                                                content.subtitle = "Confirmation Error"
                                                                                content.body = "You have either confirmed \(med) today already, or you are not scheduled to take any meds today"
                                                                                content.sound = UNNotificationSound.default
                                                                                content.badge = 1
                                                                                
                                                                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                                
                                                                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                                
                                                                                UNUserNotificationCenter.current().add(request) { error in
                                                                                    if let error = error {
                                                                                        // Handle the error
                                                                                        print("Error adding notification1 request:", error)
                                                                                    } else {
                                                                                        // Notification request added successfully
                                                                                        print("Notification1 request added successfully")
                                                                                    }
                                                                                }
                                                                            }
                                                                        } else {
                                                                            // Medicine with the given name and username does not exist
                                                                            print("Medicine not found or does not belong to the user.")
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                else
                                                                {
                                                                    let content = UNMutableNotificationContent()
                                                                    content.title = "PillNotify"
                                                                    content.subtitle = "Med Not Found"
                                                                    content.body = "Sorry, couldn't find \(med). Make sure Siri's spelling matches what is inputted in the app. If not, change the name in the app to match how Siri spells it."
                                                                    content.sound = UNNotificationSound.default
                                                                    content.badge = 1
                                                                    
                                                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                                    
                                                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                                    
                                                                    UNUserNotificationCenter.current().add(request) { error in
                                                                        if let error = error {
                                                                            // Handle the error
                                                                            print("Error adding notification1 request:", error)
                                                                        } else {
                                                                            // Notification request added successfully
                                                                            print("Notification1 request added successfully")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                        } else {
                                                            print("No data found in users node")
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    let content = UNMutableNotificationContent()
                                                    content.title = "PillNotify"
                                                    content.subtitle = "PillNotifyPro Required"
                                                    content.body = "Sorry, you cannot confirm \(med). Your caretaker needs to purchase PillNotifyPro."
                                                    content.sound = UNNotificationSound.default
                                                    content.badge = 1
                                                    
                                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                                    
                                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                                    
                                                    UNUserNotificationCenter.current().add(request) { error in
                                                        if let error = error {
                                                            // Handle the error
                                                            print("Error adding notification1 request:", error)
                                                        } else {
                                                            // Notification request added successfully
                                                            print("Notification1 request added successfully")
                                                        }
                                                    }
                                                }
                                            }
                                            else {
                                                print("Paid value is not a boolean")
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                else
                                {
                                    let content = UNMutableNotificationContent()
                                    content.title = "PillNotify"
                                    content.subtitle = "Caretaker Required"
                                    content.body = "Sorry, you cannot confirm \(med). You need a caretaker with the PillNotifyPro plan."
                                    content.sound = UNNotificationSound.default
                                    content.badge = 1
                                    
                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                    
                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                    
                                    UNUserNotificationCenter.current().add(request) { error in
                                        if let error = error {
                                            // Handle the error
                                            print("Error adding notification1 request:", error)
                                        } else {
                                            // Notification request added successfully
                                            print("Notification1 request added successfully")
                                        }
                                    }

                                }
                            }
                        }
                        
                    }
                }
                
                
            }
            else
            {
                let content = UNMutableNotificationContent()
                content.title = "PillNotify"
                content.subtitle = "Siri Permissions"
                content.body = "Sorry, you have to be logged in as a user to use siri shortcuts."
                content.sound = UNNotificationSound.default
                content.badge = 1
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        // Handle the error
                        print("Error adding notification1 request:", error)
                    } else {
                        // Notification request added successfully
                        print("Notification1 request added successfully")
                    }
                }
            }
        }
    }
    
    // This method updates the reports database with the dates that the medicine taker has missed
    // for exmaple, lets say a user misses a dose today, then it will update the database to include today as a day
    // that the user missed their dose
    func updateReports(med: String, date: [Date])
    {
        let database = Database.database().reference()
        let calendar = Calendar.current
        let currentDate = Date()
        
        var stringDates: [String] = []
        
        for i in date
        {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            stringDates.append(dateFormatter2.string(from: i))
        }
        
        // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
        let currentWeekday = calendar.component(.weekday, from: currentDate)

        // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
        let daysToSubtract = (currentWeekday + 6) % 7

        // Create date components with the calculated days to subtract
        var dateComponents = DateComponents()
        dateComponents.day = -daysToSubtract

        // Get the last Sunday by subtracting the date components from the current date
        if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {
            // `lastSunday` will now contain the most recent Sunday from the current date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: lastSunday)
            let id = sharedDefaults?.string(forKey: ShareDefaults.Keys.username)
            
            var missedCount = 0
            var confirmedCount = 0
            var missedDates: [String] = []
            var confirmedDates: [String] = []
            

            let reportsReference = database.child("reports").child(id!).child(med).child(formattedDate)
            reportsReference.observeSingleEvent(of: .value) { snapshot in
                guard let reportData = snapshot.value as? [String: Any] else {
                    let reportsReference2 = database.child("reports").child(id!).child(med).child(formattedDate)
                    
                    let reports: [String: Any] = ["confirmed": stringDates.count, "missed":0, "misseddates": ["None"], "seniordates": stringDates]
                    
                    let updatedData: [String: Any] = reports
                    
                    reportsReference2.setValue(updatedData) { error, _ in
                        if let error = error {
                            // Handle the error case
                            print("Failed to create object: \(error.localizedDescription)")
                            // Handle the error and show appropriate alert
                        } else {
                            print("Object created successfully")
                        }
                    }
                    return
                }
                
                if let datesS = reportData["seniordates"] as? [String] {
                    confirmedDates = datesS
                    for i in stringDates
                    {
                        confirmedDates.append(i)
                    }
                }
                if let datesM = reportData["misseddates"] as? [String] {
                    missedDates = datesM
                }
                
                if let confirmed = reportData["confirmed"] as? Int {
                    confirmedCount = confirmed
                }
                if let missed = reportData["missed"] as? Int {
                    missedCount = missed
                }
                
                    let updatedData: [String: Any] = [
                        "confirmed": confirmedCount + stringDates.count,
                        "missed": missedCount,
                        "misseddates": missedDates,
                        "seniordates": confirmedDates
                    ]
                    
                    reportsReference.updateChildValues(updatedData) { error, _ in
                        if let error = error {
                            // Handle the error case
                            print("Failed to update reports: \(error.localizedDescription)")
                        }
                    }

            }
        }
    }
    
    // This method converts a Date object to a string using a DateFormatter in the format yyyy-mm-dd hh:mm:ss
    func dateToString(count: Date) -> String
    {
        let date = count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Choose a format that suits your needs
        return dateFormatter.string(from: date)
    }
    
    // This method iterates through all the medication of a logged in user and gets all the times the user has a medicine
    // scheduled for and calls the method that schedules a notification at that time.
    func sendMessage()
    {
        let database = Database.database().reference()
        if let username = sharedDefaults?.string(forKey: ShareDefaults.Keys.username) {
            
            var count = 1
            let medicineDatabase = database.child("medicines").child(username)
                
            medicineDatabase.observeSingleEvent(of: .value) { [self] snapshot in
                if snapshot.exists() {
                    guard let medicineData = snapshot.value as? [String:[String: Any]] else {
                        return
                    }
                    
                    for (med, medData) in medicineData
                    {
                        if let reminders = medData["reminders"] as? [String: [String]] {
                            for (day, times) in reminders {
                                count = 1
                                for time in times {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    if let date = dateFormatter.date(from: time) {
                                        // Set the timeOfDay value for the specific day and count
                                        switch day {
                                        case "Monday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 2)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 2)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 2)
                                            }
                                        case "Tuesday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 3)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 3)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 3)
                                            }
                                        case "Wednesday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 4)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 4)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 4)
                                            }
                                        case "Thursday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 5)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 5)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 5)
                                            }
                                        case "Friday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 6)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 6)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 6)
                                            }
                                        case "Saturday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 7)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 7)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 7)
                                            }
                                        case "Sunday":
                                            if count == 1 {
                                                scheduleNotification(med: med, user: username, day: date, week: 1)
                                                count += 1
                                            } else if count == 2 {
                                                scheduleNotification(med: med, user: username, day: date, week: 1)
                                                count += 1
                                            } else if count == 3 {
                                                scheduleNotification(med: med, user: username, day: date, week: 1)
                                            }
                                        default:
                                            break
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    
                } else {
                    print("No data found in medicines node for the user: \(username)")
                }
            }
        }
    }
    
    // This method logs a user in when they want to view their meds with siri
    func viewMedsLogin(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false) // Call completion block with false to indicate login failure
            } else {
                print("logged in with \(email) \(password)")
                completion(true) // Call completion block with true to indicate login success
            }
        }
    }

    // this method logs a user in when they want to confirm their meds
    func confirmMedsLogin(email: String, password: String, medication: String)
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
            else
            {
                print("logged in with \(email) \(password)")
                self.getAuthenticatedUserUID(medication: medication)
                
            }
        }
    }
    
    // This method retrives the UserID of the logged in user and then check what med the user want to delete
    // and deletes it from Firebase. Siri must get the correct spelling of how the user inputted in the app. Otherwise wont work.
    // If user says a phrase with "All" (case-insensitve) then it will confirm all meds possible.
    func getAuthenticatedUserUID(medication: String) {
        let database = Database.database().reference()
        if let currentUser = Auth.auth().currentUser {
            if medication.localizedCaseInsensitiveContains("All")
            {
                let medicineDatabase = database.child("medicines").child(currentUser.uid)
                let query = medicineDatabase.queryOrdered(byChild: "username").queryEqual(toValue: currentUser.uid)
                
                query.observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        guard let usersData = snapshot.value as? [String: [String: Any]] else {
                            return
                        }
                        
                        for (_, usersData) in usersData {
                            if let med = usersData["medname"] as? String {
                                self.confirmMed(med: med)
                            }
                        }
                    }
                }
            }
            else
            {
                self.confirmMed(med: medication)
            }
        } else {
            print("No user is currently logged in.")
            
        }
    }
    
    // this method logs a user in when they want to delete their meds
    func deleteMedsLogin(email: String, password: String, medication: String)
    {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if error != nil
            {
                print (error!.localizedDescription)
            }
            else
            {
                print("logged in with \(email) \(password)")
                self.deleteItems(med: medication)
            }
        }
    }
    
    // This method retrives the the meds that the logged in user has created. If there are no meds, it returns no meds.
    // If user is not logged in, it send a notification to log in as a medicine taker that has a caretaker with PillNotifyPro
    func getMedsString(completion: @escaping (String) -> Void) {
        // Retrieve the value previously set in the main app
        if let _ = Auth.auth().currentUser {
            if let username = sharedDefaults?.string(forKey: ShareDefaults.Keys.username) {
                var meds = ""
                let database = Database.database().reference()
                let medicinesReference = database.child("medicines").child(username)
                
                medicinesReference.observeSingleEvent(of: .value) { snapshot in
                    guard let medicinesData = snapshot.value as? [String: [String: Any]] else {
                        // Handle data retrieval error
                        completion("\nno meds") // Return default value when there's an error
                        return
                    }
                    
                    
                    for medicineData in medicinesData.values { // Use 'values' to loop through the values in the dictionary
                        if let medName = medicineData["medname"] as? String {
                            meds += medName // Append the medication name to the 'meds' string
                            
                            if let medColor = medicineData["medcolor"] as? String {
                                meds += " - Color: \(medColor)," // Append medication color if available
                            }
                            if let medShape = medicineData["medshape"] as? String {
                                meds += " Shape: \(medShape)," // Append medication shape if available
                            }
                            if let dosage = medicineData["dosage"] as? Int {
                                meds += " Dosage: \(dosage)" // Append medication dosage if available
                            }
                            if let unit = medicineData["unit"] as? String {
                                meds += "\(unit)," // Append medication unit if available
                            }
                            if let remaining = medicineData["remaining"] as? Int {
                                meds += " Remaining: \(remaining)" // Append remaining count if available
                            }
                            if let secondunit = medicineData["secondunit"] as? String {
                                meds += "\(secondunit)" // Append medication unit if available
                            }
                        }
                        meds += "\n" // Add a newline after processing each medication data
                    }
                    // Call the completion closure with the retrieved meds string
                    completion(meds)
                }
            }
            else
            {
                completion("\nno meds") // Return default value when there's no username
                let content = UNMutableNotificationContent()
                content.title = "PillNotify"
                content.subtitle = "Siri Permissions"
                content.body = "Sorry, you have to be logged in as a user to use siri shortcuts."
                content.sound = UNNotificationSound.default
                content.badge = 1
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        // Handle the error
                        print("Error adding notification1 request:", error)
                    } else {
                        // Notification request added successfully
                        print("Notification1 request added successfully")
                    }
                }
            }
        }

    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}

extension IntentViewController: INUIHostedViewSiriProviding {
    var displaysMessage: Bool {
        os_log("TK421: %{public}s", "\(#function)")
        return true
    }
    
    var displaysMap: Bool {
        os_log("TK421: %{public}s", "\(#function)")
        return false
    }
    
    var displaysPaymentTransaction: Bool {
        os_log("TK421: %{public}s", "\(#function)")
        return false
    }
}
