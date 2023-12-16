//
//  CaretakerMedView.swift
//  PillNotify
//
//  Created by Amogh Bantwal on 6/3/23.
//

import SwiftUI
import MessageUI
import StoreKit
import UserNotifications
import Combine
import FirebaseDatabase
import FirebaseStorage
import StoreKit
import FirebaseAuth
import BackgroundTasks


// This class is the payment gateway class that allows a cartaker to purchase the PillNotifyPro
class SKPaymentObserver: NSObject, SKPaymentTransactionObserver {
    // This method purchases the product from the app store connect via the SKPaymentQueue
    // If successful, it updates the firebase DB that the caretaker has paid
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Transaction Successful")
                updatePaid()
                UserDefaults.standard.set(true, forKey: "purchased")
                
            } else if transaction.transactionState == .failed {
                print("Transaction Failed")
            }
        }
    }
    
    //This method updates the firebase DB that the caretaker has paid and will persist when they
    // close the app so the app doesnt show the Purchase Pro screen.
    func updatePaid()
    {
        let database = Database.database().reference()
        let id = UserDefaults.standard.string(forKey: "userid") ?? "NO ID"
        let caretakerDatabase = database.child("caretaker").child(id)
        let updatedData: [String: Any] = [
            "paid": true
        ]
        
        caretakerDatabase.updateChildValues(updatedData) { error, _ in
            if let error = error {
                // Handle the error case
                print("Failed to update paid: \(error.localizedDescription)")
            }
            else
            {
                print("caretaker has paid")
            }
        }
        
    }
}

// This view is the primary screen of the tab view that displays the medicines of the medicine taker to the caretaker
struct CaretakerMedView: View{
    private let productID = "com.amoghbantwal.PillAlertify.app.PillNotifyPro"
    private let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private let database = Database.database().reference()
    
    @State private var medicineRecords: [String: [String: Any]] = [:]
    @State private var name = ""
    @State private var previousname = ""
    @State private var color = ""
    @State private var shape = ""
    @State private var amount = 0
    private let units: [String] = ["IU", "mcL", "mL", "mcg", "mg", "g", "tbsp", "oz", "fl oz", "tsp", "puffs", "pills", "injections", "gummies"]
    @State private var unit = "pills"
    @State private var secondunit = "pills"
    @State private var pillsleft = 0
    
    @State private var fullname = ""
    @State private var apn = ""
    @State private var caretakerapn = ""
    @State private var count = 0
    @State private var changeCount = false
    
    @State private var timeOfDay1M = Date()
    @State private var timeOfDay1Tu = Date()
    @State private var timeOfDay1W = Date()
    @State private var timeOfDay1Th = Date()
    @State private var timeOfDay1F = Date()
    @State private var timeOfDay1Sa = Date()
    @State private var timeOfDay1Su = Date()

    @State private var timeOfDay2M = Date()
    @State private var timeOfDay2Tu = Date()
    @State private var timeOfDay2W = Date()
    @State private var timeOfDay2Th = Date()
    @State private var timeOfDay2F = Date()
    @State private var timeOfDay2Sa = Date()
    @State private var timeOfDay2Su = Date()

    @State private var timeOfDay3M = Date()
    @State private var timeOfDay3Tu = Date()
    @State private var timeOfDay3W = Date()
    @State private var timeOfDay3Th = Date()
    @State private var timeOfDay3F = Date()
    @State private var timeOfDay3Sa = Date()
    @State private var timeOfDay3Su = Date()

    @State private var timesADayM = 1
    @State private var timesADayTu = 1
    @State private var timesADayW = 1
    @State private var timesADayTh = 1
    @State private var timesADayF = 1
    @State private var timesADaySa = 1
    @State private var timesADaySu = 1
    
    @State private var UID = ""
    @State private var selectedDays: [String] = []
    @State private var searchText = ""
    @State private var medicineSheet = false
    
    private var isAddButtonDisabled: Bool
    {
        [name, color, shape, unit, secondunit].contains(where:\.isEmpty) || amount <= 0 || pillsleft <= 0 || selectedDays.count == 0
    }
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    
    var body: some View {
        if false//!(UserDefaults.standard.bool(forKey: "purchased"))
        {
            if networkMonitor.isConnected
            {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0/255, green: 47/255, blue: 100/255),
                            Color(red: 0/255, green: 47/255, blue: 100/255),
                            Color.white,
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .foregroundStyle(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255), .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 1000, height: 400)
                        .rotationEffect(.degrees(135))
                        .offset(y: -350)
                    
                    VStack(spacing: 20) {
                        Text("PillNotifyPro")
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 40))
                            .shadow(color: .black, radius: 5)
                        

                        Button(action: {
                            purchaseProduct()
                            
                        }, label:{
                            VStack {
                                HStack {
                                    Text("$1.99")
                                        .frame(width: 100, height: 50) // Adjust the width as needed
                                    Text("Unlock exclusive med management features!")
                                        .frame(width: 200, height: 50) // Adjust the width as needed
                                }
                            }
                            .padding()
                        })
                        .foregroundColor(.white)
                        .background(.green)
                        .cornerRadius(15.0)
                        .shadow(color: .white, radius: 5)
                        
                        Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundStyle(.white)
                            .padding(.bottom, 20)
                        
                        Text("\nAnalytic reports")
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 15))
                            .shadow(color: .black, radius: 5)
                        Text("\nAbility to send reports to doctor")
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 15))
                            .shadow(color: .black, radius: 5)
                        Text("\nAbility to view scheduled medications")
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 15))
                            .shadow(color: .black, radius: 5)
                        Text("\nReceive notifications when user confirms or misses a dose")
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 15))
                            .shadow(color: .black, radius: 5)
                        Text("\nEnable siri shortcuts for medicine taker to confirm, view, and delete medicines")
                            .italic()
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 15))
                            .shadow(color: .black, radius: 5)
                        
                        
                    }
                    .frame(width: 350)
                }
                .ignoresSafeArea()
                .onAppear{
                    checkPaid()
                    SKPaymentQueue.default().add(SKPaymentObserver())
                }
            }
            else
            {
                LoadingView()
                    .navigationBarBackButtonHidden()
            }
            
        }
        else
        {
            ScrollView   
            {
                LazyVStack(spacing: 20) {
                    Text("Medications")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 40))
                        .shadow(color: .black, radius: 5)
                    
                    TextField("Search", text: $searchText)
                        .autocorrectionDisabled(true)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .background(Capsule().fill(.white))
                        .foregroundColor(Color(red: 0/255, green: 47/255, blue: 100/255))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                        .preferredColorScheme(.light)
                    
                    ForEach(medicineRecords.sorted(by: { $0.key < $1.key }), id: \.key) { medicineId, medicineData in
                        if let medName = medicineData["medname"] as? String,
                           let medColor = medicineData["medcolor"] as? String,
                           let medShape = medicineData["medshape"] as? String,
                           let medAmount = medicineData["dosage"] as? Int,
                           let medReminaing = medicineData["remaining"] as? Int,
                           let unit = medicineData["unit"] as? String,
                           let secondunit = medicineData["secondunit"] as? String
                        {
                            if searchText.isEmpty || medName.localizedCaseInsensitiveContains(searchText)
                            {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 160)
                                    .foregroundStyle(.white)
                                    .cornerRadius(15.0)
                                    .padding(.bottom, 20)
                                    .shadow(color: .black, radius: 5)
                                    .opacity(medicineSheet ? 0.5 : 1)
                                    .onTapGesture {
                                        medicineSheet = true
                                        DispatchQueue.global().async {
                                            fillSheet(medname: medName)
                                        }
                                    }
                                    .overlay(
                                        HStack {
                                            Image(systemName: "pill.fill")
                                                .font(.system(size: 45))
                                                .padding(.trailing, 25)
                                                .padding(.bottom, 20)
                                                .foregroundStyle(Color(red: 0/255, green: 47/255, blue: 100/255))
                                                .shadow(color: .gray, radius: 5)
                                            Rectangle()
                                                .frame(width: 1, height: 140)
                                                .foregroundStyle(.black)
                                                .cornerRadius(15.0)
                                                .padding(.bottom, 15)
                                                .padding(.trailing, 20)
                                            
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text(medName)
                                                        .foregroundStyle(Color(red: 0/255, green: 47/255, blue: 100/255))
                                                        .font(.custom("AmericanTypewriter-Bold", size: 18))
                                                        .shadow(color: .white, radius: 5)
                                                    Image(systemName: "pencil")
                                                        .foregroundStyle(Color(red: 0/255, green: 47/255, blue: 100/255))
                                                }
                                                .font(.headline)
                                                .sheet(isPresented: $medicineSheet) 
                                                {
                                                    NavigationStack
                                                    {
                                                        ZStack {
                                                            Form {
                                                                Section(header: Text("Medicine Name")) {
                                                                    TextField("Medicine Name", text: $name)
                                                                        .autocorrectionDisabled(true)
                                                                        .textFieldStyle(.roundedBorder)
                                                                        .disabled(true)
                                                                        .foregroundColor(.red)
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Medicine Color")) {
                                                                    TextField("Medicine Color", text: $color)
                                                                        .autocorrectionDisabled(true)
                                                                        .textFieldStyle(.roundedBorder)
                                                                        .disabled(true)
                                                                        .foregroundColor(.red)
                                                                    
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Medicine Shape"))
                                                                {
                                                                    TextField("Medicine Shape", text: $shape)
                                                                        .autocorrectionDisabled(true)
                                                                        .textFieldStyle(.roundedBorder)
                                                                        .disabled(true)
                                                                        .foregroundColor(.red)
                                                                    
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Dosage Amount"))
                                                                {
                                                                    TextField("Dosage Amount", value: $amount, formatter: NumberFormatter())
                                                                        .textFieldStyle(.roundedBorder)
                                                                        .disabled(true)
                                                                        .foregroundColor(.red)
                                                                    
                                                                    Picker("Measurement Unit", selection: $unit)
                                                                    {
                                                                        ForEach(units, id:\.self)
                                                                        {
                                                                            Text("\($0)").tag("\($0)")
                                                                        }
                                                                    }
                                                                    .disabled(true)
                                                                    .foregroundColor(.red)
                                                                }
                                                                
                                                                
                                                                Section(header: Text("Medicine Supply Remaining"))
                                                                {
                                                                    TextField("Dosage Remaining", value: $pillsleft, formatter: NumberFormatter())
                                                                        .textFieldStyle(.roundedBorder)
                                                                    
                                                                    Picker("Measurement Unit", selection: $secondunit)
                                                                    {
                                                                        ForEach([unit, "pills", "puffs", "injections", "gummies"], id:\.self)
                                                                        {
                                                                            Text("\($0)").tag("\($0)")
                                                                        }
                                                                    }
                                                                    .disabled(true)
                                                                    .foregroundColor(.red)
                                                                    
                                                                    
                                                                }
                                                                
                                                                
                                                                Section(header: Text("Days"))
                                                                {
                                                                    List {
                                                                        ForEach(days, id: \.self) { day in
                                                                            MultipleSelectionRow(title: day, isSelected: self.selectedDays.contains(day)) {
                                                                                if let index = self.selectedDays.firstIndex(of: day) {
                                                                                    self.selectedDays.remove(at: index)
                                                                                } else {
                                                                                    self.selectedDays.append(day)
                                                                                }
                                                                            }
                                                                            .disabled(true)
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                List
                                                                {
                                                                    ForEach(Array(selectedDays), id: \.self) { day in
                                                                        SetTimesView(timeDay1M: $timeOfDay1M, timeDay1Tu: $timeOfDay1Tu, timeDay1W: $timeOfDay1W, timeDay1Th: $timeOfDay1Th, timeDay1F: $timeOfDay1F, timeDay1Sa: $timeOfDay1Sa, timeDay1Su: $timeOfDay1Su, timeDay2M: $timeOfDay2M, timeDay2Tu: $timeOfDay2Tu, timeDay2W: $timeOfDay2W, timeDay2Th: $timeOfDay2Th, timeDay2F: $timeOfDay2F, timeDay2Sa: $timeOfDay2Sa, timeDay2Su: $timeOfDay2Su, timeDay3M: $timeOfDay3M, timeDay3Tu: $timeOfDay3Tu, timeDay3W: $timeOfDay3W, timeDay3Th: $timeOfDay3Th, timeDay3F: $timeOfDay3F, timeDay3Sa: $timeOfDay3Sa, timeDay3Su: $timeOfDay3Su, timesDayM: $timesADayM, timesDayTu: $timesADayTu, timesDayW: $timesADayW, timesDayTh: $timesADayTh, timesDayF: $timesADayF, timesDaySa: $timesADaySa, timesDaySu: $timesADaySu, days: day)
                                                                            .disabled(true)
                                                                        
                                                                    }
                                                                }
                                                                
                                                                
                                                                Button(action: {
                                                                    updateMedicine()
                                                                }, label: {
                                                                    Text("Update Medication")
                                                                })
                                                                .disabled(isAddButtonDisabled)
                                                            }
                                                            .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                                                            .toolbarBackground(.visible, for: .navigationBar)
                                                            .toolbarColorScheme(.dark)
                                                            .navigationBarItems(
                                                                trailing: Button(action: {
                                                                    medicineSheet = false
                                                                }) {
                                                                    Text("Dismiss").bold()
                                                                }
                                                            )
                                                            .navigationTitle("Medication Info")
                                                            .preferredColorScheme(.light)
                                                            
                                                        }
                                                    }
                                                }
                                                Text("Shape: \(medShape)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.gray)
                                                Text("Color: \(medColor)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.gray)
                                                Text("Dosage: \(medAmount) \(unit)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.gray)
                                                Text("Medicine Remaining: \(medReminaing) \(secondunit)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.gray)
                                                    .padding(.bottom, 20)
                                            }
                                        }
                                    )
                                
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    fetchMedicineRecords()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    checkLatest()
                    if let email = UserDefaults.standard.string(forKey: "email") {
                        if let password = UserDefaults.standard.string(forKey: "pass") {
                            login(email: email, password: password)
                            checkPaid()
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
    
    // This method turns a Date object into a string formatted yyy-mm-dd hh:mm:ss
    func dateToString(count: Date) -> String
    {
        let date = count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Choose a format that suits your needs
        return dateFormatter.string(from: date)
    }
    
    // This method checks if the caretaker has paid for the premium version of PillNotifyPro
    // If so, it will display the meds of the caretaker, else it will show the purchase Pro screen
    func checkPaid() {
        let username = UserDefaults.standard.string(forKey: "userid") ?? "NO ID"
        let paidReference = database.child("caretaker").child(username).child("paid")
        
        paidReference.observeSingleEvent(of: .value) { (snapshot, error) in
            if let error = error {
                print("Error getting paid value: \(error)")
            } else {
                if let paidValue = snapshot.value as? Bool {
                    UserDefaults.standard.set(paidValue, forKey: "purchased")
                }
            }
        }
    }
    
    // This method purchases the Pro version for the caretaker and triggers the PaymentQueue class above
    func purchaseProduct() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            
        } else {
            print("Caretaker unable to make payments")
        }
    }
    
    // This method logs the user in with the saved email and password in the UserDeafults
    // This makes sure that they can make state changes to the database
    // If successful, it automatically calls the getAPN() method
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
    
    // This method is used to place the caretaker's APNS token from Firebase in their respective
    // medicine taker's APNS key in the database
    func getAPN()
    {
        let apnsToken = UserDefaults.standard.string(forKey: "apnsToken") ?? "No APNS"
        let accountID = UserDefaults.standard.string(forKey: "userid") ?? "No ID"

        let caretakerDatabase = database.child("caretaker").child(accountID)
        var UID = ""

        caretakerDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
            if caretakerSnapshot.exists() {
                guard let caretakerData = caretakerSnapshot.value as? [String: Any] else {
                    return
                }
                
                if let userAccountID = caretakerData["caretakeeID"] as? String {
                    
                    UID = userAccountID
                    
                    let apnsRef = database.child("caretaker").child(accountID).child("apnsid")

                    // Observe the value at the accountid location
                    apnsRef.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            // Retrieve the accountid value
                            if let accountIDValue = snapshot.value as? String {
                                if accountIDValue == "None"
                                {
                                    let userDatabase = database.child("users").child(UID)
                                    userDatabase.observeSingleEvent(of: .value) { userSnapshot in
                                        if userSnapshot.exists() {
                                            guard let switchAPNData = userSnapshot.value as? [String: Any] else {
                                                return
                                            }
                                            
                                            if let apn = switchAPNData["apnsid"] as? String {
                                                let updatedData: [String: Any] = [
                                                    "apnsid": apnsToken,
                                                    // Add other fields to be updated
                                                ]
                                                
                                                let caretakerUpdatedData: [String: Any] = [
                                                    "apnsid": apn,
                                                    // Add other fields to be updated
                                                ]
                                                
                                                caretakerDatabase.updateChildValues(caretakerUpdatedData) { error, _ in
                                                    if let error = error {
                                                        // Handle the error case
                                                        print("Failed to update user data: \(error.localizedDescription)")
                                                    } else {
                                                        userDatabase.updateChildValues(updatedData) { error, _ in
                                                            if let error = error {
                                                                // Handle the error case
                                                                print("Failed to update user data: \(error.localizedDescription)")
                                                            } else {
                                                                // User data updated successfully
                                                                print("User and caretaker data updated successfully")
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
                                    let userDatabase = database.child("users").child(UID)
                                    userDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
                                        if caretakerSnapshot.exists() {
                                            let updatedData: [String: Any] = [
                                                "apnsid": apnsToken,
                                                // Add other fields to be updated
                                            ]
                                            
                                            userDatabase.updateChildValues(updatedData) { error, _ in
                                                if let error = error {
                                                    // Handle the error case
                                                    print("Failed to update user data: \(error.localizedDescription)")
                                                } else {
                                                    // User data updated successfully
                                                    print("User data updated successfully")
                                                }
                                            }
                                        }

                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            } else {
                print("No data found in users node")
            }
        }
    }
    
    // This method retrieves the userID of the caretaker from firebase and assigns it to a variable
    func getUID()
    {
        let accountID = UserDefaults.standard.string(forKey: "userid") ?? "NO"

        let caretakerDatabase = database.child("caretaker").child(accountID)

        caretakerDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
            if caretakerSnapshot.exists() {
                guard let caretakerData = caretakerSnapshot.value as? [String: Any] else {
                    return
                }
                
                if let userAccountID = caretakerData["caretakeeID"] as? String{
                    
                    UID = userAccountID

                }
                
            } else {
                print("No data found in caretaker node")
            }
            
        }
    }
    
    // This method is a daily reminder to the caretaker to open the app because currently the app
    // does not automaticlly run in the background to check if the medicine taker has confirmed their dose.
    // So the only way to check if the medicine taker has confirmed is to remind the caretaker to open the app
    // after 45 minutes of each dosage time the medicine taker inputed. For example: if the user schedules to take
    // tylenol at 10PM, then the caretaker will get a message at 10:45 reminding them to open the app.
    func checkLatest()
    {
        if let userID = UserDefaults.standard.object(forKey: "userid") as? String {
            
            let caretakerDatabase = database.child("caretaker").child(userID)
            var dates: [Int: [Int: Date]] = [:]
            var idcount = 1 // allows dupicates in the dates dictionary for days with same times
            var count = 1
            var latestDate = Calendar.current.startOfDay(for: Date())
            caretakerDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
                if caretakerSnapshot.exists() {
                    guard let caretakerData = caretakerSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let id = caretakerData["caretakeeID"] as? String
                    {
                        let medicinesReference = database.child("medicines").child(id)
                        medicinesReference.observeSingleEvent(of: .value) { snapshot in
                            guard let medicineData = snapshot.value as? [String: [String: Any]] else {
                                return
                            }
                            
                            for (_, data) in medicineData {
                                if let med = data["medname"] as? String {
                                    let remindersReference = database.child("medicines").child(id)
                    
                                    remindersReference.observeSingleEvent(of: .value) { snapshot in
                                        if snapshot.exists() {
                                            count = 1
                                            dates = [:]
                                            if let reminders = data["reminders"] as? [String: [String]] {
                                                for (day, times) in reminders {
                                                    count = 1
                                                    for time in times {
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                        if let date = dateFormatter.date(from: time) {
                                                            switch day {
                                                            case "Monday":
                                                                if count == 1 {
                                                                    dates[idcount] = [2:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [2:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [2:date]
                                                                    idcount += 1
                                                                }
                                                            case "Tuesday":
                                                                if count == 1 {
                                                                    dates[idcount] = [3:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [3:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [3:date]
                                                                    idcount += 1
                                                                }
                                                            case "Wednesday":
                                                                if count == 1 {
                                                                    dates[idcount] = [4:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [4:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [4:date]
                                                                    idcount += 1
                                                                }
                                                            case "Thursday":
                                                                if count == 1 {
                                                                    dates[idcount] = [5:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [5:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [5:date]
                                                                    idcount += 1
                                                                }
                                                            case "Friday":
                                                                if count == 1 {
                                                                    dates[idcount] = [6:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [6:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [6:date]
                                                                    idcount += 1
                                                                }
                                                            case "Saturday":
                                                                if count == 1 {
                                                                    dates[idcount] = [7:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [7:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [7:date]
                                                                    idcount += 1
                                                                }
                                                            case "Sunday":
                                                                if count == 1 {
                                                                    dates[idcount] = [1:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 2 {
                                                                    dates[idcount] = [1:date]
                                                                    idcount += 1
                                                                    count += 1
                                                                } else if count == 3 {
                                                                    dates[idcount] = [1:date]
                                                                    idcount += 1
                                                                }
                                                            default:
                                                                break
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                for currentWeekday in 1...7
                                                {
                                                    let datesDict = dates
                                                    latestDate = Calendar.current.startOfDay(for: Date())
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
                                                    
                                                    for (_, value) in sortedDictionary {
                                                        let calendar = Calendar.current
                                                        let components = calendar.dateComponents([.hour, .minute], from: value)
                                                        let dateWithSameTime = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: Date())!
                                                        
                                                        
                                                        if dateWithSameTime.compare(latestDate) == .orderedDescending {
                                                            // date is after confirm
                                                            latestDate = dateWithSameTime
                                                        }
                                                        
                                                        
                                                    }
                                                    
                                                    let content = UNMutableNotificationContent()
                                                    content.title = "PillNotify"
                                                    content.subtitle = "Check-in"
                                                    content.body = "If you did not receive all medication confirmation notifications for \(med), please check into the app to see if there are any missed dosage updates!"
                                                    content.sound = UNNotificationSound.default
                                                    content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

                                                    // Create a date component for 8:00 AM
                                                    let suffix = latestDate
                                                    let calendar = Calendar.current
                                                    let components = calendar.dateComponents([.hour, .minute], from: suffix)
                                                    
                                                    var hour = components.hour ?? 0
                                                    var minute = (components.minute ?? 0) + 45
                                                    
                                                    if minute >= 60 {
                                                        hour += 1
                                                        minute -= 60
                                                    }

                                                    // Create a calendar trigger for daily notifications at 8:00 AM
                                                    let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute, weekday: currentWeekday), repeats: true)
                                                    

                                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                                                    UNUserNotificationCenter.current().add(request) { error in
                                                        if let error = error {
                                                            // Handle the error
                                                            print("Error adding notification request:", error)
                                                        } else {
                                                            // Notification request added successfully
                                                            print("Notification request added successfully")
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                else {
                    print ("no caretaker found")
                }
            }
            
        }
    }
    
    // This method updates the number of pills remaining for a medications.
    // This is controlled by the caretaker and they set how many pills are currently avaialable
    func updateMedicine() {
        let username = UserDefaults.standard.string(forKey: "userid") ?? "NO ID"
        
        var fullname = ""
        var apn = ""
        let caretakerDatabase = database.child("caretaker").child(username)
        caretakerDatabase.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let caretakerData = snapshot.value as? [String: Any] else {
                    return
                }
                
                
                fullname += UserDefaults.standard.string(forKey: "fname") ?? "NO Name"
                fullname += " "
                fullname += UserDefaults.standard.string(forKey: "lname") ?? "NO Name"
                
                if let id = caretakerData["apnsid"] as? String {
                    apn = id
                }
            } else {
                print("No data found in caretaker node")
            }
        }
        
        
        
        let medicineDatabase = database.child("medicines").child(UID).child("\(name)")
        let updatedData: [String: Any] = [
            "remaining": pillsleft,
        ]

        medicineDatabase.updateChildValues(updatedData) { error, _ in
            if let error = error {
                // Handle the error case
                print("Failed to update medicine: \(error.localizedDescription)")
            } else {
                // Medicine updated successfully
                // Handle the success case
                medicineSheet = false
                fetchMedicineRecords()
                print("Medicine updated successfully")
                sendPushNotification(body: "\(fullname) has updated your medication supply for \(name).", subtitle: "Medication Supply Update", phoneId: apn)
            }
        }
    }
    
    // This method is passed a message, a title, and a APNS token representing who to send
    // a push notifications from Firebase to
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
    
    // This method grabs the medications from the medicine database and
    // does some formatting manipulation (takes out hyphens, slashes, other special characters)
    // and then displays the information about that med along with the name to the caretaker
    func fillSheet(medname: String)
    {
        var count = 1
        var user = ""
        var picname = medname.replacingOccurrences(of: " ", with: "-")
        picname = picname.replacingOccurrences(of: "\\", with: "")
        let medicineDatabase = database.child("medicines").child(UID)
        medicineDatabase.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let medicineData = snapshot.value as? [String: [String: Any]] else {
                    return
                }
                
                selectedDays.removeAll()
                
                for (_, data) in medicineData {
                    if let medicineName = data["medname"] as? String, medicineName == medname {
                        // Access and use the medicine information here
                        name = medicineName
                        if let medcolor = data["medcolor"] as? String
                        {
                            color = medcolor
                        }
                        if let username = data["username"] as? String
                        {
                            user = username
                        }
                        if let medshape = data["medshape"] as? String
                        {
                            shape = medshape
                        }
                        
                        if let medcolor = data["medcolor"] as? String
                        {
                            color = medcolor
                        }
                        
                        if let medremain = data["remaining"] as? Int
                        {
                            pillsleft = medremain
                        }
                        
                        if let dose = data["dosage"] as? Int
                        {
                            amount = dose
                        }
                        
                        if let measure = data["unit"] as? String
                        {
                            unit = measure
                        }
                        
                        if let measure = data["secondunit"] as? String
                        {
                            secondunit = measure
                        }
                        
                        
                        if let reminders = data["reminders"] as? [String: [String]] {
                            for (day, times) in reminders {
                                selectedDays.insert(day, at: 0)
                                
                                let timesADay = times.count
                                // Set the timesADay value for the specific day
                                switch day {
                                case "Monday":
                                    timesADayM = timesADay
                                case "Tuesday":
                                    timesADayTu = timesADay
                                case "Wednesday":
                                    timesADayW = timesADay
                                case "Thursday":
                                    timesADayTh = timesADay
                                case "Friday":
                                    timesADayF = timesADay
                                case "Saturday":
                                    timesADaySa = timesADay
                                case "Sunday":
                                    timesADaySu = timesADay
                                default:
                                    break
                                }
                                
                                count = 1
                                for time in times {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    if let date = dateFormatter.date(from: time) {
                                        // Set the timeOfDay value for the specific day and count
                                        switch day {
                                        case "Monday":
                                            if count == 1 {
                                                timeOfDay1M = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2M = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3M = date
                                            }
                                        case "Tuesday":
                                            if count == 1 {
                                                timeOfDay1Tu = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2Tu = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3Tu = date
                                            }
                                        case "Wednesday":
                                            if count == 1 {
                                                timeOfDay1W = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2W = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3W = date
                                            }
                                        case "Thursday":
                                            if count == 1 {
                                                timeOfDay1Th = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2Th = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3Th = date
                                            }
                                        case "Friday":
                                            if count == 1 {
                                                timeOfDay1F = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2F = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3F = date
                                            }
                                        case "Saturday":
                                            if count == 1 {
                                                timeOfDay1Sa = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2Sa = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3Sa = date
                                            }
                                        case "Sunday":
                                            if count == 1 {
                                                timeOfDay1Su = date
                                                count += 1
                                            } else if count == 2 {
                                                timeOfDay2Su = date
                                                count += 1
                                            } else if count == 3 {
                                                timeOfDay3Su = date
                                            }
                                        default:
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("No data found in medicines node for the user: \(user)")
            }
        }

    }
    
    // This method updates the reports database with the dates that the medicine taker has missed
    // for exmaple, lets say a user misses a dose today, then it will update the database to include today as a day
    // that the user missed their dose
    func updateReportsMissed(med: String, date: [Date])
    {
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
            
            var missedCount = 0
            var confirmedCount = 0
            var missedDates: [String] = []
            var confirmDates: [String] = []
            

            let reportsReference = database.child("reports").child(UID).child(med).child(formattedDate)
            reportsReference.observeSingleEvent(of: .value) { snapshot in
                guard let reportData = snapshot.value as? [String: Any] else {
                    let reportsReference2 = database.child("reports").child(UID).child(med).child(formattedDate)
                    
                    let reports: [String: Any] = ["confirmed": 0, "missed":1, "misseddates": stringDates, "seniordates": ["None"]]
                    
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
                    confirmDates = datesS
                }
                if let datesM = reportData["misseddates"] as? [String] {
                    missedDates = datesM
                    for i in stringDates
                    {
                        missedDates.append(i)
                    }
                }
                if let confirmed = reportData["confirmed"] as? Int {
                    confirmedCount = confirmed
                }
                if let missed = reportData["missed"] as? Int {
                    missedCount = missed
                }
                
                    let updatedData: [String: Any] = [
                        "confirmed": confirmedCount,
                        "missed": missedCount + stringDates.count,
                        "misseddates": missedDates,
                        "seniordates": confirmDates
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
    
    // This method alertifies the medicine taker and caretaker that they have missed their dose for a medicaion. If the current time
    // is 45 minutes after what the dosage time was scheduled at, it sends a Firebase push notificaiton to both. It also updates the reports to say
    // that today the medicine taker missed their dose.
    func sendMissedDose()
    {
        let login = UserDefaults.standard.object(forKey: "isLoggedIn") as? Bool ?? false
        if login
        {
            let id = UserDefaults.standard.string(forKey: "userid") ?? "NO"
            let caretakerReference = database.child("caretaker").child(id)
            fullname = ""
            apn = ""
            caretakerapn = ""
            count = 0
            
            var repeats = false
            
            var missedDates: [Date] = []
            
            var dates: [Int: [Int: Date]] = [:]
            var confirmTime: Date = Date()
            var missedRestart: Date = Date()
            var idcount = 1
            
            caretakerReference.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    guard let caretakerData = snapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let apns = caretakerData["apnsid"] as? String {
                        caretakerapn = apns
                    }
                    
                    let usersReference = database.child("users").child(UID)
                    
                    usersReference.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            guard let userData = snapshot.value as? [String: Any] else {
                                return
                            }
                            
                            fullname += UserDefaults.standard.string(forKey: "fname") ?? "No Name"
                            fullname += " "
                            fullname += UserDefaults.standard.string(forKey: "lname") ?? "No Name"
                            if let apns = userData["apnsid"] as? String {
                                apn = apns
                            }
                            
                            let medicineDatabase = database.child("medicines").child(UID)
                            
                            medicineDatabase.observeSingleEvent(of: .value) { snapshot in
                                if snapshot.exists() {
                                    guard let medicineData = snapshot.value as? [String: [String: Any]] else {
                                        return
                                    }
                                    
                                    for (_, data) in medicineData {
                                        if let med = data["medname"] as? String {
                                            // Do something with the medicine name
                                            
                                            let remindersReference = database.child("medicines").child(UID)
                                            
                                            remindersReference.observeSingleEvent(of: .value) { snapshot in
                                                if snapshot.exists() {
                                                    if let time = data["lastconfirm"] as? String {
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                        confirmTime = dateFormatter.date(from: time)!
                                                        missedRestart = confirmTime
                                                    }
                                                    
                                                    if let numtimes = data["count"] as? Int {
                                                        if let confirmtime = data["lastconfirm"] as? String {
                                                            let dateFormatter = DateFormatter()
                                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Assuming the date format is "yyyy-MM-dd HH:mm:ss"
                                                            
                                                            if let confirmDate = dateFormatter.date(from: confirmtime) {
                                                                let calendar = Calendar.current
                                                                let currentDate = Date()
                                                                
                                                                let componentsCurrentDate = calendar.dateComponents([.year, .month, .day], from: currentDate)
                                                                let componentsConfirmDate = calendar.dateComponents([.year, .month, .day], from: confirmDate)
                                                                
                                                                if let date1 = calendar.date(from: componentsCurrentDate),
                                                                   let date2 = calendar.date(from: componentsConfirmDate) {
                                                                    let daysApart = calendar.dateComponents([.day], from: date2, to: date1).day ?? 0
                                                                    
                                                                    if daysApart >= 1 {
                                                                        count = 0
                                                                        repeats = true
                                                                        missedRestart = Calendar.current.startOfDay(for: Date())
                                                                    }
                                                                    else
                                                                    {
                                                                        count = numtimes
                                                                        if let time = data["repeatMissed"] as? Bool {
                                                                            repeats = time
                                                                        }
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    
                                                    
                                                    var count2 = 1
                                                    dates = [:]
                                                    changeCount = false
                                                    missedDates = []
                                                    if let reminders = data["reminders"] as? [String: [String]] {
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
                                                        
                                                        
                                                        for (_, value) in sortedDictionary {
                                                            let calendar = Calendar.current
                                                            let components = calendar.dateComponents([.hour, .minute], from: value)
                                                            let dateWithSameTime = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: today)!
                                                            
                                                            
                                                            if dateWithSameTime.compare(confirmTime) == .orderedDescending {
                                                                // date is after confirm
                                                                if Date().compare(dateWithSameTime) == .orderedDescending {
                                                                    let components = calendar.dateComponents([.hour, .minute], from: dateWithSameTime, to: Date())
                                                                    
                                                                    
                                                                    if let hours = components.hour, let mins = components.minute
                                                                    {
                                                                        if hours > 0 || mins >= 45
                                                                        {
                                                                            if count <= 2 && repeats == true {
                                                                                sendPushNotification(body: "Hi \(fullname), your medicine taker has missed their dose on \(dateToString(count: dateWithSameTime)) for \(med). They may still be able to confirm this dose late.", subtitle: "Missed Dose", phoneId: apn)
                                                                                
                                                                                if caretakerapn != UserDefaults.standard.string(forKey: "apnsToken") ?? "No APNS"
                                                                                {
                                                                                    sendPushNotification(body: "\(fullname) has been notified you have missed your \(dateToString(count: dateWithSameTime)) dose for \(med). You can still confirm this med.", subtitle: "Missed Dose", phoneId: caretakerapn)
                                                                                }
                                                                                count += 1
                                                                                changeCount = true
                                                                                missedDates.append(dateWithSameTime)
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                        if changeCount == true {
                                                            updateReportsMissed(med: med, date: missedDates)
                                                            let medicineRef = database.child("medicines").child(UID).child(med)
                                                            let updatedData: [String: Any] = [
                                                                "count": count,
                                                                "repeatMissed": false,
                                                                "lastconfirm" : dateToString(count:missedRestart)
                                                            ]
                                                            
                                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                                if let error = error {
                                                                    // Handle the error case
                                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                                } else {
                                                                    repeats = false
                                                                }
                                                            }
                                                        }
                                                        else
                                                        {
                                                            let medicineRef = database.child("medicines").child(UID).child(med)
                                                            let updatedData: [String: Any] = [
                                                                "count": count,
                                                                "repeatMissed": repeats
                                                            ]
                                                            
                                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                                if let error = error {
                                                                    // Handle the error case
                                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                                } else {
                                                                    print("oo")
                                                                }
                                                            }
                                                        }
                                                        

                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                        } else {
                            print("No data found for caretakee in users node")
                        }
                    }
                } else {
                    print("No data found in caretaker node")
                }
            }
        }
    }
    
    // This method retrieves all the medicines that a medicine taker is taking and displays them to the caretaker
    func fetchMedicineRecords() {
        if let userID = UserDefaults.standard.object(forKey: "userid") as? String {
            
            let caretakerDatabase = database.child("caretaker").child(userID)
            
            caretakerDatabase.observeSingleEvent(of: .value) { caretakerSnapshot in
                if caretakerSnapshot.exists() {
                    guard let caretakerData = caretakerSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let id = caretakerData["caretakeeID"] as? String{
                        UID = id
                        let medicinesReference = database.child("medicines").child(id)
                        
                        medicinesReference.observeSingleEvent(of: .value) { snapshot in
                            guard let medicinesData = snapshot.value as? [String: [String: Any]] else {
                                return
                            }
                            
                            for (medicineId, medicineData) in medicinesData {
                                if let did = medicineData["username"] as? String, did == id {
                                    medicineRecords[medicineId] = medicineData
                                }
                            }
                        }
                        sendMissedDose()
                    }
                    
                }
            }
            
        }

    }
}


struct CaretakerMedView_Previews: PreviewProvider {
    static var previews: some View {
        CaretakerMedView()
    }
}
