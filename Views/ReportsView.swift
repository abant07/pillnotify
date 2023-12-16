//
//  ReportsView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 7/17/23.
//

import MessageUI
import SwiftUI
import FirebaseDatabase
import Charts
import FirebaseAuth
import StoreKit

var email = ""

struct ReportsView: View {
    @StateObject private var emailController = EmailController()
    private let database = Database.database().reference()
    private let productID = "com.amoghbantwal.PillAlertify.app.PillNotifyPro"
    @StateObject private var networkMonitor = NetworkMonitor()

    
    @State private var medicineName = "All Meds"
    @State private var selectedDate = "All Time"
    @State private var onlyDates = ""
    @State private var missed = 0
    @State private var conf = 0
    @State private var caretakerConf = 0
    @State private var avg: Double = 0.0
    @State private var median: Double = 0.0
    
    @State private var UID = ""
    
    @State private var isActionSheetPresented = false
    @State private var showingImagePicker = false
    @State private var sheet = false
    @State private var animate = false
    
    @State private var showFilter = false
    @State private var filteredDate1 = Date()
    @State private var filteredDate2 = Date()
    @State private var filteredMed = "All Meds"
    @State private var canSendMail = false
    
    
    @State private var datesRecords: [String: [String]] = [:]
    @State private var seniorDatesRecords: [String: [String]] = [:]
    @State private var missedRecords: [String: [String]] = [:]
    @State private var categoriesSum: [CategorySum] = []
    @State private var images: [UIImage] = [UIImage()]
    @State private var stringDates: [String] = ["All Time", "Last Week", "Last Two Weeks", "Last Month", "Last Two Months", "Last Year"]
    @State private var viewConfirm: [ViewConfirm] = []
    @State private var medicineRecords: [String] = ["All Meds"]
    
    
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
                            .frame(width: UIScreen.main.bounds.width - 20, height: 1)
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
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
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
                LazyVStack
                {
                    HStack {
                        Text("Reports")
                            .foregroundStyle(.white)
                            .font(.custom("AmericanTypewriter-Bold", size: 40))
                            .shadow(color: .black, radius: 5)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            isActionSheetPresented = true
                        }, label: {
                            Label("Send Reports", systemImage: "square.and.arrow.up")
                                .font(.custom("AmericanTypewriter-Bold", size: 17))
                                .foregroundStyle(.white)
                                .shadow(color: .black, radius: 5)
                                .padding()
                        })
                        
                        .sheet(isPresented: $showingImagePicker) {
                            MultiImagePicker(images: $images, isShown: $showingImagePicker)
                        }
                        .sheet(isPresented: $showFilter) {
                            NavigationStack
                            {
                                VStack
                                {
                                    Form
                                    {
                                        Section{
                                            Picker("Medicine:", selection: $filteredMed) {
                                                ForEach(medicineRecords, id: \.self) {
                                                    Text("\($0)")
                                                        .padding()
                                                        .tag(String($0))
                                                }
                                            }
                                        }
                                        Section {
                                            DatePicker("Start Date:", selection: $filteredDate1, displayedComponents: [.date])
                                        }
                                        Section {
                                            DatePicker("End Date: ", selection: $filteredDate2, displayedComponents: [.date])
                                        }
                                    }
                                }
                                .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                                .toolbarBackground(.visible, for: .navigationBar)
                                .toolbarColorScheme(.dark)
                                .navigationTitle("Filter Report")
                                .navigationBarItems(
                                    leading: Button(action: {
                                        showFilter = false
                                        
                                    }) {
                                        Text("Cancel").bold()
                                            .foregroundStyle(.white)
                                    }
                                )
                                .navigationBarItems(
                                    trailing: Button(action: {
                                        showFilter = false
                                        displayEmail(med: filteredMed, startDate: filteredDate1, endDate: filteredDate2, image: images)
                                    }) {
                                        Text("Send Email")
                                            .foregroundStyle(.white)
                                            .bold()
                                    }
                                )
                            }
                            .presentationDetents([.height(400)])
                        }
                        .onChange(of: images) { newImage in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if newImage != [UIImage()]
                                {
                                    showFilter = true
                                }
                                
                            }
                        }
                        .confirmationDialog(
                            "Send Reports",
                            isPresented: $isActionSheetPresented)
                        {
                            Button("Include Screenshot") {
                                showingImagePicker = true
                                filteredMed = "All Meds"
                                filteredDate1 = Date()
                                filteredDate2 = Date()
                                images = [UIImage()]
                            }
                            Button("Don't Include Screenshot") {
                                showFilter = true
                                filteredMed = "All Meds"
                                filteredDate1 = Date()
                                filteredDate2 = Date()
                                images = [UIImage()]
                            }
                            
                            Button("Cancel", role: .cancel) {}
                            
                        }
                        .alert(isPresented: $emailController.canSendMail)
                        {
                            Alert(
                                title: Text("Email Error"),
                                message: Text("Please make sure Mail is set-up to send emails"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    
                    
                    Text("\(onlyDates)")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 18))
                        .shadow(color: .black, radius: 5)
                    HStack
                    {
                        
                        Picker("Medicine:", selection: $medicineName) {
                            ForEach(medicineRecords, id: \.self) {
                                Text("\($0)")
                                    .tag(String($0))
                                    .foregroundStyle(.white)
                            }
                        }
                        .accentColor(.white)
                        .onAppear{
                            if medicineName == "All Meds"
                            {
                                getData(med: "All Meds", date: selectedDate)
                                getMedicalAdherance(med: "All Meds", date: selectedDate)
                            }
                        }
                        .onChange(of: medicineName)
                        { med in
                            getData(med: med, date: selectedDate)
                            getMedicalAdherance(med: med, date: selectedDate)
                            animate.toggle()
                        }
                        
                        Picker("Date:", selection: $selectedDate) {
                            ForEach(stringDates, id: \.self) {
                                Text("\($0)")
                                    .padding()
                                    .tag(String($0))
                            }
                        }
                        .accentColor(.white)
                        .onChange(of: selectedDate)
                        { date in
                            getData(med: medicineName, date: date)
                            getWeek(date: date)
                            getMedicalAdherance(med: medicineName, date: date)
                            animate.toggle()
                        }
                        .onAppear{
                            if selectedDate == "All Meds"
                            {
                                getWeek(date: "All Time")
                            }
                            else
                            {
                                getWeek(date: selectedDate)
                            }
                        }
                        
                    }
                    
                    Text("Dosage Count Report")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 16))
                        .shadow(color: .black, radius: 5)
                        .padding(.bottom, 20)
                    
                    Chart{
                        ForEach(viewConfirm) { viewConfirm in
                            BarMark(x: .value("Type", viewConfirm.type), y: .value("Count", viewConfirm.confirmed)
                            )
                            .foregroundStyle(Color.white.gradient)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .frame(height: 200)
                    .animation(Animation.spring(), value: animate)
                    
                    Text("Total Confirmed Dosages Count: \(conf)")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 16))
                        .shadow(color: .black, radius: 5)
                        .italic()
                    Text("Total Missed Dosages Count: \(missed)")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 16))
                        .shadow(color: .black, radius: 5)
                        .padding(.bottom, 20)
                        .italic()
                    
                    Button(action:{sheet = true
                        getDates(med: medicineName, date: selectedDate)
                    }, label: {
                        Text("See Dates")
                            .bold()
                            .frame(width: UIScreen.main.bounds.width - 40, height: 70)
                            .background {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                            }
                            .foregroundStyle(.white)
                            .shadow(color: .white, radius: 5)
                    })
                    .padding(.bottom, 20)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .sheet(isPresented: $sheet)
                    {
                        NavigationStack
                        {
                            ScrollView
                            {
                                LazyVStack
                                {
                                    Text("Confirmed Dosage Dates")
                                        .foregroundStyle(.white)
                                        .font(.custom("AmericanTypewriter-Bold", size: 20))
                                        .shadow(color: .black, radius: 5)
                                        .padding(.bottom, 20)
                                    
                                    ForEach(seniorDatesRecords.sorted(by: { $0.key < $1.key }), id: \.key) { med, dates in
                                        Text("\(med)")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .font(.custom("AmericanTypewriter-Bold", size: 16))
                                            .shadow(color: .black, radius: 5)
                                            .padding(.bottom, 10)
                                        ForEach(dates, id: \.self) { date in
                                            if (date != "None")
                                            {
                                                Rectangle()
                                                    .frame(width: UIScreen.main.bounds.width - 50, height: 40)
                                                    .foregroundStyle(.white)
                                                    .cornerRadius(10.0)
                                                    .padding(.bottom, 10)
                                                    .shadow(color: .black, radius: 5)
                                                    .overlay(
                                                        Text("Date: \(date)")
                                                            .foregroundStyle(Color(red: 0/255, green: 47/255, blue: 100/255))
                                                            .padding(.bottom, 10)
                                                            .font(.subheadline)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.bottom, 20)
                                    
                                    Text("Missed Dosage Dates")
                                        .foregroundStyle(.white)
                                        .font(.custom("AmericanTypewriter-Bold", size: 16))
                                        .shadow(color: .black, radius: 5)
                                        .padding(.bottom, 10)
                                    
                                    ForEach(missedRecords.sorted(by: { $0.key < $1.key }), id: \.key) { med, dates in
                                        VStack(alignment: .center) {
                                            Text("\(med)")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                                .font(.custom("AmericanTypewriter-Bold", size: 16))
                                                .shadow(color: .black, radius: 5)
                                                .padding(.bottom, 10)
                                            ForEach(dates, id: \.self) { date in
                                                if (date != "None")
                                                {
                                                    Rectangle()
                                                        .frame(width: UIScreen.main.bounds.width - 50, height: 40)
                                                        .foregroundStyle(.white)
                                                        .cornerRadius(10.0)
                                                        .padding(.bottom, 10)
                                                        .shadow(color: .black, radius: 5)
                                                        .overlay(
                                                            Text("Date: \(date)")
                                                                .foregroundStyle(Color(red: 0/255, green: 47/255, blue: 100/255))
                                                                .padding(.bottom, 10)
                                                                .font(.subheadline)
                                                        )
                                                }
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
                            .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .toolbarColorScheme(.dark)
                            .navigationTitle("Dates")
                            .navigationBarItems(
                                trailing: Button(action: {
                                    sheet = false
                                }) {
                                    Text("Dismiss").bold()
                                        .foregroundStyle(.white)
                                }
                            )
                        }
                        
                    }

                    Text("Medical Adherance Report")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 16))
                        .shadow(color: .black, radius: 5)
                        .padding(.bottom, 20)
                        .italic()
                    
                    HStack(alignment: .top, spacing: 10)
                    {
                        Image(systemName: "circle.fill")
                            .rotationEffect(Angle(degrees: 45))
                            .foregroundColor(Color.green)
                        
                        if avg.isNaN
                        {
                            Text("Confirmed 0.0%")
                                .foregroundColor(.secondary)
                        }
                        else
                        {
                            Text("Confirmed " + String(avg.rounded()) + "%")
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "circle.fill")
                            .rotationEffect(Angle(degrees: 45))
                            .foregroundColor(Color.red)
                        
                        if median.isNaN
                        {
                            Text("Missed 0.0%")
                                .foregroundColor(.secondary)
                        }
                        else
                        {
                            Text("Missed " + String(median.rounded()) + "%")
                                .foregroundColor(.secondary)
                        }
                        
                    }
                    .padding(.bottom, 30)
                    
                    PieChartView(
                        data: categoriesSum.map { ($0.sum, $0.category) },
                        style: Styles.pieChartStyleOne,
                        form: CGSize(width: 300, height: 240),
                        dropShadow: true
                        )
                    
                    
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
            .onAppear {
                fetchMedicineRecords()
                animate.toggle()
                checkPaid()
            }
            
        }
        
    }
    
    func purchaseProduct() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            
        } else {
            print("User unable to make payments")
        }
    }
    
    func checkPaid() {
        let username = UserDefaults.standard.string(forKey: "userid")!
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
    
    func sortMedicineRecords(_ dictionary: [String: [String]]) -> [String: [String]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Convert date strings to Date objects and find the most recent date in each group
        let groupsWithDates = dictionary.mapValues { dates in
            dates.compactMap { dateFormatter.date(from: $0) }.max()
        }

        // Sort the groups based on the most recent date in each group
        let sortedGroups = groupsWithDates.sorted { entry1, entry2 in
            guard let date1 = entry1.value, let date2 = entry2.value else { return false }
            return date1 > date2
        }

        // Convert the sorted array of tuples back to a dictionary
        let sortedDictionary = Dictionary(uniqueKeysWithValues: sortedGroups.map { ($0.key, dictionary[$0.key]!) })

        return sortedDictionary
    }

    func mergeDuplicateMedicineNames(_ dictionary: [Int: [String: [String]]]) -> [String: [String]] {
        var result: [String: [String]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for (_, value) in dictionary {
            for (medicineName, medicineValues) in value {
                if var existingValues = result[medicineName] {
                    // Filter out "None" and convert to Date objects
                    let newDates = medicineValues.compactMap { dateString -> Date? in
                        if dateString != "None" {
                            return dateFormatter.date(from: dateString)
                        }
                        return nil
                    }
                    // Append and sort as Date objects
                    existingValues.append(contentsOf: newDates.map { dateFormatter.string(from: $0) })
                    let sortedDates = existingValues.compactMap { dateFormatter.date(from: $0) }.sorted(by: >)
                    result[medicineName] = sortedDates.map { dateFormatter.string(from: $0) }
                } else {
                    result[medicineName] = medicineValues.filter { $0 != "None" }
                }
            }
        }

        // Call sortMedicineRecords to sort the merged records
        return sortMedicineRecords(result)
    }

    
    func getAuthenticatedUserUID() {
        if let currentUser = Auth.auth().currentUser {
            UID = currentUser.uid
            print("Authenticated user UID: \(UID)")
        } else {
            print("No user is currently logged in.")
        }
    }
    
    func calculateMedian(data: [Double]) -> Double? {
        let sortedData = data.sorted()
        let count = sortedData.count

        if count == 0 {
            return nil // No data to calculate median
        } else if count % 2 == 1 {
            // Odd number of elements
            return sortedData[count / 2]
        } else {
            // Even number of elements
            let middleIndex = count / 2
            return (sortedData[middleIndex - 1] + sortedData[middleIndex]) / 2.0
        }
    }
    
    
    func getDates(med: String, date: String)
    {
        missedRecords = [:]
        seniorDatesRecords = [:]
        
        if let id = UserDefaults.standard.object(forKey: "userid") as? String {
            let usersReference = database.child("caretaker").child(id)

            usersReference.observeSingleEvent(of: .value) { usersSnapshot in
                if usersSnapshot.exists() {
                    guard let usersData = usersSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let userID = usersData["caretakeeID"] as? String{
                        if date == "Last Week"
                        {
                            if med == "All Meds"
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<1 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }
                                        

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week
                                            
                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)
                                            
                                            for (name, medicineData) in userData {
                                                count += 1
                                                if let dateData = medicineData[formattedDate] {
                                                    if let dates = dateData["seniordates"] as? [String] {
                                                        seniorDatesRecordsPrev[count] = [name: dates]
                                                    }
                                                    if let dates = dateData["misseddates"] as? [String] {
                                                        missedRecordsPrev[count] = [name: dates]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                        missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<1 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }
                                            

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    count += 1
                                                    if date == formattedDate
                                                    {
                                                        if let dates = medicineData["seniordates"] as? [String] {
                                                            seniorDatesRecordsPrev[count] = [med: dates]
                                                        }
                                                        if let dates = medicineData["misseddates"] as? [String] {
                                                            missedRecordsPrev[count] = [med: dates]
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                            missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Two Weeks"
                        {
                            if med == "All Meds"
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<2 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }
                                        

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week
                                            
                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)
                                            
                                            for (name, medicineData) in userData {
                                                count += 1
                                                if let dateData = medicineData[formattedDate] {
                                                    if let dates = dateData["seniordates"] as? [String] {
                                                        seniorDatesRecordsPrev[count] = [name: dates]
                                                    }
                                                    if let dates = dateData["misseddates"] as? [String] {
                                                        missedRecordsPrev[count] = [name: dates]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                        missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<2 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }
                                            

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    count += 1
                                                    if date == formattedDate
                                                    {
                                                        if let dates = medicineData["seniordates"] as? [String] {
                                                            seniorDatesRecordsPrev[count] = [med: dates]
                                                        }
                                                        if let dates = medicineData["misseddates"] as? [String] {
                                                            missedRecordsPrev[count] = [med: dates]
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                            missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Month"
                        {
                            if med == "All Meds"
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<4 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }
                                        

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week
                                            
                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)
                                            
                                            for (name, medicineData) in userData {
                                                count += 1
                                                if let dateData = medicineData[formattedDate] {
                                                    if let dates = dateData["seniordates"] as? [String] {
                                                        seniorDatesRecordsPrev[count] = [name: dates]
                                                    }
                                                    if let dates = dateData["misseddates"] as? [String] {
                                                        missedRecordsPrev[count] = [name: dates]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                        missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<4 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }
                                            

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    count += 1
                                                    if date == formattedDate
                                                    {
                                                        if let dates = medicineData["seniordates"] as? [String] {
                                                            seniorDatesRecordsPrev[count] = [med: dates]
                                                        }
                                                        if let dates = medicineData["misseddates"] as? [String] {
                                                            missedRecordsPrev[count] = [med: dates]
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                            missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Two Months"
                        {
                            if med == "All Meds"
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<8 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }
                                        

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week
                                            
                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)
                                            
                                            for (name, medicineData) in userData {
                                                count += 1
                                                if let dateData = medicineData[formattedDate] {
                                                    if let dates = dateData["seniordates"] as? [String] {
                                                        seniorDatesRecordsPrev[count] = [name: dates]
                                                    }
                                                    if let dates = dateData["misseddates"] as? [String] {
                                                        missedRecordsPrev[count] = [name: dates]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                        missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<8 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }
                                            

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    count += 1
                                                    if date == formattedDate
                                                    {
                                                        if let dates = medicineData["seniordates"] as? [String] {
                                                            seniorDatesRecordsPrev[count] = [med: dates]
                                                        }
                                                        if let dates = medicineData["misseddates"] as? [String] {
                                                            missedRecordsPrev[count] = [med: dates]
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                            missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Year"
                        {
                            if med == "All Meds"
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<52 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }
                                        

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week
                                            
                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)
                                            
                                            for (name, medicineData) in userData {
                                                count += 1
                                                if let dateData = medicineData[formattedDate] {
                                                    if let dates = dateData["seniordates"] as? [String] {
                                                        seniorDatesRecordsPrev[count] = [name: dates]
                                                    }
                                                    if let dates = dateData["misseddates"] as? [String] {
                                                        missedRecordsPrev[count] = [name: dates]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                        missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                var count = 0
                                var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                var missedRecordsPrev: [Int: [String: [String]]] = [:]

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<52 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }
                                            

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    count += 1
                                                    if date == formattedDate
                                                    {
                                                        if let dates = medicineData["seniordates"] as? [String] {
                                                            seniorDatesRecordsPrev[count] = [med: dates]
                                                        }
                                                        if let dates = medicineData["misseddates"] as? [String] {
                                                            missedRecordsPrev[count] = [med: dates]
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                            seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                            missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else
                        {
                            if med == "All Meds"
                            {

                                var weeks = 0

                                
                                let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                reportsReference.observeSingleEvent(of: .value) { snapshot in
                                    guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                        return
                                    }
                                    
                                    var allDates: [String] = []
                                    
                                    // Iterate through the outer dictionary to access the inner dictionaries and their keys
                                    for (_, innerDict) in userData {
                                        for (date, _) in innerDict {
                                            // Append the date to the allDates array
                                            allDates.append(date)
                                        }
                                    }
                                    
                                    let sortedDates = allDates.sorted()
                                    
                                    // Find the difference between the first and last dates in number of weeks
                                    if let firstDate = sortedDates.first, let lastDate = sortedDates.last {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        
                                        if let startDate = dateFormatter.date(from: firstDate), let endDate = dateFormatter.date(from: lastDate) {
                                            let calendar = Calendar.current
                                            let components = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate)
                                            if let numberOfWeeks = components.weekOfYear {
                                                weeks = numberOfWeeks + 1
                                            }
                                        }
                                    }
                                    
                                    weeks += 1
                                    
                                    var count = 0
                                    
                                    let calendar = Calendar.current
                                    let currentDate = Date()
                                    
                                    var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                    
                                    var missedRecordsPrev: [Int: [String: [String]]] = [:]
                                    
                                    // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                    let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7
                                    
                                    // Create date components with the calculated days to subtract
                                    var dateComponents = DateComponents()
                                    dateComponents.day = -daysToSubtract
                                    
                                    // Get the last Sunday by subtracting the date components from the current date
                                    if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {
                                        
                                        // Calculate the dates for the previous two Sundays
                                        var previousSundays: [Date] = []
                                        for i in 0..<weeks {
                                            let daysToSubtract = i * 7
                                            dateComponents.day = -daysToSubtract
                                            if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                                // Set the time components of the previousSunday to midnight (00:00:00)
                                                let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                                previousSundays.insert(startOfPreviousSunday, at: 0)
                                            }
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week
                                            
                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)
                                            
                                            for (name, medicineData) in userData {
                                                count += 1
                                                if let dateData = medicineData[formattedDate] {
                                                    if let dates = dateData["seniordates"] as? [String] {
                                                        seniorDatesRecordsPrev[count] = [name: dates]
                                                    }
                                                    if let dates = dateData["misseddates"] as? [String] {
                                                        missedRecordsPrev[count] = [name: dates]
                                                    }
                                                }
                                            }
                                            
                                        }
                                        seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                        missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)
                                       
                                        
                                        
                                    }
                                }
                            }
                            else
                            {
                                
                                let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                reportsReference.observeSingleEvent(of: .value) { snapshot in
                                    guard let userData = snapshot.value as? [String: [String: Any]] else {
                                        return
                                    }
                                    
                                    var count = 0
                                    var seniorDatesRecordsPrev: [Int: [String: [String]]] = [:]
                                    var missedRecordsPrev: [Int: [String: [String]]] = [:]
                                    
                                    let sortedDateData = userData.sorted { $0.key < $1.key }
                                    for (_, medicineData) in sortedDateData {
                                        count += 1
                                        if let dates = medicineData["seniordates"] as? [String] {
                                            seniorDatesRecordsPrev[count] = [med: dates]
                                        }
                                        if let dates = medicineData["misseddates"] as? [String] {
                                            missedRecordsPrev[count] = [med: dates]
                                        }
                                    }
                                    
                                    seniorDatesRecords = mergeDuplicateMedicineNames(seniorDatesRecordsPrev)
                                    missedRecords = mergeDuplicateMedicineNames(missedRecordsPrev)

                                }
                            }
                        }
                        
                        
                    }
                    
                } else {
                    print("No data found in users node")
                }
            }
        }
    }

    
    func getMedicalAdherance(med:String, date: String)
    {
        categoriesSum = []
        avg = 0.0
        median = 0.0
        if let id = UserDefaults.standard.object(forKey: "userid") as? String {
            let usersReference = database.child("caretaker").child(id)
            
            usersReference.observeSingleEvent(of: .value) { usersSnapshot in
                if usersSnapshot.exists() {
                    guard let usersData = usersSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let userID = usersData["caretakeeID"] as? String{
                        if date == "Last Week"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0

                                var count: Double = 0.0
                                var average: Double = 0.0
                                

                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<1 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose = Double(confirmedCount)
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose = Double(missedCount)
                                                    }
                                                    average += confirmedDose
                                                    count += missedDose
                                                }
                                            }
                                            
                                        }
                                        avg = average / (average + count) * 100
                                        median = count / (average + count) * 100
                                        categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                        categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                        
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<1 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }
                                            

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    if date == formattedDate
                                                    {
                                                        if let confirmedCount = medicineData["confirmed"] as? Int{
                                                            confirmedDose = Double(confirmedCount)
                                                        }
                                                        if let missedCount = medicineData["missed"] as? Int{
                                                            missedDose = Double(missedCount)
                                                            
                                                        }
                                                        average += confirmedDose
                                                        count += missedDose
                                                    }
                                                    
                                                }
                                            }
                                            avg = average / (average + count) * 100
                                            median = count / (average + count) * 100
                                            categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                            categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                            
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            
                        }
                        else if date == "Last Two Weeks"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0

                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<2 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose = Double(confirmedCount)
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose = Double(missedCount)
                                                    }
                                                    average += confirmedDose
                                                    count += missedDose
                                                }
                                            }
                                            
                                        }
                                        avg = average / (average + count) * 100
                                        median = count / (average + count) * 100
                                        categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                        categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<2 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    if date == formattedDate
                                                    {
                                                        if let confirmedCount = medicineData["confirmed"] as? Int{
                                                            confirmedDose = Double(confirmedCount)
                                                        }
                                                        if let missedCount = medicineData["missed"] as? Int{
                                                            missedDose = Double(missedCount)
                                                            
                                                        }
                                                        average += confirmedDose
                                                        count += missedDose
                                                    }
                                                    
                                                }
                                            }
                                            avg = average / (average + count) * 100
                                            median = count / (average + count) * 100
                                            categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                            categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }

                            
                        }
                        else if date == "Last Month"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0

                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<4 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose = Double(confirmedCount)
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose = Double(missedCount)
                                                    }
                                                    average += confirmedDose
                                                    count += missedDose
                                                }
                                            }
                                            
                                        }
                                        avg = average / (average + count) * 100
                                        median = count / (average + count) * 100
                                        categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                        categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<4 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    if date == formattedDate
                                                    {
                                                        if let confirmedCount = medicineData["confirmed"] as? Int{
                                                            confirmedDose = Double(confirmedCount)
                                                        }
                                                        if let missedCount = medicineData["missed"] as? Int{
                                                            missedDose = Double(missedCount)
                                                            
                                                        }
                                                        average += confirmedDose
                                                        count += missedDose
                                                    }
                                                    
                                                }
                                            }
                                            avg = average / (average + count) * 100
                                            median = count / (average + count) * 100
                                            categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                            categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }

                            
                        }
                        else if date == "Last Two Months"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0

                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<8 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose = Double(confirmedCount)
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose = Double(missedCount)
                                                    }
                                                    average += confirmedDose
                                                    count += missedDose
                                                }
                                            }
                                            
                                        }
                                        avg = average / (average + count) * 100
                                        median = count / (average + count) * 100
                                        categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                        categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<8 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    if date == formattedDate
                                                    {
                                                        if let confirmedCount = medicineData["confirmed"] as? Int{
                                                            confirmedDose = Double(confirmedCount)
                                                        }
                                                        if let missedCount = medicineData["missed"] as? Int{
                                                            missedDose = Double(missedCount)
                                                            
                                                        }
                                                        average += confirmedDose
                                                        count += missedDose
                                                    }
                                                    
                                                }
                                            }
                                            avg = average / (average + count) * 100
                                            median = count / (average + count) * 100
                                            categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                            categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }

                            
                        }
                        else if date == "Last Year"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0

                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<52 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }
                                    
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose = Double(confirmedCount)
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose = Double(missedCount)
                                                    }
                                                    average += confirmedDose
                                                    count += missedDose
                                                }
                                            }
                                            
                                        }
                                        avg = average / (average + count) * 100
                                        median = count / (average + count) * 100
                                        categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                        categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<52 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.insert(startOfPreviousSunday, at: 0)
                                        }
                                    }

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            for previousSunday in previousSundays {
                                                // Create a date formatter to get just the date in yyyy-MM-dd format
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                // Format the previousSunday date to get the date in yyyy-MM-dd format
                                                let formattedDate = dateFormatter.string(from: previousSunday)
                                                
                                                
                                                for (date, medicineData) in userData {
                                                    if date == formattedDate
                                                    {
                                                        if let confirmedCount = medicineData["confirmed"] as? Int{
                                                            confirmedDose = Double(confirmedCount)
                                                        }
                                                        if let missedCount = medicineData["missed"] as? Int{
                                                            missedDose = Double(missedCount)
                                                            
                                                        }
                                                        average += confirmedDose
                                                        count += missedDose
                                                    }
                                                    
                                                }
                                            }
                                            avg = average / (average + count) * 100
                                            median = count / (average + count) * 100
                                            categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                            categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                            
                                        }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }

                            
                        }
                        else
                        {
                            if med == "All Meds"
                            {

                                var confirmedDose: Double = 0.0
                                var missedDose: Double = 0.0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                var weeks = 0

                                
                                let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                reportsReference.observeSingleEvent(of: .value) { snapshot in
                                    guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                        return
                                    }
                                    
                                    var allDates: [String] = []
                                    
                                    // Iterate through the outer dictionary to access the inner dictionaries and their keys
                                    for (_, innerDict) in userData {
                                        for (date, _) in innerDict {
                                            // Append the date to the allDates array
                                            allDates.append(date)
                                        }
                                    }
                                    
                                    
                                    let sortedDates = allDates.sorted()
                                    
                                    // Find the difference between the first and last dates in number of weeks
                                    if let firstDate = sortedDates.first, let lastDate = sortedDates.last {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        
                                        if let startDate = dateFormatter.date(from: firstDate), let endDate = dateFormatter.date(from: lastDate) {
                                            let calendar = Calendar.current
                                            let components = calendar.dateComponents([.weekOfYear], from: startDate, to: endDate)
                                            if let numberOfWeeks = components.weekOfYear {
                                                weeks = numberOfWeeks + 1
                                            }
                                        }
                                    }
                                    
                                    weeks += 1
                                    
                                    
                                    let calendar = Calendar.current
                                    let currentDate = Date()
                                    
                                    // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                    let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7
                                    
                                    // Create date components with the calculated days to subtract
                                    var dateComponents = DateComponents()
                                    dateComponents.day = -daysToSubtract
                                    
                                    // Get the last Sunday by subtracting the date components from the current date
                                    if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {
                                        
                                        // Calculate the dates for the previous two Sundays
                                        var previousSundays: [Date] = []
                                        for i in 0..<weeks {
                                            let daysToSubtract = i * 7
                                            dateComponents.day = -daysToSubtract
                                            if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                                // Set the time components of the previousSunday to midnight (00:00:00)
                                                let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                                previousSundays.insert(startOfPreviousSunday, at: 0)
                                            }
                                        }
                                        
                                        
                                        
                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose = Double(confirmedCount)
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose = Double(missedCount)
                                                    }
                                                    average += confirmedDose
                                                    count += missedDose
                                                }
                                            }
                                            
                                        }
                                        avg = average / (average + count) * 100
                                        median = count / (average + count) * 100
                                        categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                        categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                        
                                        
                                    }
                                }
                            }
                            else
                            {
                                var confirmedDose: Double = 0
                                var missedDose: Double = 0
                                
                                var count: Double = 0.0
                                var average: Double = 0.0
                                
                                let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                reportsReference.observeSingleEvent(of: .value) { snapshot in
                                    guard let userData = snapshot.value as? [String: [String: Any]] else {
                                        return
                                    }
                                    
                                    let sortedDateData = userData.sorted { $0.key < $1.key }
                                    for (_, medicineData) in sortedDateData {
                                        if let confirmedCount = medicineData["confirmed"] as? Int{
                                            confirmedDose = Double(confirmedCount)
                                        }
                                        if let missedCount = medicineData["missed"] as? Int{
                                            missedDose = Double(missedCount)
                                        }
                                        average += confirmedDose
                                        count += missedDose
                                    }
                                    avg = average / (average + count) * 100
                                    median = count / (average + count) * 100
                                    categoriesSum.append(CategorySum(sum: average, category: Color.green))
                                    categoriesSum.append(CategorySum(sum: count, category: Color.red))
                                    
                                    
                                }
                            }
                        }
                        
                        
                        
                    }
                }
            }
            
        }
    }
    
    func getWeek(date: String)
    {
        if date == "Last Week"
        {
            let calendar = Calendar.current
            let currentDate = Date()
            
            // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
            let currentWeekday = calendar.component(.weekday, from: currentDate)
            
            // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
            let daysToSubtract = (currentWeekday + 6) % 7
            
            // Create date components with the calculated days to subtract
            var dateComponents = DateComponents()
            dateComponents.day = -daysToSubtract - 7
            
            let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // Format the lastSunday date to get the date in yyyy-MM-dd format
            let formattedDate = dateFormatter.string(from: lastSunday!)
            
            let daysUntilSunday = calendar.component(.weekday, from: currentDate) - 1
            let mostRecentSunday = calendar.date(byAdding: .day, value: -daysUntilSunday, to: currentDate)!

            let formattedDate2 = dateFormatter.string(from: mostRecentSunday)

            
            onlyDates = "Date Range: \(formattedDate) to \(formattedDate2)"
        }
        else if date == "Last Two Weeks"
        {
            let calendar = Calendar.current
            let currentDate = Date()

            // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
            let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

            // Create date components with the calculated days to subtract
            var dateComponents = DateComponents()
            dateComponents.day = -daysToSubtract - 7

            let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate)

                // Calculate the dates for the previous two Sundays
            var previousSundays: [Date] = []
            for i in 0..<2 {
                let daysToSubtract = i * 7
                dateComponents.day = -daysToSubtract
                if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday!) {
                    // Set the time components of the previousSunday to midnight (00:00:00)
                    let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                    previousSundays.append(startOfPreviousSunday)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // Format the previousSunday date to get the date in yyyy-MM-dd format
            let formattedDate = dateFormatter.string(from: previousSundays[previousSundays.count-1])
            
            let daysUntilSunday = calendar.component(.weekday, from: currentDate) - 1
            let mostRecentSunday = calendar.date(byAdding: .day, value: -daysUntilSunday, to: currentDate)!

            let formattedDate2 = dateFormatter.string(from: mostRecentSunday)
            
            onlyDates = "Date Range: \(formattedDate) to \(formattedDate2)"
        }
        else if date == "Last Month"
        {
            let calendar = Calendar.current
            let currentDate = Date()

            // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
            let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

            // Create date components with the calculated days to subtract
            var dateComponents = DateComponents()
            dateComponents.day = -daysToSubtract - 7

            let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate)

                // Calculate the dates for the previous two Sundays
            var previousSundays: [Date] = []
            for i in 0..<4 {
                let daysToSubtract = i * 7
                dateComponents.day = -daysToSubtract
                if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday!) {
                    // Set the time components of the previousSunday to midnight (00:00:00)
                    let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                    previousSundays.append(startOfPreviousSunday)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // Format the previousSunday date to get the date in yyyy-MM-dd format
            let formattedDate = dateFormatter.string(from: previousSundays[previousSundays.count-1])
            
            let daysUntilSunday = calendar.component(.weekday, from: currentDate) - 1
            let mostRecentSunday = calendar.date(byAdding: .day, value: -daysUntilSunday, to: currentDate)!

            let formattedDate2 = dateFormatter.string(from: mostRecentSunday)
            
            onlyDates = "Date Range: \(formattedDate) to \(formattedDate2)"
        }
        else if date == "Last Two Months"
        {
            let calendar = Calendar.current
            let currentDate = Date()

            // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
            let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

            // Create date components with the calculated days to subtract
            var dateComponents = DateComponents()
            dateComponents.day = -daysToSubtract - 7

            let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate)

                // Calculate the dates for the previous two Sundays
            var previousSundays: [Date] = []
            for i in 0..<8 {
                let daysToSubtract = i * 7
                dateComponents.day = -daysToSubtract
                if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday!) {
                    // Set the time components of the previousSunday to midnight (00:00:00)
                    let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                    previousSundays.append(startOfPreviousSunday)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // Format the previousSunday date to get the date in yyyy-MM-dd format
            let formattedDate = dateFormatter.string(from: previousSundays[previousSundays.count-1])
            
            let daysUntilSunday = calendar.component(.weekday, from: currentDate) - 1
            let mostRecentSunday = calendar.date(byAdding: .day, value: -daysUntilSunday, to: currentDate)!

            let formattedDate2 = dateFormatter.string(from: mostRecentSunday)
            
            onlyDates = "Date Range: \(formattedDate) to \(formattedDate2)"
        }
        else if date == "Last Year"
        {
            let calendar = Calendar.current
            let currentDate = Date()

            // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
            let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

            // Create date components with the calculated days to subtract
            var dateComponents = DateComponents()
            dateComponents.day = -daysToSubtract - 7

            let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate)

                // Calculate the dates for the previous two Sundays
            var previousSundays: [Date] = []
            for i in 0..<52 {
                let daysToSubtract = i * 7
                dateComponents.day = -daysToSubtract
                if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday!) {
                    // Set the time components of the previousSunday to midnight (00:00:00)
                    let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                    previousSundays.append(startOfPreviousSunday)
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            // Format the previousSunday date to get the date in yyyy-MM-dd format
            let formattedDate = dateFormatter.string(from: previousSundays[previousSundays.count-1])
            
            let daysUntilSunday = calendar.component(.weekday, from: currentDate) - 1
            let mostRecentSunday = calendar.date(byAdding: .day, value: -daysUntilSunday, to: currentDate)!

            let formattedDate2 = dateFormatter.string(from: mostRecentSunday)
            
            onlyDates = "Date Range: \(formattedDate) to \(formattedDate2)"
        }
        else
        {
            onlyDates = "Date Range: All Time"
        }
    }

    func getData(med: String, date: String)
    {
        viewConfirm = []
        if let id = UserDefaults.standard.object(forKey: "userid") as? String {
            let usersReference = database.child("caretaker").child(id)
            
            usersReference.observeSingleEvent(of: .value) { usersSnapshot in
                if usersSnapshot.exists() {
                    guard let usersData = usersSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let userID = usersData["caretakeeID"] as? String{
                        if date == "Last Week"
                        {
                            if med == "All Meds"
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)
                                
                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7
                                
                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7
                                
                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {
                                    // Create a date formatter to get just the date in yyyy-MM-dd format
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    // Format the lastSunday date to get the date in yyyy-MM-dd format
                                    let formattedDate = dateFormatter.string(from: lastSunday)

                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        // Clear the counts before populating the data for the current week
                                        var confirmedDose = 0
                                        var missedDose = 0
                                        

                                        for (_, medicineData) in userData {
                                            if let dateData = medicineData[formattedDate] {
                                                if let confirmedCount = dateData["confirmed"] as? Int{
                                                    confirmedDose += confirmedCount
                                                }
                                                if let missedCount = dateData["missed"] as? Int {
                                                    missedDose += missedCount
                                                }
                                            }
                                        }

                                        // Append the ViewConfirm after iterating through the data for the current week
                                        viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                        viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                        
                                        missed = missedDose
                                        conf = confirmedDose
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                let calendar = Calendar.current
                                let currentDate = Date()
                                
                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)
                                
                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7
                                
                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7
                                
                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {
                                    // Create a date formatter to get just the date in yyyy-MM-dd format
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    // Format the lastSunday date to get the date in yyyy-MM-dd format
                                    let formattedDate = dateFormatter.string(from: lastSunday)
                                    
                                    let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String:Any]] else {
                                            return
                                        }
                                        for (date, medicineData) in userData {
                                            if date == formattedDate, let confirmedCount = medicineData["confirmed"] as? Int {
                                                if date == formattedDate, let missedCount = medicineData["missed"] as? Int {
                                                    viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedCount))
                                                    viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedCount))
                                                    missed = missedCount
                                                    conf = confirmedCount
                                                }
                                            }
                                            
                                            
                                        }
                                    }
                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Two Weeks"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<2 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose += confirmedCount
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose += missedCount
                                                    }
                                                }
                                            }

                                            // Append the ViewConfirm after iterating through the data for each week
                                        }

                                        viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                        viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                        missed = missedDose
                                        conf = confirmedDose

                                        // Now you have the data for the previous two weeks in the viewConfirm array
                                        // You can use this data to display in your SwiftUI view or chart.
                                    }


                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }


                            }
                            else
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<2 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }

                                    for previousSunday in previousSundays {
                                        // Create a date formatter to get just the date in yyyy-MM-dd format
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        // Format the previousSunday date to get the date in yyyy-MM-dd format
                                        let formattedDate = dateFormatter.string(from: previousSunday)

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            

                                            for (date, medicineData) in userData {
                                                if date == formattedDate, let confirmedCount = medicineData["confirmed"] as? Int {
                                                    confirmedDose += confirmedCount
                                                }
                                                if date == formattedDate, let missedCount = medicineData["missed"] as? Int {
                                                    missedDose += missedCount
                                                }
                                            }

                                            viewConfirm = [ViewConfirm(type: "Confirmed", confirmed: confirmedDose),ViewConfirm(type: "Missed", confirmed: missedDose)]
                                            missed = missedDose
                                            conf = confirmedDose
                                        }
                                        
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }

                            }
                        }
                        else if date == "Last Month"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<4 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose += confirmedCount
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose += missedCount
                                                    }
                                                }
                                            }

                                            // Append the ViewConfirm after iterating through the data for each week
                                        }
                                        viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                        viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                        missed = missedDose
                                        conf = confirmedDose

                                        // Now you have the data for the previous two weeks in the viewConfirm array
                                        // You can use this data to display in your SwiftUI view or chart.
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }                }
                            else
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<4 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }

                                    for previousSunday in previousSundays {
                                        // Create a date formatter to get just the date in yyyy-MM-dd format
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        // Format the previousSunday date to get the date in yyyy-MM-dd format
                                        let formattedDate = dateFormatter.string(from: previousSunday)

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            

                                            for (date, medicineData) in userData {
                                                if date == formattedDate, let confirmedCount = medicineData["confirmed"] as? Int {
                                                    confirmedDose += confirmedCount
                                                }
                                                if date == formattedDate, let missedCount = medicineData["missed"] as? Int {
                                                    missedDose += missedCount
                                                }
                                            }

                                            viewConfirm = [ViewConfirm(type: "Confirmed", confirmed: confirmedDose),ViewConfirm(type: "Missed", confirmed: missedDose)]
                                            missed = missedDose
                                            conf = confirmedDose
                                        }
                                        
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Two Months"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<8 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose += confirmedCount
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose += missedCount
                                                    }
                                                }
                                            }

                                            // Append the ViewConfirm after iterating through the data for each week
                                        }
                                        viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                        viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                        missed = missedDose
                                        conf = confirmedDose

                                        // Now you have the data for the previous two weeks in the viewConfirm array
                                        // You can use this data to display in your SwiftUI view or chart.
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<8 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }

                                    for previousSunday in previousSundays {
                                        // Create a date formatter to get just the date in yyyy-MM-dd format
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        // Format the previousSunday date to get the date in yyyy-MM-dd format
                                        let formattedDate = dateFormatter.string(from: previousSunday)

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            

                                            for (date, medicineData) in userData {
                                                if date == formattedDate, let confirmedCount = medicineData["confirmed"] as? Int {
                                                    confirmedDose += confirmedCount
                                                }
                                                if date == formattedDate, let missedCount = medicineData["missed"] as? Int {
                                                    missedDose += missedCount
                                                }
                                            }

                                            viewConfirm = [ViewConfirm(type: "Confirmed", confirmed: confirmedDose),ViewConfirm(type: "Missed", confirmed: missedDose)]
                                            missed = missedDose
                                            conf = confirmedDose
                                        }
                                        
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else if date == "Last Year"
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (calendar.component(.weekday, from: currentDate) + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<52 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }
                                    
                                    let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                    reportsReference.observeSingleEvent(of: .value) { snapshot in
                                        guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                            return
                                        }

                                        for previousSunday in previousSundays {
                                            // Clear the counts before populating the data for each week

                                            // Create a date formatter to get just the date in yyyy-MM-dd format
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            // Format the previousSunday date to get the date in yyyy-MM-dd format
                                            let formattedDate = dateFormatter.string(from: previousSunday)

                                            for (_, medicineData) in userData {
                                                if let dateData = medicineData[formattedDate] {
                                                    if let confirmedCount = dateData["confirmed"] as? Int {
                                                        confirmedDose += confirmedCount
                                                    }
                                                    if let missedCount = dateData["missed"] as? Int {
                                                        missedDose += missedCount
                                                    }
                                                }
                                            }

                                            // Append the ViewConfirm after iterating through the data for each week
                                        }
                                        viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                        viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                        missed = missedDose
                                        conf = confirmedDose

                                        // Now you have the data for the previous two weeks in the viewConfirm array
                                        // You can use this data to display in your SwiftUI view or chart.
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                            else
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let calendar = Calendar.current
                                let currentDate = Date()

                                // Get the weekday component of the current date (1 is Sunday, 2 is Monday, etc.)
                                let currentWeekday = calendar.component(.weekday, from: currentDate)

                                // Calculate the number of days to subtract to get to the last Sunday (assuming Sunday is the first day of the week)
                                let daysToSubtract = (currentWeekday + 6) % 7

                                // Create date components with the calculated days to subtract
                                var dateComponents = DateComponents()
                                dateComponents.day = -daysToSubtract - 7

                                // Get the last Sunday by subtracting the date components from the current date
                                if let lastSunday = calendar.date(byAdding: dateComponents, to: currentDate) {

                                    // Calculate the dates for the previous two Sundays
                                    var previousSundays: [Date] = []
                                    for i in 0..<52 {
                                        let daysToSubtract = i * 7
                                        dateComponents.day = -daysToSubtract
                                        if let previousSunday = calendar.date(byAdding: dateComponents, to: lastSunday) {
                                            // Set the time components of the previousSunday to midnight (00:00:00)
                                            let startOfPreviousSunday = calendar.startOfDay(for: previousSunday)
                                            previousSundays.append(startOfPreviousSunday)
                                        }
                                    }

                                    for previousSunday in previousSundays {
                                        // Create a date formatter to get just the date in yyyy-MM-dd format
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        // Format the previousSunday date to get the date in yyyy-MM-dd format
                                        let formattedDate = dateFormatter.string(from: previousSunday)

                                        let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                                            guard let userData = snapshot.value as? [String: [String:Any]] else {
                                                return
                                            }

                                            // Clear the counts before populating the data for each week
                                            

                                            for (date, medicineData) in userData {
                                                if date == formattedDate, let confirmedCount = medicineData["confirmed"] as? Int {
                                                    confirmedDose += confirmedCount
                                                }
                                                if date == formattedDate, let missedCount = medicineData["missed"] as? Int {
                                                    missedDose += missedCount
                                                }
                                            }

                                            viewConfirm = [ViewConfirm(type: "Confirmed", confirmed: confirmedDose),ViewConfirm(type: "Missed", confirmed: missedDose)]
                                            missed = missedDose
                                            conf = confirmedDose
                                        }
                                        
                                    }

                                } else {
                                    print("Error: Unable to calculate the last Sunday.")
                                }
                            }
                        }
                        else
                        {
                            if med == "All Meds"
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let reportsReference = database.child("reports").child("\(userID)") // Query data under the specific userID
                                reportsReference.observeSingleEvent(of: .value) { snapshot in
                                    guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                        return
                                    }


                                    for (_, medicineData) in userData {
                                        for (_, dateData) in medicineData {
                                            if let confirmedCount = dateData["confirmed"] as? Int {
                                                confirmedDose += confirmedCount
                                            }
                                            if let missedCount = dateData["missed"] as? Int {
                                                missedDose += missedCount
                                            }

                                        }
                                    }

                                    // Append the ViewConfirm after iterating through all the data under the .child(userID) node
                                    viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                    viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                    missed = missedDose
                                    conf = confirmedDose
                                }
                            }
                            else
                            {
                                var confirmedDose = 0
                                var missedDose = 0
                                let reportsReference = database.child("reports").child("\(userID)").child(med) // Query data under the specific userID
                                reportsReference.observeSingleEvent(of: .value) { snapshot in
                                    guard let userData = snapshot.value as? [String: [String: Any]] else {
                                        return
                                    }


                                    for (_, medicineData) in userData {
                                        if let confirmedCount = medicineData["confirmed"] as? Int {
                                            confirmedDose += confirmedCount
                                        }
                                        if let missedCount = medicineData["missed"] as? Int {
                                            missedDose += missedCount
                                        }
                                    }

                                    // Append the ViewConfirm after iterating through all the data under the .child(userID) node
                                    viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: confirmedDose))
                                    viewConfirm.append(ViewConfirm(type: "Missed", confirmed: missedDose))
                                    missed = missedDose
                                    conf = confirmedDose
                                }
                            }
                        }
                        
                        
                    }
                }
            }
            
            
        }
    }
    
    
    func displayEmail(med: String, startDate: Date, endDate: Date, image: [UIImage])
    {
        if med == "All Meds"
        {
            email = ""
            let userID = UserDefaults.standard.string(forKey: "userid")!
            var confirmedDose = 0
            var missedDose = 0
            var marr: [String] = []
            var sarr: [String] = []
            
            var grandconfirmedDose = 0
            var grandmissedDose = 0
            var grandm: [String] = []
            var grands: [String] = []

            var adhance: Double = 0.0
            var adhancearr: [Double] = []
            
            var compareDate = Date()
            
            
            let usersReference = database.child("caretaker").child(userID)
            
            usersReference.observeSingleEvent(of: .value) { usersSnapshot in
                if usersSnapshot.exists() {
                    guard let usersData = usersSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let id = usersData["caretakeeID"] as? String
                    {
                        
                        
                        
                        let reportsReference = database.child("reports").child(id) // Query data under the specific userID
                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                            guard let userData = snapshot.value as? [String: [String: [String: Any]]] else {
                                return
                            }

                            for (name, medicineData) in userData {
                                email += "\(name):"
                                grandconfirmedDose = 0
                                grandmissedDose = 0
                                grandm = []
                                grands = []
                                adhancearr = []
                                for (date, dateData) in medicineData {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    dateFormatter.timeZone = TimeZone.current
                                    compareDate = dateFormatter.date(from: date) ?? Date()
                                    let startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                                    let compareDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: compareDate)
                                    let endDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
                                    
                                    if let startDate2 = Calendar.current.date(from: startDateComponents),
                                        let compareDate2 = Calendar.current.date(from: compareDateComponents),
                                        let endDate2 = Calendar.current.date(from: endDateComponents)
                                    {

                                        if compareDate2.compare(startDate2) == .orderedDescending || compareDate2.compare(startDate2) == .orderedSame{
                                            // date is after confirm
                                            if compareDate2.compare(endDate2) == .orderedAscending || compareDate2.compare(endDate2) == .orderedSame{
                                                marr = []
                                                sarr = []
                                                adhance = 0.0
                                                confirmedDose = 0
                                                missedDose = 0
                                                email += "\n\nWeek: \(date):"
                                                if let confirmedCount = dateData["confirmed"] as? Int {
                                                    confirmedDose += confirmedCount
                                                    grandconfirmedDose += confirmedCount
                                                    email += "\nConfirmed:\(confirmedCount)"
                                                }
                                                if let missedCount = dateData["missed"] as? Int {
                                                    missedDose += missedCount
                                                    grandmissedDose += missedCount
                                                    email += "\nMissed:\(missedCount)"
                                                }
                                                if let dates = dateData["misseddates"] as? [String] {
                                                    for i in dates
                                                    {
                                                        if i != "None"
                                                        {
                                                            marr.append(i)
                                                            grandm.append(i)
                                                        }
                                                    }
                                                    email += "\nMissed Dosage Dates: \(marr)"
                                                }
                                                
                                                if let dates = dateData["seniordates"] as? [String] {
                                                    for i in dates
                                                    {
                                                        if i != "None"
                                                        {
                                                            sarr.append(i)
                                                            grands.append(i)
                                                        }
                                                    }
                                                    email += "\nConfirmed Dosage Dates: \(sarr)"
                                                }
                                                
                                                adhance = Double(confirmedDose) / (Double(confirmedDose) + Double(missedDose)) * 100
                                                
                                                if adhance.isNaN
                                                {
                                                    adhance = 0.0
                                                }
                                                
                                                email += "\nMedical Adherance: \(adhance.rounded())%"
                                                adhancearr.append(adhance.rounded())
                                            }
                                        }
                                    }
                                    
                                }
                                
                                email += "\n\n*All Time \(name) Total:*\nConfirmed:\(grandconfirmedDose)\nMissed:\(grandmissedDose)\nMissed Dosage Dates: \(grandm)\nConfirmed Dates: \(grands)\n\n\n"
                                    
                            }
                            
                            emailController.sendEmail(inputImage: image)
                        }
                    }
                }
            }
        }
        else
        {
            email = ""
            let userID = UserDefaults.standard.string(forKey: "userid")!
            var confirmedDose = 0
            var missedDose = 0
            var marr: [String] = []
            var sarr: [String] = []
            
            var grandconfirmedDose = 0
            var grandmissedDose = 0
            var grandm: [String] = []
            var grands: [String] = []

            var adhance: Double = 0.0
            var adhancearr: [Double] = []
            
            var compareDate = Date()
            
            
            
            let usersReference = database.child("caretaker").child(userID)
            
            usersReference.observeSingleEvent(of: .value) { usersSnapshot in
                if usersSnapshot.exists() {
                    guard let usersData = usersSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let id = usersData["caretakeeID"] as? String
                    {
                        
                        let reportsReference = database.child("reports").child(id).child(med)
                        reportsReference.observeSingleEvent(of: .value) { snapshot in
                            guard let userData = snapshot.value as? [String: [String: Any]] else {
                                return
                            }

                            email += "\(med):"
                            grandconfirmedDose = 0
                            grandmissedDose = 0
                            grandm = []
                            grands = []
                            adhancearr = []
                            for (date, dateData) in userData {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                compareDate = dateFormatter.date(from: date) ?? Date()
                                if compareDate.compare(startDate) == .orderedDescending{
                                    // date is after confirm
                                    if compareDate.compare(endDate) == .orderedAscending{
                                        marr = []
                                        sarr = []
                                        adhance = 0.0
                                        confirmedDose = 0
                                        missedDose = 0
                                        email += "\n\nWeek: \(date):"
                                        if let confirmedCount = dateData["confirmed"] as? Int {
                                            confirmedDose += confirmedCount
                                            grandconfirmedDose += confirmedCount
                                            email += "\nConfirmed:\(confirmedCount)"
                                        }
                                        if let missedCount = dateData["missed"] as? Int {
                                            missedDose += missedCount
                                            grandmissedDose += missedCount
                                            email += "\nMissed:\(missedCount)"
                                        }
                                        if let dates = dateData["misseddates"] as? [String] {
                                            for i in dates
                                            {
                                                if i != "None"
                                                {
                                                    marr.append(i)
                                                    grandm.append(i)
                                                }
                                            }
                                            email += "\nMissed Dosage Dates: \(marr)"
                                        }
                                        
                                        if let dates = dateData["seniordates"] as? [String] {
                                            for i in dates
                                            {
                                                if i != "None"
                                                {
                                                    sarr.append(i)
                                                    grands.append(i)
                                                }
                                            }
                                            email += "\nConfirmed Dosage Dates: \(sarr)"
                                        }
                                        
                                        adhance = Double(confirmedDose) / (Double(confirmedDose) + Double(missedDose)) * 100
                                        
                                        if adhance.isNaN
                                        {
                                            adhance = 0.0
                                        }
                                        
                                        email += "\nMedical Adherance: \(adhance.rounded())%"
                                        adhancearr.append(adhance.rounded())
                                        
                                    }
                                }
                                
                            }
                            
                            
                            email += "\n\n*All Time \(med) Total:*\nConfirmed:\(grandconfirmedDose)\nMissed:\(grandmissedDose)\nMissed Dosage Dates: \(grandm)\nConfirmed Dates: \(grands)\n\n\n"
                            
                            
                            emailController.sendEmail(inputImage: image)
                        }
                    }
                }
            }
        }
    }
    
    func fetchMedicineRecords() {
        medicineRecords = ["All Meds"]
        viewConfirm.append(ViewConfirm(type: "Confirmed", confirmed: 0))
        viewConfirm.append(ViewConfirm(type: "Missed", confirmed: 0))
        if let userID = UserDefaults.standard.object(forKey: "userid") as? String {
            
            let usersReference = database.child("caretaker").child(userID)
            
            usersReference.observeSingleEvent(of: .value) { usersSnapshot in
                if usersSnapshot.exists() {
                    guard let usersData = usersSnapshot.value as? [String: Any] else {
                        return
                    }
                    
                    if let id = usersData["caretakeeID"] as? String{
                        let medicinesReference = database.child("medicines").child(id)
                        
                        medicinesReference.observeSingleEvent(of: .value) { snapshot in
                            guard let medicinesData = snapshot.value as? [String: [String: Any]] else {
                                return
                            }
                            
                            for (_, medicineData) in medicinesData {
                                if let did = medicineData["username"] as? String, did == id {
                                    if let medName = medicineData["medname"] as? String {
                                        medicineRecords.append(medName)
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

class EmailController: NSObject, MFMailComposeViewControllerDelegate, ObservableObject {
    @Published var canSendMail = false
    func sendEmail(inputImage: [UIImage]) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("PillNotify Medication Reports")
            
            for (index, image) in inputImage.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    mail.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "image\(index).jpg")
                }
            }
            
            
            mail.setMessageBody(email, isHTML: false)
            
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(mail, animated: true)
                }
            }
        } else {
            canSendMail = true
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error{
            controller.dismiss(animated: true)
        }
        
        // Handle the different result cases if needed
        switch result {
        case .sent:
            print ("sent")
        case .saved:
            print ("saved")
        case .cancelled:
            print ("canceled")
        case .failed:
            // Email composition failed
            if let error = error {
                print("Error composing email: \(error.localizedDescription)")
            }
        default:
            print ("none")
        }
        
        controller.dismiss(animated: true)
    }
}


struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}

struct CategorySum: Identifiable, Equatable {
    let sum: Double
    let category: Color
    
    var id: String { "\(category)\(sum)" }
}

struct ViewConfirm: Identifiable
{
    let id = UUID()
    let type: String
    let confirmed: Int
}

struct ViewAdherance: Identifiable
{
    let id = UUID()
    let date: String
    let percent: Double
    let name: String
}

