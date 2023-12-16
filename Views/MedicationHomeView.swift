//
//  MedicationHomeView.swift
//  PillNotify
//
//  Created by Amogh Bantwal on 7/12/23.
//

import SwiftUI
import MessageUI
import UserNotifications
import Combine
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

// This view shows the medications that a medicine taker inputs and schedules.
struct MedicationHomeView: View {
    private let numbers: [Int] = Array(1...3).map { Int($0) }
    private let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private let database = Database.database().reference()
    
    @State private var name = ""
    @State private var previousname = ""
    @State private var color = ""
    @State private var shape = ""
    @State private var amount = 0
    @State private var unit = "pills"
    @State private var secondunit = "pills"
    private let units: [String] = ["IU", "mcL", "mL", "mcg", "mg", "g", "tbsp", "oz", "fl oz", "tsp", "puffs", "pills", "injections", "gummies"]
    @State private var pillsleft = 0
    @State private var medname = ""
    
    @State private var fullname = ""
    @State private var apn = ""
    @State private var changeCount = false
    @State private var isActionSheetPresented = false
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var timeOfDay1M = Date()
    @State private var timeOfDay1Tu = Date()
    @State private var timeOfDay1W = Date()
    @State private var timeOfDay1Th = Date()
    @State private var timeOfDay1F = Date()
    @State private var timeOfDay1Sa = Date()
    @State private var timeOfDay1Su = Date()
    @State private var timeOfDay1Total = Date()

    @State private var timeOfDay2M = Date()
    @State private var timeOfDay2Tu = Date()
    @State private var timeOfDay2W = Date()
    @State private var timeOfDay2Th = Date()
    @State private var timeOfDay2F = Date()
    @State private var timeOfDay2Sa = Date()
    @State private var timeOfDay2Su = Date()
    @State private var timeOfDay2Total = Date()

    @State private var timeOfDay3M = Date()
    @State private var timeOfDay3Tu = Date()
    @State private var timeOfDay3W = Date()
    @State private var timeOfDay3Th = Date()
    @State private var timeOfDay3F = Date()
    @State private var timeOfDay3Sa = Date()
    @State private var timeOfDay3Su = Date()
    @State private var timeOfDay3Total = Date()

    @State private var timesADayM = 1
    @State private var timesADayTu = 1
    @State private var timesADayW = 1
    @State private var timesADayTh = 1
    @State private var timesADayF = 1
    @State private var timesADaySa = 1
    @State private var timesADaySu = 1
    @State private var timesADayTotal = 1
    
    @State private var image: Image? = Image(uiImage: UIImage())
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = UIImage()
    
    @State private var sheet = false
    @State private var sheet2 = false
    @State private var medPresentAlert = false
    @State private var medPresentAlert2 = false
    @State private var msgError = false
    @State private var deleteAlert = false
    @State private var isUpdating = false
    @State private var UID = ""
    
    @State private var count = 0
    @State private var countOfReminders = false
    
    @State private var everyday = false

    @State private var selectedDays: [String] = []

    @State private var lastconfirmed = ""
    
    @State private var confirm = false
    @State private var confirmingDate: [String] = []
    
    private var isAddButtonDisabled: Bool
    {
        if everyday
        {
            return [name, color, shape, unit, secondunit].contains(where:\.isEmpty) || amount <= 0 || pillsleft <= 0 || inputImage == UIImage()
        }
        else
        {
           return  [name, color, shape, unit, secondunit].contains(where:\.isEmpty) || amount <= 0 || pillsleft <= 0 || selectedDays.count == 0 || inputImage == UIImage()
        }
    }
    
    @State private var medicineRecords: [String: [String: Any]] = [:]
    
    @State private var reports: [String:Any] = [:]
    
    @State private var searchText = ""
    
    @State private var deleteButton = false
    
    var body: some View {
        ScrollView 
        {
            LazyVStack {
                HStack {
                    Button(action: {
                        deleteButton.toggle()
                    })
                    {
                        Label(deleteButton ? "Done" : "Delete Medicine" , systemImage: deleteButton ? "checkmark" : "trash")
                            .font(.custom("AmericanTypewriter-Bold", size: 17))
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                            .padding(.leading, 30)
                            .padding(.top, 15)
                    }
                    
                    Spacer()
                    Button(action: {
                        reset()
                        sheet = true
                        unit = "pills"
                        secondunit = "pills"
                    })
                    {
                        Label("Add Medicine", systemImage: "plus")
                            .font(.custom("AmericanTypewriter-Bold", size: 17))
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 5)
                            .padding(.trailing, 20)
                            .padding(.top, 15)
                    }
                    .sheet(isPresented: $sheet)
                    {
                        NavigationStack {
                            ZStack
                            {
                                Form
                                {
                                    Section(header: Text("Medicine Name (CAPS)"))
                                    {
                                        TextField("Medicine Name", text: $name)
                                            .autocorrectionDisabled(true)
                                            .textFieldStyle(.roundedBorder)
                                            .autocapitalization(.allCharacters)
                                        
                                    }
                                    
                                    Section(header: Text("Medicine Color"))
                                    {
                                        TextField("Medicine Color", text: $color)
                                            .autocorrectionDisabled(true)
                                            .textFieldStyle(.roundedBorder)
                                        
                                    }
                                    Section(header: Text("Medicine Shape"))
                                    {
                                        TextField("Medicine Shape", text: $shape)
                                            .autocorrectionDisabled(true)
                                            .textFieldStyle(.roundedBorder)
                                        
                                    }
                                    Section(header: Text("Dosage Amount"))
                                    {
                                        TextField("Dosage Amount", value: $amount, formatter: NumberFormatter())
                                            .textFieldStyle(.roundedBorder)
                                        
                                        Picker("Measurement Unit", selection: $unit)
                                        {
                                            ForEach(units, id:\.self)
                                            {
                                                Text("\($0)").tag("\($0)")
                                            }
                                        }
                                        
                                    }
                                    
                                    Section(header: Text("Medicine Supply Remaining"))
                                    {
                                        TextField("Dosage Remaining", value: $pillsleft, formatter: NumberFormatter())
                                            .textFieldStyle(.roundedBorder)
                                        
                                        Picker("Measurement Unit", selection: $secondunit)
                                        {
                                            if unit == "pills"
                                            {
                                                Text("pills").tag("pills")
                                                
                                            }
                                            else if unit == "puffs"
                                            {
                                                Text("puffs").tag("puffs")
                                                
                                            }
                                            else if unit == "injections"
                                            {
                                                Text("injections").tag("injections")
                                                
                                            }
                                            else if unit == "gummies"
                                            {
                                                Text("gummies").tag("gummies")
                                                
                                            }
                                            else
                                            {
                                                ForEach([unit, "pills", "puffs", "injections", "gummies"], id:\.self)
                                                {
                                                    Text("\($0)").tag("\($0)")
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    Section(header: Text("Days"))
                                    {
                                        Button(action: {
                                            selectedDays = []
                                            everyday.toggle()
                                        }) {
                                            HStack {
                                                Text("Everyday")
                                                Spacer()
                                                if everyday {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                        List {
                                            ForEach(days, id: \.self) { day in
                                                MultipleSelectionRow(title: day, isSelected: self.selectedDays.contains(day)) {
                                                    if let index = self.selectedDays.firstIndex(of: day) {
                                                        self.selectedDays.remove(at: index)
                                                    } else {
                                                        self.selectedDays.append(day)
                                                    }
                                                }
                                            }
                                        }
                                        .disabled(everyday)
                                    }
                                    
                                    List
                                    {
                                        if everyday
                                        {
                                            Picker("Number of Dosages:", selection: $timesADayTotal)
                                            {
                                                ForEach(numbers, id:\.self)
                                                {
                                                    Text("\($0)")
                                                }
                                            }
                                            
                                            if timesADayTotal == 1
                                            {
                                                DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                            }
                                            else if timesADayTotal == 2
                                            {
                                                DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                DatePicker("Dosage Time 2", selection: $timeOfDay2Total, displayedComponents: .hourAndMinute)
                                            }
                                            else
                                            {
                                                DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                DatePicker("Dosage Time 2", selection: $timeOfDay2Total, displayedComponents: .hourAndMinute)
                                                DatePicker("Dosage Time 3", selection: $timeOfDay3Total, displayedComponents: .hourAndMinute)
                                            }
                                        }
                                        else
                                        {
                                            ForEach(Array(selectedDays), id: \.self) { day in
                                                SetTimesView(timeDay1M: $timeOfDay1M, timeDay1Tu: $timeOfDay1Tu, timeDay1W: $timeOfDay1W, timeDay1Th: $timeOfDay1Th, timeDay1F: $timeOfDay1F, timeDay1Sa: $timeOfDay1Sa, timeDay1Su: $timeOfDay1Su, timeDay2M: $timeOfDay2M, timeDay2Tu: $timeOfDay2Tu, timeDay2W: $timeOfDay2W, timeDay2Th: $timeOfDay2Th, timeDay2F: $timeOfDay2F, timeDay2Sa: $timeOfDay2Sa, timeDay2Su: $timeOfDay2Su, timeDay3M: $timeOfDay3M, timeDay3Tu: $timeOfDay3Tu, timeDay3W: $timeOfDay3W, timeDay3Th: $timeOfDay3Th, timeDay3F: $timeOfDay3F, timeDay3Sa: $timeOfDay3Sa, timeDay3Su: $timeOfDay3Su, timesDayM: $timesADayM, timesDayTu: $timesADayTu, timesDayW: $timesADayW, timesDayTh: $timesADayTh, timesDayF: $timesADayF, timesDaySa: $timesADaySa, timesDaySu: $timesADaySu, days: day)
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                    Section(header: Text("Upload photo of medication (only you view this)"))
                                    {
                                        Button(action:{isActionSheetPresented = true}, label:{Text("Choose Photo")})
                                            .sheet(isPresented: $showingImagePicker) {
                                                ImagePicker(image: $inputImage, isShown: $showingImagePicker, sourceType: sourceType)
                                            }
                                            .actionSheet(isPresented: $isActionSheetPresented) {
                                                ActionSheet(
                                                    title: Text("Choose Photo"),
                                                    buttons: [
                                                        .default(Text("Take Photo")) {
                                                            
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                showingImagePicker = true
                                                            }
                                                            sourceType = .camera
                                                        },
                                                        .default(Text("Upload Photo")) {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                showingImagePicker = true
                                                            }
                                                            sourceType = .photoLibrary
                                                        },
                                                        .cancel()
                                                    ]
                                                )
                                            }
                                        
                                        image?
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .onChange(of: inputImage)
                                    {
                                        _ in loadImage()
                                    }
                                    
                                    Button(action: {
                                        addMedicine()
                                    }, label: {Text("Add Medication")})
                                    .disabled(isAddButtonDisabled)
                                    .alert(isPresented: $medPresentAlert2) {
                                        Alert(
                                            title: Text("Error!"),
                                            message: Text("Medicine already present"),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                    
                                }
                                .preferredColorScheme(.light)
                                .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                                .toolbarBackground(.visible, for: .navigationBar)
                                .toolbarColorScheme(.dark)
                                .navigationBarItems(
                                    trailing: Button(action: {
                                        sheet = false
                                    }) {
                                        Text("Dismiss")
                                            .bold()
                                            .foregroundStyle(.white)
                                    }
                                )
                                
                            }.navigationTitle("Add Medicine")
                        }
                    }
                }
                
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
                       let firstunit = medicineData["unit"] as? String,
                       let secondunit = medicineData["secondunit"] as? String
                    {
                        if searchText.isEmpty || medName.localizedCaseInsensitiveContains(searchText)
                        {
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 160)
                                .foregroundStyle(.white)
                                .cornerRadius(15.0)
                                .padding(.bottom, 3)
                                .shadow(color: .black, radius: 5)
                                .opacity(sheet2 ? 0.5 : 1)
                                .onTapGesture {
                                    isUpdating = false
                                    sheet2 = true
                                    previousname = medName
                                    everyday = false
                                    DispatchQueue.global().async {
                                        fillSheet(medname: medName)
                                    }
                                }
                                .overlay(
                                    HStack {
                                        if deleteButton {
                                            Button(action: {
                                                deleteItems(medicineId: medName)
                                            }, label: {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 45))
                                                    .padding(.trailing, 25)
                                                    .padding(.bottom, 20)
                                                    .foregroundStyle(Color.red.gradient)
                                                    .shadow(color: .red, radius: 5)
                                            })
                                        }
                                        else {
                                            Image(systemName: "pill.fill")
                                                .font(.system(size: 45))
                                                .padding(.trailing, 25)
                                                .padding(.bottom, 20)
                                                .foregroundStyle(Color(red: 0/255, green: 47/255, blue: 100/255))
                                                .shadow(color: .gray, radius: 5)
                                        }
                                        Rectangle()
                                            .frame(width: 1, height: 140)
                                            .foregroundStyle(.black)
                                            .cornerRadius(15.0)
                                            .padding(.bottom, 10)
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
                                            .foregroundColor(.blue)
                                            .sheet(isPresented: $sheet2) 
                                            {
                                                NavigationStack {
                                                    ZStack
                                                    {
                                                        if isUpdating {
                                                            ProgressView("Updating...")
                                                                .progressViewStyle(CircularProgressViewStyle())
                                                                .scaleEffect(1.3)
                                                        }
                                                        else
                                                        {
                                                            Form {
                                                                Section(header: Text("Medicine Name (CAPS)")) {
                                                                    TextField("Medicine Name", text: $name)
                                                                        .autocorrectionDisabled(true)
                                                                        .textFieldStyle(.roundedBorder)
                                                                        .autocapitalization(.allCharacters)
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Medicine Color")) {
                                                                    TextField("Medicine Color", text: $color)
                                                                        .autocorrectionDisabled(true)
                                                                        .textFieldStyle(.roundedBorder)
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Medicine Shape"))
                                                                {
                                                                    TextField("Medicine Shape", text: $shape)
                                                                        .autocorrectionDisabled(true)
                                                                        .textFieldStyle(.roundedBorder)
                                                                    
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Dosage Amount"))
                                                                {
                                                                    TextField("Dosage Amount", value: $amount, formatter: NumberFormatter())
                                                                        .textFieldStyle(.roundedBorder)
                                                                    
                                                                    Picker("Measurement Unit", selection: $unit)
                                                                    {
                                                                        ForEach(units, id:\.self)
                                                                        {
                                                                            Text("\($0)").tag("\($0)")
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                                
                                                                Section(header: Text("Medicine Supply Remaining"))
                                                                {
                                                                    TextField("Dosage Remaining", value: $pillsleft, formatter: NumberFormatter())
                                                                        .textFieldStyle(.roundedBorder)
                                                                    
                                                                    
                                                                    Picker("Measurement Unit", selection: $secondunit)
                                                                    {
                                                                        if unit == "pills"
                                                                        {
                                                                            Text("pills").tag("pills")
                                                                            
                                                                        }
                                                                        else if unit == "puffs"
                                                                        {
                                                                            Text("puffs").tag("puffs")
                                                                            
                                                                        }
                                                                        else if unit == "injections"
                                                                        {
                                                                            Text("injections").tag("injections")
                                                                            
                                                                        }
                                                                        else if unit == "gummies"
                                                                        {
                                                                            Text("gummies").tag("gummies")
                                                                            
                                                                        }
                                                                        else
                                                                        {
                                                                            ForEach([unit, "pills", "puffs", "injections", "gummies"], id:\.self)
                                                                            {
                                                                                Text("\($0)").tag("\($0)")
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                }
                                                                
                                                                
                                                                Section(header: Text("Days"))
                                                                {
                                                                    Button(action: {
                                                                        selectedDays = []
                                                                        everyday.toggle()
                                                                    }) {
                                                                        HStack {
                                                                            Text("Everyday")
                                                                            Spacer()
                                                                            if everyday {
                                                                                Image(systemName: "checkmark")
                                                                            }
                                                                        }
                                                                    }
                                                                    List {
                                                                        ForEach(days, id: \.self) { day in
                                                                            MultipleSelectionRow(title: day, isSelected: self.selectedDays.contains(day)) {
                                                                                if let index = self.selectedDays.firstIndex(of: day) {
                                                                                    self.selectedDays.remove(at: index)
                                                                                } else {
                                                                                    self.selectedDays.append(day)
                                                                                }
                                                                            }
                                                                        }
                                                                        .disabled(everyday)
                                                                    }
                                                                }
                                                                
                                                                List
                                                                {
                                                                    if everyday
                                                                    {
                                                                        Picker("Number of Dosages:", selection: $timesADayTotal)
                                                                        {
                                                                            ForEach(numbers, id:\.self)
                                                                            {
                                                                                Text("\($0)")
                                                                            }
                                                                        }
                                                                        
                                                                        if timesADayTotal == 1
                                                                        {
                                                                            DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                                        }
                                                                        else if timesADayTotal == 2
                                                                        {
                                                                            DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                                            DatePicker("Dosage Time 2", selection: $timeOfDay2Total, displayedComponents: .hourAndMinute)
                                                                        }
                                                                        else
                                                                        {
                                                                            DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                                            DatePicker("Dosage Time 2", selection: $timeOfDay2Total, displayedComponents: .hourAndMinute)
                                                                            DatePicker("Dosage Time 3", selection: $timeOfDay3Total, displayedComponents: .hourAndMinute)
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        ForEach(Array(selectedDays), id: \.self) { day in
                                                                            SetTimesView(timeDay1M: $timeOfDay1M, timeDay1Tu: $timeOfDay1Tu, timeDay1W: $timeOfDay1W, timeDay1Th: $timeOfDay1Th, timeDay1F: $timeOfDay1F, timeDay1Sa: $timeOfDay1Sa, timeDay1Su: $timeOfDay1Su, timeDay2M: $timeOfDay2M, timeDay2Tu: $timeOfDay2Tu, timeDay2W: $timeOfDay2W, timeDay2Th: $timeOfDay2Th, timeDay2F: $timeOfDay2F, timeDay2Sa: $timeOfDay2Sa, timeDay2Su: $timeOfDay2Su, timeDay3M: $timeOfDay3M, timeDay3Tu: $timeOfDay3Tu, timeDay3W: $timeOfDay3W, timeDay3Th: $timeOfDay3Th, timeDay3F: $timeOfDay3F, timeDay3Sa: $timeOfDay3Sa, timeDay3Su: $timeOfDay3Su, timesDayM: $timesADayM, timesDayTu: $timesADayTu, timesDayW: $timesADayW, timesDayTh: $timesADayTh, timesDayF: $timesADayF, timesDaySa: $timesADaySa, timesDaySu: $timesADaySu, days: day)
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                Section(header: Text("Upload photo of medication"))
                                                                {
                                                                    Button(action:{isActionSheetPresented = true}, label:{Text("Choose Photo")})
                                                                        .sheet(isPresented: $showingImagePicker) {
                                                                            ImagePicker(image: $inputImage, isShown: $showingImagePicker, sourceType: sourceType)
                                                                        }
                                                                        .actionSheet(isPresented: $isActionSheetPresented) {
                                                                            ActionSheet(
                                                                                title: Text("Choose Photo"),
                                                                                buttons: [
                                                                                    .default(Text("Take Photo")) {
                                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                                            showingImagePicker = true
                                                                                        }
                                                                                        sourceType = .camera
                                                                                    },
                                                                                    .default(Text("Upload Photo")) {
                                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                                            showingImagePicker = true
                                                                                        }
                                                                                        sourceType = .photoLibrary
                                                                                    },
                                                                                    .cancel()
                                                                                ]
                                                                            )
                                                                        }
                                                                    
                                                                    image?
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                }
                                                                .onChange(of: inputImage)
                                                                {
                                                                    _ in loadImage()
                                                                }
                                                                
                                                                
                                                                Button(action: {
                                                                    updateMedicine()
                                                                }, label: {
                                                                    Text("Update Medication")
                                                                })
                                                                .disabled(isAddButtonDisabled)
                                                                .alert(isPresented: $medPresentAlert) {
                                                                    Alert(
                                                                        title: Text("Error!"),
                                                                        message: Text("Medicine already present"),
                                                                        dismissButton: .default(Text("OK"))
                                                                    )
                                                                }
                                                            }
                                                            .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                                                            .toolbarBackground(.visible, for: .navigationBar)
                                                            .toolbarColorScheme(.dark)
                                                            .navigationBarItems(
                                                                trailing: Button(action: {
                                                                    sheet2 = false
                                                                }) {
                                                                    Text("Dismiss").bold().foregroundStyle(.white)
                                                                }
                                                            )
                                                            .navigationTitle("Update Medicine")
                                                            .preferredColorScheme(.light)
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            Text("Shape: \(medShape)")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                            Text("Color: \(medColor)")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                            Text("Dosage: \(medAmount) \(firstunit)")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                            Text("Medicine Remaining: \(medReminaing) \(secondunit)")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                                .padding(.bottom, 20)
                                        }
                                })
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 50)
                                .foregroundStyle(.green)
                                .cornerRadius(15.0)
                                .padding(.bottom, 30)
                                .shadow(color: .white, radius: 5)
                                .opacity(sheet2 ? 0.5 : 1)
                                .onTapGesture {
                                    isUpdating = false
                                    sheet2 = true
                                    previousname = medName
                                    everyday = false
                                    DispatchQueue.global().async {
                                        fillSheet(medname: medName)
                                    }
                                }
                                .overlay(
                                    HStack {
                                        Button(action: {
                                            deleteAlert = false
                                            confirmMed(med: medName)
                                            
                                        }, label:{
                                            Text("Confirm Today's \(medName)")
                                                .foregroundStyle(.white)
                                                .font(.custom("AmericanTypewriter-Bold", size: 20))
                                                .shadow(color: .white, radius: 5)
                                                .padding(.bottom, 30)
                                        }).foregroundColor(Color.blue)
                                            .alert(isPresented: $msgError) {
                                                if deleteAlert == true
                                                {
                                                    return Alert(
                                                        title: Text("Confirmation Error"),
                                                        message: Text("You have either confirmed \(medname) today already, or you are not scheduled to take any meds today"),
                                                        dismissButton: .default(Text("OK"))
                                                    )
                                                }
                                                if confirm == true
                                                {
                                                    let confirmingDateText = confirmingDate.map { "\($0)" }.joined(separator: ", ")
                                                    return Alert(
                                                        title: Text("Success"),
                                                        message: Text("Medicine scheduled at \(confirmingDateText) has been confirmed"),
                                                        dismissButton: .default(Text("OK"))
                                                    )
                                                }
                                                else
                                                {
                                                    return Alert(
                                                        title: Text("Error!"),
                                                        message: Text("Not enough pills!"),
                                                        dismissButton: .default(Text("OK"))
                                                    )
                                                }
                                                
                                            }
                                    }
                                )
                            
                        }
                    }
                }
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width - 20, height: 100)
                    .foregroundStyle(.white)
                    .cornerRadius(15.0)
                    .shadow(color: .black, radius: 5)
                    .opacity(sheet ? 0.5 : 1)
                    .onTapGesture {
                        sheet = true
                        DispatchQueue.global().async {
                            reset()
                            sheet = true
                            unit = "pills"
                            secondunit = "pills"
                        }
                    }
                    .overlay(
                        Button(action: {
                            reset()
                            sheet = true
                            unit = "pills"
                            secondunit = "pills"
                        })
                        {
                            HStack
                            {
                                Spacer()
                                Image(systemName: "plus")
                                    .frame(width: 60, height: 60) // Increase the frame size for a larger circle
                                    .background(Circle().foregroundColor(Color(red: 0/255, green: 47/255, blue: 100/255))) // Create a circular background
                                    .foregroundColor(.white) // Set the color of the plus sign
                                    .font(.system(size: 30, weight: .bold)) // Adjust the font size and weight of the plus sign
                                    .shadow(color:.white, radius: 10)
                                Spacer()
                            }
                        }
                        .sheet(isPresented: $sheet)
                        {
                            NavigationStack
                            {
                                ZStack {
                                    Form
                                    {
                                        Section(header: Text("Medicine Name (CAPS)"))
                                        {
                                            TextField("Medicine Name", text: $name)
                                                .autocorrectionDisabled(true)
                                                .textFieldStyle(.roundedBorder)
                                                .autocapitalization(.allCharacters)
                                            
                                        }
                                        
                                        Section(header: Text("Medicine Color"))
                                        {
                                            TextField("Medicine Color", text: $color)
                                                .autocorrectionDisabled(true)
                                                .textFieldStyle(.roundedBorder)
                                            
                                        }
                                        Section(header: Text("Medicine Shape"))
                                        {
                                            TextField("Medicine Shape", text: $shape)
                                                .autocorrectionDisabled(true)
                                                .textFieldStyle(.roundedBorder)
                                            
                                        }
                                        Section(header: Text("Dosage Amount"))
                                        {
                                            TextField("Dosage Amount", value: $amount, formatter: NumberFormatter())
                                                .textFieldStyle(.roundedBorder)
                                            
                                            Picker("Measurement Unit", selection: $unit)
                                            {
                                                ForEach(units, id:\.self)
                                                {
                                                    Text("\($0)").tag("\($0)")
                                                }
                                            }
                                            
                                        }
                                        
                                        Section(header: Text("Medicine Supply Remaining"))
                                        {
                                            TextField("Dosage Remaining", value: $pillsleft, formatter: NumberFormatter())
                                                .textFieldStyle(.roundedBorder)
                                            
                                            Picker("Measurement Unit", selection: $secondunit)
                                            {
                                                if unit == "pills"
                                                {
                                                    Text("pills").tag("pills")
                                                    
                                                }
                                                else if unit == "puffs"
                                                {
                                                    Text("puffs").tag("puffs")
                                                    
                                                }
                                                else if unit == "injections"
                                                {
                                                    Text("injections").tag("injections")
                                                    
                                                }
                                                else if unit == "gummies"
                                                {
                                                    Text("gummies").tag("gummies")
                                                    
                                                }
                                                else
                                                {
                                                    ForEach([unit, "pills", "puffs", "injections", "gummies"], id:\.self)
                                                    {
                                                        Text("\($0)").tag("\($0)")
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                        
                                        Section(header: Text("Days"))
                                        {
                                            Button(action: {
                                                selectedDays = []
                                                everyday.toggle()
                                            }) {
                                                HStack {
                                                    Text("Everyday")
                                                    Spacer()
                                                    if everyday {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                            List {
                                                ForEach(days, id: \.self) { day in
                                                    MultipleSelectionRow(title: day, isSelected: self.selectedDays.contains(day)) {
                                                        if let index = self.selectedDays.firstIndex(of: day) {
                                                            self.selectedDays.remove(at: index)
                                                        } else {
                                                            self.selectedDays.append(day)
                                                        }
                                                    }
                                                }
                                                .disabled(everyday)
                                            }
                                        }
                                        
                                        List
                                        {
                                            if everyday
                                            {
                                                Picker("Number of Dosages:", selection: $timesADayTotal)
                                                {
                                                    ForEach(numbers, id:\.self)
                                                    {
                                                        Text("\($0)")
                                                    }
                                                }
                                                
                                                if timesADayTotal == 1
                                                {
                                                    DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                }
                                                else if timesADayTotal == 2
                                                {
                                                    DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                    DatePicker("Dosage Time 2", selection: $timeOfDay2Total, displayedComponents: .hourAndMinute)
                                                }
                                                else
                                                {
                                                    DatePicker("Dosage Time 1", selection: $timeOfDay1Total, displayedComponents: .hourAndMinute)
                                                    DatePicker("Dosage Time 2", selection: $timeOfDay2Total, displayedComponents: .hourAndMinute)
                                                    DatePicker("Dosage Time 3", selection: $timeOfDay3Total, displayedComponents: .hourAndMinute)
                                                }
                                            }
                                            else
                                            {
                                                ForEach(Array(selectedDays), id: \.self) { day in
                                                    SetTimesView(timeDay1M: $timeOfDay1M, timeDay1Tu: $timeOfDay1Tu, timeDay1W: $timeOfDay1W, timeDay1Th: $timeOfDay1Th, timeDay1F: $timeOfDay1F, timeDay1Sa: $timeOfDay1Sa, timeDay1Su: $timeOfDay1Su, timeDay2M: $timeOfDay2M, timeDay2Tu: $timeOfDay2Tu, timeDay2W: $timeOfDay2W, timeDay2Th: $timeOfDay2Th, timeDay2F: $timeOfDay2F, timeDay2Sa: $timeOfDay2Sa, timeDay2Su: $timeOfDay2Su, timeDay3M: $timeOfDay3M, timeDay3Tu: $timeOfDay3Tu, timeDay3W: $timeOfDay3W, timeDay3Th: $timeOfDay3Th, timeDay3F: $timeOfDay3F, timeDay3Sa: $timeOfDay3Sa, timeDay3Su: $timeOfDay3Su, timesDayM: $timesADayM, timesDayTu: $timesADayTu, timesDayW: $timesADayW, timesDayTh: $timesADayTh, timesDayF: $timesADayF, timesDaySa: $timesADaySa, timesDaySu: $timesADaySu, days: day)
                                                    
                                                }
                                            }
                                        }
                                        
                                        
                                        Section(header: Text("Upload photo of medication"))
                                        {
                                            Button(action:{isActionSheetPresented = true}, label:{Text("Choose Photo")})
                                                .sheet(isPresented: $showingImagePicker) {
                                                    ImagePicker(image: $inputImage, isShown: $showingImagePicker, sourceType: sourceType)
                                                }
                                                .actionSheet(isPresented: $isActionSheetPresented) {
                                                    ActionSheet(
                                                        title: Text("Choose Photo"),
                                                        buttons: [
                                                            .default(Text("Take Photo")) {
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                    showingImagePicker = true
                                                                }
                                                                sourceType = .camera
                                                            },
                                                            .default(Text("Upload Photo")) {
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                    showingImagePicker = true
                                                                }
                                                                sourceType = .photoLibrary
                                                            },
                                                            .cancel()
                                                        ]
                                                    )
                                                }
                                            
                                            image?
                                                .resizable()
                                                .scaledToFit()
                                        }
                                        .onChange(of: inputImage)
                                        {
                                            _ in loadImage()
                                        }
                                        
                                        Button(action: {
                                            addMedicine()
                                        }, label: {Text("Add Medication")})
                                        .disabled(isAddButtonDisabled)
                                        .alert(isPresented: $medPresentAlert2) {
                                            Alert(
                                                title: Text("Error!"),
                                                message: Text("Medicine already present"),
                                                dismissButton: .default(Text("OK"))
                                            )
                                        }
                                        
                                    }
                                    .preferredColorScheme(.light)
                                    .toolbarBackground(Color(red: 0/255, green: 47/255, blue: 100/255), for: .navigationBar)
                                    .toolbarBackground(.visible, for: .navigationBar)
                                    .toolbarColorScheme(.dark)
                                    .navigationBarItems(
                                        trailing: Button(action: {
                                            sheet = false
                                        }) {
                                            Text("Dismiss").bold()
                                                .foregroundStyle(.white)
                                        }
                                    )
                                }
                                .navigationTitle("Add Medicine")
                                
                            }
                        }
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
        }
        
        
    }
    
    // This method shows the image that the medicine taker uploads as they are adding a medicine or
    // updating medicine
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    // This method retrieves the UserID of the logged in medicine taker and assign it to a global variable
    func getAuthenticatedUserUID() {
        if let currentUser = Auth.auth().currentUser {
            UID = currentUser.uid
            print("Authenticated user UID: \(UID)")
        } else {
            print("No user is currently logged in.")
        }
    }
    
    // This method gets the date of the most recent sunday. THis will be used for when the user adds a medication and
    // we it automatically creates a reports record with the current's week report. Ex: medicine taker scheules a med on Dec 11, 2023,
    // then this method will return Sunday Dec 10, 2023
    func getStartAndEndDateOfCurrentWeek() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        var startOfWeek: Date = Date()
        var interval: TimeInterval = 0
        guard calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: Date()) else {
            return nil
        }
        
        let endOfWeek = startOfWeek.addingTimeInterval(interval - 1)
        
        // Set the time component to midnight for both start and end dates to get the whole day.
        if let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startOfWeek),
           let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek) {
            return (startDate, endDate)
        }
        
        return nil
    }
    
    // This method takes in a message and a APNS token of someone's phone and sends them a Firebase Push Notication
    // from the app with a custom message
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
    
    // This method deletes a medicine that the user chooses from the list of medicine they have scheduled
    // It then delets any images associated with the medicine and reports. It also reconfigures all the UNUserNotifications
    // since you dont want notifications for the deleted medicine to start showing.
    func deleteItems(medicineId: String) {
        
        let username = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        
        let medicineReference = database.child("medicines").child(username)
        
        var fullname = ""
        var apn = ""
        
        // Delete the medicine record from Firebase
        medicineReference.child(medicineId.uppercased()).removeValue { error, _ in
            if let error = error {
                print("Failed to delete medicine: \(error.localizedDescription)")
            } else {
                print("Medicine deleted successfully")
                var picname = medicineId.replacingOccurrences(of: " ", with: "-") // this is so that if the user enters any spaces or backslashes, then when we query from firebase storage, nothing will error
                picname = picname.replacingOccurrences(of: "\\", with: "")

                let imageDatabase = Storage.storage().reference().child("images").child(username).child("\(picname.uppercased()).jpg")

                // Delete the file
                imageDatabase.delete { error in
                    if let error = error {
                        // Handle the error case
                        print("Failed to delete file: \(error.localizedDescription)")
                    } else {
                        // File deleted successfully
                        print("File deleted successfully")
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        sendMessage2()
                        fetchMedicineRecords()
                        
                        let reportsReference = database.child("reports").child(username).child(medicineId.uppercased())
                        reportsReference.removeValue { error, _ in
                            if let error = error {
                                print("Failed to delete report: \(error.localizedDescription)")
                            } else {
                                print ("Successful deleted report")
                                let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                
                                let usersReference = database.child("users").child(username)
                                usersReference.observeSingleEvent(of: .value) { snapshot in
                                    if snapshot.exists() {
                                        guard let usersData = snapshot.value as? [String: Any] else {
                                            return
                                        }
                                        
                                        fullname = UserDefaults.standard.string(forKey: "fname")!
                                        
                                        if let apns = usersData["apnsid"] as? String {
                                            apn = apns
                                        }
                                        
                                        if ap != apn
                                        {
                                            sendPushNotification(body: "\(fullname) has deleted \(medicineId.uppercased()).", subtitle: "Deleted Medication", phoneId: apn)
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
        
        medicineRecords.removeValue(forKey: medicineId)
        // Remove the deleted medicines from the local `medicineRecords` dictionary
    }
    
    // This method updates the reports database for each medicine that a user confirms.
    // It updates the date and time of the day the user confirm their med.
    func updateReports(med: String, date: [String])
    {
        let calendar = Calendar.current
        let currentDate = Date()
        
        var stringDates: [String] = []
        
        for i in date
        {
            stringDates.append(i)
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
            let id = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
            
            var missedCount = 0
            var confirmedCount = 0
            var missedDates: [String] = []
            var confirmedDates: [String] = []
            

            let reportsReference = database.child("reports").child(id).child(med).child(formattedDate)
            reportsReference.observeSingleEvent(of: .value) { snapshot in
                guard let reportsData = snapshot.value as? [String: Any] else {
                    let reportsReference2 = database.child("reports").child(id).child(med).child(formattedDate)
                    
                    let reports2: [String: Any] = ["confirmed": stringDates.count, "missed":0, "misseddates": ["None"], "seniordates": stringDates]
                    
                    let updatedData: [String: Any] = reports2
                    
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
                
                if let datesS = reportsData["seniordates"] as? [String] {
                    confirmedDates = datesS
                    for i in stringDates
                    {
                        confirmedDates.append(i)
                    }
                }
                if let datesM = reportsData["misseddates"] as? [String] {
                    missedDates = datesM
                }
                if let confirmedd = reportsData["confirmed"] as? Int {
                    confirmedCount = confirmedd
                }
                if let missedd = reportsData["missed"] as? Int {
                    missedCount = missedd
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
                        print("Failed to update medicine: \(error.localizedDescription)")
                    }
                }
                
            }
            
            
        }
    }
    
    // This method confirms the medicine that the user said to Siri. It runs through edge cases such as if the user confirms twice,
    // if the user wants to confirm their dose early, if they confirm late, if they update a medicine time after confirming their med
    func confirmMed(med: String)
    {
        var picname = med.replacingOccurrences(of: " ", with: "-")
        picname = picname.replacingOccurrences(of: "\\", with: "")
        confirm = false
        countOfReminders = false
        medname = med
        var repeats = false
        var updateReportsCount = false
        confirmingDate = []
        let user = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        var fullname = ""
        var apn = ""
        var confirmTime = Date()
        var dates: [Int: [Int: Date]] = [:]
        var idcount = 1
        let usersReference = database.child("users").child(user)
        usersReference.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let usersData = snapshot.value as? [String: Any] else {
                    return
                }
                
                fullname += UserDefaults.standard.string(forKey: "fname")!
                fullname += " "
                fullname += UserDefaults.standard.string(forKey: "lname")!
                if let id = usersData["apnsid"] as? String {
                    apn = id
                }
            } else {
                print("No data found in users node")
            }
        }
        
        
        let medicineDatabase = database.child("medicines").child(user).child(med)
        medicineDatabase.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let medicineData = snapshot.value as? [String: Any] {
                if let medicineName = medicineData["medname"] as? String, medicineName == med {
                    if let medcolor = medicineData["medcolor"] as? String
                    {
                        color = medcolor
                    }
                    if let medshape = medicineData["medshape"] as? String
                    {
                        shape = medshape
                    }
                    
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
                                countOfReminders = true
                                confirmingDate.append(dateToString(count: dateWithSameTime))
                            }

                        }
                
                    }
                    
                    let medicinesReference = database.child("medicines").child(user)
                    let medicineQuery = medicinesReference.queryOrdered(byChild: "medname").queryEqual(toValue: med)
                    medicineQuery.observeSingleEvent(of: .value) { snapshot in
                        var shouldUpdateMedicine = false
                        
                        if snapshot.exists() {
                            // Medication name already exists, check if it belongs to the same username
                            if let data = snapshot.value as? [String: [String: Any]] {
                                for (_, medicineData) in data {
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
                                        msgError = true
                                        let content = UNMutableNotificationContent()
                                        content.title = "PillNotify"
                                        content.subtitle = "Refill"
                                        content.body = "Hi, \(fullname), you have no supply left for \(med). Please make sure you or your caretaker refill it."
                                        content.sound = UNNotificationSound.default
                                        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                        
                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                        
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
                                        let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                        if ap != apn
                                        {
                                            sendPushNotification(body: "Hey! it looks like \(fullname) tried to confirm \(med) for \(remind), but ran out of supply. Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                        }
                                    }
                                    else if unit == "pills" || unit == "puffs" || unit == "injections" || unit == "gummies"
                                    {
                                        if pillsleft - amount < 0
                                        {
                                            msgError = true
                                            let content = UNMutableNotificationContent()
                                            content.title = "PillNotify"
                                            content.subtitle = "Refill"
                                            content.body = "Hi, \(fullname), you don't have enough supply to confirm \(med). Please make sure you or your caretaker refill it."
                                            content.sound = UNNotificationSound.default
                                            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                            
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                            
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
                                            let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                            if ap != apn
                                            {
                                                sendPushNotification(body: "Hey! it looks like \(fullname) doesn't have enough supply for \(med) to confirm at \(remind). Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                            }
                                        }
                                        else
                                        {
                                            if updateReportsCount == false && repeats == true
                                            {
                                                updateReports(med: med, date: confirmingDate)
                                                updateReportsCount = true
                                            }
                                            
                                            pillsleft -= amount
                                            count += 1
                                            
                                            let medicineRef = database.child("medicines").child(user).child(med)
                                            let updatedData: [String: Any] = [
                                                "remaining": pillsleft,
                                                "count": count,
                                                "lastconfirm": remind
                                            ]
                                            
                                            
                                            
                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                if let error = error {
                                                    // Handle the error case
                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                } else {
                                                    fetchMedicineRecords()
                                                    
                                                    if (pillsleft / amount >= 0) && (pillsleft / amount <= 10)
                                                    {
                                                        
                                                        let imageDatabase = Storage.storage().reference().child("images").child(user).child("\(picname).jpg")
                                                        
                                                        imageDatabase.downloadURL { (url, error) in
                                                            if let error = error {
                                                                // Handle the error case
                                                                print("Failed to retrieve download URL: \(error.localizedDescription)")
                                                                return
                                                            }
                                                            
                                                            guard let downloadURL = url else {
                                                                // Handle the case where download URL is nil
                                                                print ("download URL is nil")
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
                                                                            content.body = "Hi, \(fullname), you're supply for \(med) is low. \(pillsleft) \(secondunit) left."
                                                                            content.sound = UNNotificationSound.default
                                                                            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                                                            
                                                                            // Get the UIImage from your source, e.g. the camera roll
                                                                            let image = inputImage
                                                                            let uuid = UUID().uuidString
                                                                            let filename = "\(uuid).jpg"
                                                                            
                                                                            // Compress the image data to reduce the file size
                                                                            if let compressedImageData = image!.jpegData(compressionQuality: 0.5) {
                                                                                
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
                                                                            
                                                                            
                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                                                            
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
                                                                            let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                                                            if ap != apn
                                                                            {
                                                                                sendPushNotification(body: "Hey! \(fullname) is running low on supply for \(med). \(pillsleft) \(secondunit) left.", subtitle: "Refill Medications", phoneId: apn)
                                                                            }

                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                // Handle the case where image URL is invalid
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                    print("Medicine updated successfully")
                                                    /*
                                                    let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                                    if ap != apn
                                                    {
                                                        if repeats == true
                                                        {
                                                            sendPushNotification(body: "\(fullname) has confirmed thier \(remind) dose for \(med). \(pillsleft) \(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                        }
                                                        else
                                                        {
                                                            sendPushNotification(body: "\(fullname) has confirmed thier \(remind) dose for \(med) late. \(pillsleft) \(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                        }
                                                    }
                                                     */
                                                    msgError = true
                                                    confirm = true
                                                }
                                            }
                                        }
                                        
                                    }
                                    else if (unit != "pills" && unit != "puffs" && unit != "injections" && unit != "gummies") && (secondunit != "pills" && secondunit != "puffs" && secondunit != "injections" && secondunit != "gummies")
                                    {
                                        if pillsleft - amount < 0
                                        {
                                            msgError = true
                                            let content = UNMutableNotificationContent()
                                            content.title = "PillNotify"
                                            content.subtitle = "Refill"
                                            content.body = "Hi, \(fullname), you don't have enough supply to confirm \(med). Please make sure you or your caretaker refill it."
                                            content.sound = UNNotificationSound.default
                                            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                            
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                            
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
                                            let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                            if ap != apn
                                            {
                                                sendPushNotification(body: "Hey! it looks like \(fullname) doesn't have enough supply for \(med) to confirm at \(remind). Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                            }
                                        }
                                        else
                                        {
                                            if updateReportsCount == false && repeats == true
                                            {
                                                updateReports(med: med, date: confirmingDate)
                                                updateReportsCount = true
                                            }
                                            
                                            pillsleft -= amount
                                            count += 1
                                            
                                            let medicineRef = database.child("medicines").child(user).child(med)
                                            let updatedData: [String: Any] = [
                                                "remaining": pillsleft,
                                                "count": count,
                                                "lastconfirm": remind
                                            ]
                                            
                                            
                                            
                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                if let error = error {
                                                    // Handle the error case
                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                } else {
                                                    fetchMedicineRecords()
                                                    
                                                    if (pillsleft / amount >= 0) && (pillsleft / amount <= 10)
                                                    {
                                                        
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
                                                                            content.body = "Hi, \(fullname), you're supply for \(med) is low. \(pillsleft) \(secondunit) left."
                                                                            content.sound = UNNotificationSound.default
                                                                            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                                                            
                                                                            // Get the UIImage from your source, e.g. the camera roll
                                                                            let image = inputImage
                                                                            let uuid = UUID().uuidString
                                                                            let filename = "\(uuid).jpg"
                                                                            
                                                                            // Compress the image data to reduce the file size
                                                                            if let compressedImageData = image!.jpegData(compressionQuality: 0.5) {
                                                                                
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
                                                                            
                                                                            
                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                                                            
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
                                                                            let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                                                            if ap != apn
                                                                            {
                                                                                sendPushNotification(body: "Hey! \(fullname) is running low on supply for \(med). \(pillsleft) \(secondunit) left.", subtitle: "Refill Medications", phoneId: apn)
                                                                            }

                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                // Handle the case where image URL is invalid
                                                                print ("invalud URL")
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                    print("Medicine updated successfully")
                                                    /*
                                                    let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                                    if ap != apn
                                                    {
                                                        if repeats == true
                                                        {
                                                            sendPushNotification(body: "\(fullname) has confirmed thier \(remind) dose for \(med). \(pillsleft) \(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                        }
                                                        else
                                                        {
                                                            sendPushNotification(body: "\(fullname) has confirmed thier \(remind) dose for \(med) late. \(pillsleft) \(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                        }
                                                    }
                                                     */
                                                    msgError = true
                                                    confirm = true
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if pillsleft - 1 < 0
                                        {
                                            msgError = true
                                            let content = UNMutableNotificationContent()
                                            content.title = "PillNotify"
                                            content.subtitle = "Refill"
                                            content.body = "Hi, \(fullname), you don't have enough supply to confirm \(med). Please make sure you or your caretaker refill it."
                                            content.sound = UNNotificationSound.default
                                            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                            
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                            
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
                                            let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                            if ap != apn
                                            {
                                                sendPushNotification(body: "Hey! it looks like \(fullname) doesn't have enough supply for \(med) to confirm at \(remind). Please make sure to refill it.", subtitle: "Refill Medications", phoneId: apn)
                                            }
                                        }
                                        else
                                        {
                                            
                                            if updateReportsCount == false && repeats == true
                                            {
                                                updateReports(med: med, date: confirmingDate)
                                                updateReportsCount = true
                                            }
                                            
                                            pillsleft -= 1
                                            count += 1
                                            
                                            let medicineRef = database.child("medicines").child(user).child(med)
                                            let updatedData: [String: Any] = [
                                                "remaining": pillsleft,
                                                "count": count,
                                                "lastconfirm": remind
                                            ]
                                            
                                            
                                            
                                            medicineRef.updateChildValues(updatedData) { error, _ in
                                                if let error = error {
                                                    // Handle the error case
                                                    print("Failed to update medicine: \(error.localizedDescription)")
                                                } else {
                                                    fetchMedicineRecords()
                                                    
                                                    if (pillsleft / amount >= 0) && (pillsleft / amount <= 10)
                                                    {
                                                        
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
                                                                            content.body = "Hi, \(fullname), you're supply for \(med) is low. \(pillsleft) \(secondunit) left."
                                                                            content.sound = UNNotificationSound.default
                                                                            content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                                                            
                                                                            // Get the UIImage from your source, e.g. the camera roll
                                                                            let image = inputImage
                                                                            let uuid = UUID().uuidString
                                                                            let filename = "\(uuid).jpg"
                                                                            
                                                                            // Compress the image data to reduce the file size
                                                                            if let compressedImageData = image!.jpegData(compressionQuality: 0.5) {
                                                                                
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
                                                                            
                                                                            
                                                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                                                            
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
                                                                            let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                                                            if ap != apn
                                                                            {
                                                                                sendPushNotification(body: "Hey! \(fullname) is running low on supply for \(med). \(pillsleft) \(secondunit) left.", subtitle: "Refill Medications", phoneId: apn)
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                // Handle the case where image URL is invalid
                                                                print ("invalid URL")
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                    print("Medicine updated successfully")
                                                    /*
                                                    let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                                                    if ap != apn
                                                    {
                                                        if repeats == true
                                                        {
                                                            sendPushNotification(body: "\(fullname) has confirmed thier \(remind) dose for \(med). \(pillsleft) \(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                        }
                                                        else
                                                        {
                                                            sendPushNotification(body: "\(fullname) has confirmed thier \(remind) dose for \(med) late. \(pillsleft) \(secondunit) left.", subtitle: "Medication Confirmation", phoneId: apn)
                                                        }
                                                    }
                                                     */
                                                    msgError = true
                                                    confirm = true
                                                }
                                            }
                                        }

                                    }
                                }
                            }
                            else
                            {
                                msgError = true
                                deleteAlert = true
                            }
                        } else {
                            // Medicine with the given name and username does not exist
                            print("Medicine not found or does not belong to the user.")
                        }
                        
                    }
                }
            }
        }
    }
    
    //This method inputs a date, a userID, and medication name and createss UNUserNotification that will
    // go off at the time the parameters specified on a specific day in the week
    // It also creates a notificatio with a image that was queried using the userID. However, this is for when the user
    // creates a new med
    func scheduleNotification(med: String, user: String, day: Date, week: Int, name: String)
    {

        let content = UNMutableNotificationContent()
        content.title = "PillNotify"
        content.subtitle = med
        content.body = "Hey \(name)! It's time to take your \(med).\nDescription: (Color: \(color), Shape: \(shape), Dosage: \(amount) \(unit)). Make sure to confirm in the app or with siri if you haven't already!"
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let suffix = day
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: suffix)
        
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        
        // Get the UIImage from your source, e.g. the camera roll
        let image = inputImage
        let uuid = UUID().uuidString
        let filename = "\(uuid).jpg"

        // Compress the image data to reduce the file size
        if let compressedImageData = image!.jpegData(compressionQuality: 0.5) {

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
        

    }
    
    //This method inputs a date, a userID, and medication name and createss UNUserNotification that will
    // go off at the time the parameters specified on a specific day in the week
    // It also creates a notificatio with a image that was queried using the userID. This one is for when they are updating a med
    func scheduleNotification2(med: String, user: String, day: Date, week: Int)
    {
        var fullname = ""
        var picname = med.replacingOccurrences(of: " ", with: "-")
        picname = picname.replacingOccurrences(of: "\\", with: "")
        let username = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        let usersReference = database.child("users").child(username)
        usersReference.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let _ = snapshot.value as? [String: Any] else {
                    return
                }
                
                fullname += UserDefaults.standard.string(forKey: "fname")!
                
            } else {
                print("No data found in users node")
            }
        }
        
        let usersReference2 = database.child("medicines").child(username)
        let query = usersReference2.queryOrdered(byChild: "username").queryEqual(toValue: user)
        
        query.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let usersData = snapshot.value as? [String: [String: Any]] else {
                    return
                }
                
                for (_, usersData) in usersData {
                    if let medicineName = usersData["medname"] as? String, medicineName == med {
                        if let medcolor = usersData["medcolor"] as? String
                        {
                            color = medcolor
                        }
                        if let medshape = usersData["medshape"] as? String
                        {
                            shape = medshape
                        }
                        
                        if let dose = usersData["dosage"] as? Int
                        {
                            amount = dose
                        }
                        
                        if let measure = usersData["unit"] as? String
                        {
                            unit = measure
                        }
                    }
                }
                
                
                let storageRef = Storage.storage().reference().child("images").child(user).child("\(picname).jpg")

                storageRef.downloadURL { (url, error) in
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
                                    let content = UNMutableNotificationContent()
                                    content.title = "PillNotify"
                                    content.subtitle = med
                                    content.body = "Hey \(fullname)! It's time to take your \(med).\nDescription: (Color: \(color), Shape: \(shape), Dosage: \(amount) \(unit)). Make sure to confirm in the app or with siri if you haven't already!"
                                    content.sound = UNNotificationSound.default
                                    content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                    
                                    let suffix = day
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.hour, .minute], from: suffix)
                                    
                                    let hour = components.hour ?? 0
                                    let minute = components.minute ?? 0

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
                                    
                                    print(trigger)


                                    
                                    // choose a random identifier
                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                    
                                    
                                    // add our notification request
                                    UNUserNotificationCenter.current().add(request) { error in
                                        if let error = error {
                                            // Handle the error
                                            print("Error adding notification1 request:", error)
                                        } else {
                                            // Notification request added successfully
                                            print("Notification2 request added successfully")
                                            isUpdating = false
                                            sheet2 = false
                                        }
                                    }
                                    // ...
                                }
                            } else {
                                // Failed to convert the image data to UIImage or retrieve the image data
                                // Handle the error case
                                print ("Failed to convert the image data to UIImage or retrieve the image data")
                            }
                        }
                    } else {
                        // Handle the case where image URL is invalid
                        print ("image URL is invalid")
                    }
                }
                
        
            }
        }
        

    }
    
    // This method iterates through all the medication of a logged in user and gets all the times the user has a medicine
    // scheduled for and calls the method that schedules a notification at that time. This is when the user adds a brand new med
    func sendMessage(meds: String, reminders: [String: [String]], name: String)
    {
        if let username = UserDefaults.standard.object(forKey: "usernameKey") as? String {
            var count = 1
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
                                scheduleNotification(med: meds, user: username, day: date, week: 2, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 2, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 2, name: name)
                            }
                        case "Tuesday":
                            if count == 1 {
                                scheduleNotification(med: meds, user: username, day: date, week: 3, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 3, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 3, name: name)
                            }
                        case "Wednesday":
                            if count == 1 {
                                scheduleNotification(med: meds, user: username, day: date, week: 4, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 4, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 4, name: name)
                            }
                        case "Thursday":
                            if count == 1 {
                                scheduleNotification(med: meds, user: username, day: date, week: 5, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 5, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 5, name: name)
                            }
                        case "Friday":
                            if count == 1 {
                                scheduleNotification(med: meds, user: username, day: date, week: 6, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 6, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 6, name: name)
                            }
                        case "Saturday":
                            if count == 1 {
                                scheduleNotification(med: meds, user: username, day: date, week: 7, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 7, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 7, name: name)
                            }
                        case "Sunday":
                            if count == 1 {
                                scheduleNotification(med: meds, user: username, day: date, week: 1, name: name)
                                count += 1
                            } else if count == 2 {
                                scheduleNotification(med: meds, user: username, day: date, week: 1, name: name)
                                count += 1
                            } else if count == 3 {
                                scheduleNotification(med: meds, user: username, day: date, week: 1, name: name)
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    // This method iterates through all the medication of a logged in user and gets all the times the user has a medicine
    // scheduled for and calls the method that schedules a notification at that time. This is when a user updates/deletes a med.
    // The reason there is two is because when the user deletes a med, this one has to query the database, whereas the other one just uses the information
    // the user inputed in the sheet to add a medicine
    func sendMessage2()
    {
        if let username = UserDefaults.standard.object(forKey: "usernameKey") as? String {
            
            var count = 1
            let medicineDatabase = database.child("medicines").child(username)
            if let user = UserDefaults.standard.string(forKey: "usernameKey") {
                let query = medicineDatabase.queryOrdered(byChild: "username").queryEqual(toValue: username)
                
                query.observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        guard let medicineData = snapshot.value as? [String: [String: Any]] else {
                            return
                        }
                        
                        selectedDays.removeAll()
                        
                        for (meds, medData) in medicineData {
                            if let reminders = medData["reminders"] as? [String: [String]] {
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
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 2)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 2)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 2)
                                                }
                                            case "Tuesday":
                                                if count == 1 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 3)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 3)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 3)
                                                }
                                            case "Wednesday":
                                                if count == 1 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 4)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 4)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 4)
                                                }
                                            case "Thursday":
                                                if count == 1 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 5)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 5)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 5)
                                                }
                                            case "Friday":
                                                if count == 1 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 6)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 6)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 6)
                                                }
                                            case "Saturday":
                                                if count == 1 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 7)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 7)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 7)
                                                }
                                            case "Sunday":
                                                if count == 1 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 1)
                                                    count += 1
                                                } else if count == 2 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 1)
                                                    count += 1
                                                } else if count == 3 {
                                                    scheduleNotification2(med: meds, user: username, day: date, week: 1)
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
                        print("No data found in medicines node for the user: \(user)")
                    }
                }
            }
        }
    }
    
    // This method just resets all the @State variables that the user has to input when they enter a new medicine
    // bascially it just clears the add medicine sheet so no existing data still persists when a user wants to add a new med
    func reset()
    {
        name = ""
        color = ""
        shape = ""
        amount = 0
        unit = ""
        secondunit = ""
        pillsleft = 0
        everyday = false

        timeOfDay1M = Date()
        timeOfDay1Tu = Date()
        timeOfDay1W = Date()
        timeOfDay1Th = Date()
        timeOfDay1F = Date()
        timeOfDay1Sa = Date()
        timeOfDay1Su = Date()
        timeOfDay1Total = Date()

        timeOfDay2M = Date()
        timeOfDay2Tu = Date()
        timeOfDay2W = Date()
        timeOfDay2Th = Date()
        timeOfDay2F = Date()
        timeOfDay2Sa = Date()
        timeOfDay2Su = Date()
        timeOfDay2Total = Date()

        timeOfDay3M = Date()
        timeOfDay3Tu = Date()
        timeOfDay3W = Date()
        timeOfDay3Th = Date()
        timeOfDay3F = Date()
        timeOfDay3Sa = Date()
        timeOfDay3Su = Date()
        timeOfDay3Total = Date()

        timesADayM = 1
        timesADayTu = 1
        timesADayW = 1
        timesADayTh = 1
        timesADayF = 1
        timesADaySa = 1
        timesADaySu = 1
        timesADayTotal = 1

        inputImage = UIImage()
        image = Image(uiImage: UIImage())
        showingImagePicker = false
        selectedDays = []
    }
    
    // This method updates the firebase database with the new medicine name and all its attributes such as the images in Firebase Storage
    // the reports name, and reconfigures all the UNUserNotifications in case the medicine taker has adjusted the times to be reminded.
    func updateMedicine() {

        medPresentAlert2 = false
        
        var picname = name.replacingOccurrences(of: " ", with: "-") // eliminate spaces and backslashes so that images can be stored in Firebase Storage under similar name as medicine name
        picname = picname.replacingOccurrences(of: "\\", with: "")
        var picname2 = previousname.replacingOccurrences(of: " ", with: "-")
        picname2 = picname2.replacingOccurrences(of: "\\", with: "")
        
        
        let username = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        var times: [String: [String]] = [:]


        if everyday
        {
            if timesADayTotal == 1
            {
                times["Monday"] = [dateToString(count: timeOfDay1Total)]
                times["Tuesday"] = [dateToString(count: timeOfDay1Total)]
                times["Wednesday"] = [dateToString(count: timeOfDay1Total)]
                times["Thursday"] = [dateToString(count: timeOfDay1Total)]
                times["Friday"] = [dateToString(count: timeOfDay1Total)]
                times["Saturday"] = [dateToString(count: timeOfDay1Total)]
                times["Sunday"] = [dateToString(count: timeOfDay1Total)]
            }
            else if timesADayTotal == 2
            {
                times["Monday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Tuesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Wednesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Thursday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Friday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Saturday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Sunday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
            }
            else if timesADayTotal == 3
            {
                times["Monday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Tuesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Wednesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Thursday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay2Total)]
                times["Friday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Saturday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Sunday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
            }
        }
        else
        {
            
            for i in selectedDays
            {
                if i == "Monday" && timesADayM == 1
                {
                    times["Monday"] = [dateToString(count: timeOfDay1M)]
                }
                else if i == "Monday" && timesADayM == 2
                {
                    times["Monday"] = [dateToString(count: timeOfDay1M), dateToString(count: timeOfDay2M)]
                }
                else if i == "Monday" && timesADayM == 3
                {
                    times["Monday"] = [dateToString(count: timeOfDay1M), dateToString(count: timeOfDay2M), dateToString(count: timeOfDay3M)]
                }
                
                else if i == "Tuesday" && timesADayTu == 1
                {
                    times["Tuesday"] = [dateToString(count: timeOfDay1Tu)]
                }
                else if i == "Tuesday" && timesADayTu == 2
                {
                    times["Tuesday"] = [dateToString(count: timeOfDay1Tu), dateToString(count: timeOfDay2Tu)]
                }
                else if i == "Tuesday" && timesADayTu == 3
                {
                    times["Tuesday"] = [dateToString(count: timeOfDay1Tu), dateToString(count: timeOfDay2Tu), dateToString(count: timeOfDay3Tu)]
                }
                
                else if i == "Wednesday" && timesADayW == 1
                {
                    times["Wednesday"] = [dateToString(count: timeOfDay1W)]
                }
                else if i == "Wednesday" && timesADayW == 2
                {
                    times["Wednesday"] = [dateToString(count: timeOfDay1W), dateToString(count: timeOfDay2W)]
                }
                else if i == "Wednesday" && timesADayW == 3
                {
                    times["Wednesday"] = [dateToString(count: timeOfDay1W), dateToString(count: timeOfDay2W), dateToString(count: timeOfDay3W)]
                }
                
                else if i == "Thursday" && timesADayTh == 1
                {
                    times["Thursday"] = [dateToString(count: timeOfDay1Th)]
                }
                else if i == "Thursday" && timesADayTh == 2
                {
                    times["Thursday"] = [dateToString(count: timeOfDay1Th), dateToString(count: timeOfDay2Th)]
                }
                else if i == "Thursday" && timesADayTh == 3
                {
                    times["Thursday"] = [dateToString(count: timeOfDay1Th), dateToString(count: timeOfDay2Th), dateToString(count: timeOfDay3Th)]
                }
                
                else if i == "Friday" && timesADayF == 1
                {
                    times["Friday"] = [dateToString(count: timeOfDay1F)]
                }
                else if i == "Friday" && timesADayF == 2
                {
                    times["Friday"] = [dateToString(count: timeOfDay1F), dateToString(count: timeOfDay2F)]
                }
                else if i == "Friday" && timesADayF == 3
                {
                    times["Friday"] = [dateToString(count: timeOfDay1F), dateToString(count: timeOfDay2F), dateToString(count: timeOfDay3F)]
                }
                
                else if i == "Saturday" && timesADaySa == 1
                {
                    times["Saturday"] = [dateToString(count: timeOfDay1Sa)]
                }
                else if i == "Saturday" && timesADaySa == 2
                {
                    times["Saturday"] = [dateToString(count: timeOfDay1Sa), dateToString(count: timeOfDay2Sa)]
                }
                else if i == "Saturday" && timesADaySa == 3
                {
                    times["Saturday"] = [dateToString(count: timeOfDay1Sa), dateToString(count: timeOfDay2Sa), dateToString(count: timeOfDay3Sa)]
                }
                
                else if i == "Sunday" && timesADaySu == 1
                {
                    times["Sunday"] = [dateToString(count: timeOfDay1Su)]
                }
                else if i == "Sunday" && timesADaySu == 2
                {
                    times["Sunday"] = [dateToString(count: timeOfDay1Su), dateToString(count: timeOfDay2Su)]
                }
                else if i == "Sunday" && timesADaySu == 3
                {
                    times["Sunday"] = [dateToString(count: timeOfDay1Su), dateToString(count: timeOfDay2Su), dateToString(count: timeOfDay3Su)]
                }
            }
        }

        let medicineDatabase = database.child("medicines").child(username)
        if let user = UserDefaults.standard.string(forKey: "usernameKey") {
            let query = medicineDatabase.queryOrdered(byChild: "username").queryEqual(toValue: user)
            
            query.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    guard let medData = snapshot.value as? [String: [String: Any]] else {
                        return
                    }
                    for (_, data) in medData {
                        if let medicineName = data["medname"] as? String, medicineName == previousname {

                            if let confcount = data["lastconfirm"] as? String
                            {
                                lastconfirmed = confcount
                            }
                        }
                    }
                } else {
                    print("No data found in medicines node for the user: \(user)")
                }
            }
        }
        
        var fullname = ""
        var apn = ""
        let usersReference = database.child("users").child(username)
        usersReference.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let usersData = snapshot.value as? [String: Any] else {
                    return
                }

                fullname += UserDefaults.standard.string(forKey: "fname")!
                fullname += " "
                fullname += UserDefaults.standard.string(forKey: "lname")!
                if let ap = usersData["apnsid"] as? String {
                    apn = ap
                }
            } else {
                print("No data found in users node")
            }
        }
        
        let medicinesReference = database.child("medicines").child(username).child(name.uppercased())
        let medicineReference = database.child("medicines").child(username).queryOrdered(byChild: "medname").queryEqual(toValue: name.uppercased())
        medicineReference.observeSingleEvent(of: .value) { snapshot in
            var shouldAddMedicine = true
            
            if snapshot.exists() {
                // Medication name already exists, check if it belongs to the same username
                if let medicinesData = snapshot.value as? [String: [String: Any]] {
                    for (_, medicineData) in medicinesData {
                        if let username = medicineData["username"] as? String,
                           username == UserDefaults.standard.string(forKey: "usernameKey") {
                            // Medicine with the same name and username already exists
                            if name.uppercased() != previousname
                            {
                                shouldAddMedicine = false
                                medPresentAlert = true
                            }
                            break
                        }
                    }
                }
            }
            
            if shouldAddMedicine {
                let imageDatabase = Storage.storage().reference().child("images").child(username).child("\(picname2).jpg")

                // Delete the file
                imageDatabase.delete { error in
                    if let error = error {
                        // Handle the error case
                        print("Failed to delete file: \(error.localizedDescription)")
                    } else {
                        print("si")
                    }
                }
                
                let medicineReference2 = database.child("medicines")
                
                // Delete the medicine record from Firebase
                medicineReference2.child(username).child(previousname).removeValue { error, _ in
                    if let error = error {
                        print("Failed to delete medicine: \(error.localizedDescription)")
                    } else {
                        print ("succe")
                    }
                }
                
                let imageData = inputImage?.jpegData(compressionQuality: 0.8)
                
                // Create a unique filename or path for the image in Firebase Storage

                // Create a reference to the Firebase Storage location where you want to store the image
                let storageRef = Storage.storage().reference().child("images").child(username).child("\(picname.uppercased()).jpg")

                // Upload the image data to Firebase Storage
                storageRef.putData(imageData!, metadata: nil) { (metadata, error) in
                    if let error = error {
                        // Handle the error case
                        print("Failed to upload image: \(error.localizedDescription)")
                    }
                    else
                    {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        sendMessage2()
                        let ap = UserDefaults.standard.string(forKey: "apnsToken")!
                        if ap != apn
                        {
                            sendPushNotification(body: "\(fullname) has updated their medication info for \(name.uppercased()).", subtitle: "Updated Medication", phoneId: apn)
                        }
                    }
                }
                
                let medicineData: [String: Any] = [
                    "username": UserDefaults.standard.string(forKey: "usernameKey")!,
                    "medname": name.uppercased(),
                    "medcolor": color,
                    "medshape": shape,
                    "remaining": pillsleft,
                    "dosage": amount,
                    "unit": unit,
                    "secondunit": secondunit,
                    "count": 0,
                    "repeatMissed": true,
                    "lastconfirm": lastconfirmed,
                    "reminders" : times
                ]
                
                medicinesReference.setValue(medicineData) { error, _ in
                    if let error = error {
                        // Handle the error case
                        print("Failed to create object: \(error.localizedDescription)")
                    } else {
                        // Object created successfully
                        // Handle the success case
                        print("Medicine updated successfully")
                        fetchMedicineRecords()
                        updateReportsName(med: name.uppercased(), prev: previousname)
                        isUpdating = true
                    }
                }
            
            }
        }
    }

    // This method takes input from the user and then adds a medicine to the firebase database as well as adds to the firebase storage of the image
    // the user uploaded associated to that medicine name. It also creates a report for this med starting with the most current sunday as the first weekly report.
    func addMedicine()
    {
        medPresentAlert2 = false
        
        var picname = name.replacingOccurrences(of: " ", with: "-") // storage wont error with space and backslash
        picname = picname.replacingOccurrences(of: "\\", with: "")
        var times: [String: [String]] = [:]
        
        if everyday
        {
            if timesADayTotal == 1
            {
                times["Monday"] = [dateToString(count: timeOfDay1Total)]
                times["Tuesday"] = [dateToString(count: timeOfDay1Total)]
                times["Wednesday"] = [dateToString(count: timeOfDay1Total)]
                times["Thursday"] = [dateToString(count: timeOfDay1Total)]
                times["Friday"] = [dateToString(count: timeOfDay1Total)]
                times["Saturday"] = [dateToString(count: timeOfDay1Total)]
                times["Sunday"] = [dateToString(count: timeOfDay1Total)]
            }
            else if timesADayTotal == 2
            {
                times["Monday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Tuesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Wednesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Thursday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Friday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Saturday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
                times["Sunday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total)]
            }
            else if timesADayTotal == 3
            {
                times["Monday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Tuesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Wednesday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Thursday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay2Total)]
                times["Friday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Saturday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
                times["Sunday"] = [dateToString(count: timeOfDay1Total), dateToString(count: timeOfDay2Total), dateToString(count: timeOfDay3Total)]
            }
        }
        else
        {
            
            for i in selectedDays
            {
                if i == "Monday" && timesADayM == 1
                {
                    times["Monday"] = [dateToString(count: timeOfDay1M)]
                }
                else if i == "Monday" && timesADayM == 2
                {
                    times["Monday"] = [dateToString(count: timeOfDay1M), dateToString(count: timeOfDay2M)]
                }
                else if i == "Monday" && timesADayM == 3
                {
                    times["Monday"] = [dateToString(count: timeOfDay1M), dateToString(count: timeOfDay2M), dateToString(count: timeOfDay3M)]
                }
                
                else if i == "Tuesday" && timesADayTu == 1
                {
                    times["Tuesday"] = [dateToString(count: timeOfDay1Tu)]
                }
                else if i == "Tuesday" && timesADayTu == 2
                {
                    times["Tuesday"] = [dateToString(count: timeOfDay1Tu), dateToString(count: timeOfDay2Tu)]
                }
                else if i == "Tuesday" && timesADayTu == 3
                {
                    times["Tuesday"] = [dateToString(count: timeOfDay1Tu), dateToString(count: timeOfDay2Tu), dateToString(count: timeOfDay3Tu)]
                }
                
                else if i == "Wednesday" && timesADayW == 1
                {
                    times["Wednesday"] = [dateToString(count: timeOfDay1W)]
                }
                else if i == "Wednesday" && timesADayW == 2
                {
                    times["Wednesday"] = [dateToString(count: timeOfDay1W), dateToString(count: timeOfDay2W)]
                }
                else if i == "Wednesday" && timesADayW == 3
                {
                    times["Wednesday"] = [dateToString(count: timeOfDay1W), dateToString(count: timeOfDay2W), dateToString(count: timeOfDay3W)]
                }
                
                else if i == "Thursday" && timesADayTh == 1
                {
                    times["Thursday"] = [dateToString(count: timeOfDay1Th)]
                }
                else if i == "Thursday" && timesADayTh == 2
                {
                    times["Thursday"] = [dateToString(count: timeOfDay1Th), dateToString(count: timeOfDay2Th)]
                }
                else if i == "Thursday" && timesADayTh == 3
                {
                    times["Thursday"] = [dateToString(count: timeOfDay1Th), dateToString(count: timeOfDay2Th), dateToString(count: timeOfDay3Th)]
                }
                
                else if i == "Friday" && timesADayF == 1
                {
                    times["Friday"] = [dateToString(count: timeOfDay1F)]
                }
                else if i == "Friday" && timesADayF == 2
                {
                    times["Friday"] = [dateToString(count: timeOfDay1F), dateToString(count: timeOfDay2F)]
                }
                else if i == "Friday" && timesADayF == 3
                {
                    times["Friday"] = [dateToString(count: timeOfDay1F), dateToString(count: timeOfDay2F), dateToString(count: timeOfDay3F)]
                }
                
                else if i == "Saturday" && timesADaySa == 1
                {
                    times["Saturday"] = [dateToString(count: timeOfDay1Sa)]
                }
                else if i == "Saturday" && timesADaySa == 2
                {
                    times["Saturday"] = [dateToString(count: timeOfDay1Sa), dateToString(count: timeOfDay2Sa)]
                }
                else if i == "Saturday" && timesADaySa == 3
                {
                    times["Saturday"] = [dateToString(count: timeOfDay1Sa), dateToString(count: timeOfDay2Sa), dateToString(count: timeOfDay3Sa)]
                }
                
                else if i == "Sunday" && timesADaySu == 1
                {
                    times["Sunday"] = [dateToString(count: timeOfDay1Su)]
                }
                else if i == "Sunday" && timesADaySu == 2
                {
                    times["Sunday"] = [dateToString(count: timeOfDay1Su), dateToString(count: timeOfDay2Su)]
                }
                else if i == "Sunday" && timesADaySu == 3
                {
                    times["Sunday"] = [dateToString(count: timeOfDay1Su), dateToString(count: timeOfDay2Su), dateToString(count: timeOfDay3Su)]
                }
            }
        }
        
        var fullname = ""
        var apn = ""
        
        let user = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        let usersReference = database.child("users").child(user)
        usersReference.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                guard let usersData = snapshot.value as? [String: Any] else {
                    return
                }
                
                
                fullname += UserDefaults.standard.string(forKey: "fname")!

                
                if let apns = usersData["apnsid"] as? String {
                    apn = apns
                }
                
            } else {
                print("No data found in users node")
            }
        }

        let username = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"

        let medicinesReference = database.child("medicines").child(username).child(name.uppercased())
        let medicineReference = database.child("medicines").child(username).queryOrdered(byChild: "medname").queryEqual(toValue: name.uppercased())
            medicineReference.observeSingleEvent(of: .value) { snapshot in
                var shouldAddMedicine = true
                
                if snapshot.exists() {
                    // Medication name already exists, check if it belongs to the same username
                    if let medicinesData = snapshot.value as? [String: [String: Any]] {
                        for (_, medicineData) in medicinesData {
                            if let username = medicineData["username"] as? String,
                               username == UserDefaults.standard.string(forKey: "usernameKey") {
                                // Medicine with the same name and username already exists
                                shouldAddMedicine = false
                                medPresentAlert2 = true
                                break
                            }
                        }
                    }
                }
                
                if shouldAddMedicine {
                    
                    let imageData = inputImage?.jpegData(compressionQuality: 0.8)
                    
                    // Create a unique filename or path for the image in Firebase Storage// Example filename

                    // Create a reference to the Firebase Storage location where you want to store the image
                    let storageRef = Storage.storage().reference().child("images").child(username).child("\(picname.uppercased()).jpg")

                    // Upload the image data to Firebase Storage
                    storageRef.putData(imageData!, metadata: nil) { (metadata, error) in
                            if let error = error {
                                // Handle the error case
                                print("Failed to upload image: \(error.localizedDescription)")
                            }
                        }
                    
                    let midnightDate = Calendar.current.startOfDay(for: Date())

                    let medData: [String: Any] = [
                        "username": UserDefaults.standard.string(forKey: "usernameKey")!,
                        "medname": name.uppercased(),
                        "medcolor": color,
                        "medshape": shape,
                        "remaining": pillsleft,
                        "repeatMissed": true,
                        "dosage": amount,
                        "unit": unit,
                        "secondunit": secondunit,
                        "count": 0,
                        "lastconfirm": dateToString(count: midnightDate),
                        "reminders" : times
                    ]
                    
                    medicinesReference.setValue(medData) { error, _ in
                        if let error = error {
                            // Handle the error case
                            print("Failed to create object: \(error.localizedDescription)")
                        } else {
                            // Object created successfully
                            // Handle the success case
                            var startDateString = ""
                            fetchMedicineRecords()
                            sendMessage(meds: name.uppercased(), reminders: times, name: fullname)
                            sheet = false
                            
                            print("Object created successfully")
                            
                            if let weekDates = getStartAndEndDateOfCurrentWeek() {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                
                                startDateString = dateFormatter.string(from: weekDates.start)

                                reports = ["confirmed": 0, "missed":0, "misseddates": ["None"], "seniordates": ["None"]]
                            } else {
                                print("Failed to get the start and end dates of the current week.")
                            }
                            
                            let reportDatabase = database.child("reports").child("\(username)").child(name.uppercased())
                            let reportData: [String: Any] = [
                                startDateString: reports
                                
                            ]
                            
                            reportDatabase.setValue(reportData) { error, _ in
                                if let error = error {
                                    // Handle the error case
                                    print("Failed to create object: \(error.localizedDescription)")
                                    // Handle the error and show appropriate alert
                                } else {
                                    print("Object created successfully")
                                    let ap = UserDefaults.standard.string(forKey: "apnsToken") ?? "NO APNS"
                                    if ap != apn
                                    {
                                        sendPushNotification(body: "\(fullname) has scheduled to take \(name.uppercased()).", subtitle: "Scheduled Medication", phoneId: apn)
                                    }
                                    
                                }
                            }
                        }
                    }
                
                }
            }
    }

    // This method fills the medication info when the user clicks on the medication and wants to change something or just look at it
    func fillSheet(medname: String)
    {
        var picname = medname.replacingOccurrences(of: " ", with: "-") // storage doesn't error out with spaces and backslashes
        picname = picname.replacingOccurrences(of: "\\", with: "")
        var count = 1
        if let user = UserDefaults.standard.string(forKey: "usernameKey") {
            let medicineDatabase = database.child("medicines").child(user)
            let query = medicineDatabase.queryOrdered(byChild: "username").queryEqual(toValue: user)
            
            query.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    guard let medData = snapshot.value as? [String: [String: Any]] else {
                        return
                    }
                    
                    selectedDays.removeAll()
                    
                    for (_, data) in medData {
                        if let medicineName = data["medname"] as? String, medicineName == medname {
                            // Access and use the medicine information here
                            name = medicineName
                            if let medcolor = data["medcolor"] as? String
                            {
                                color = medcolor
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

                            let storageRef = Storage.storage().reference().child("images").child(user).child("\(picname).jpg")

                            storageRef.downloadURL { (url, error) in
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
                                                image = Image(uiImage: uiImage)
                                                // ...
                                            }
                                        } else {
                                            // Failed to convert the image data to UIImage or retrieve the image data
                                            // Handle the error case
                                            print("Failed to convert the image data to UIImage or retrieve the image data")
                                        }
                                    }
                                } else {
                                    // Handle the case where image URL is invalid
                                    print ("image URL is invalid")
                                }
                            }
                        }
                    }
                } else {
                    print("No data found in medicines node for the user: \(user)")
                }
            }
        }

    }
    
    // This method updates the name of the medicine in the reports database when a user update their medicine name
    func updateReportsName(med: String, prev: String)
    {
        let id = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
        var confirmedDose = 0
        var missedDose = 0
        var missedDates: [String] = []
        var confirmedDates: [String] = []
        
        var prevreports: [String: [String: Any]] = [:]


        let reportsReference = database.child("reports").child(id).child(prev)
        reportsReference.observeSingleEvent(of: .value) { snapshot in
            guard let reportsData = snapshot.value as? [String: [String: Any]] else {
                return
            }

            for (date, reports) in reportsData {
                if let confirmedCount = reports["confirmed"] as? Int {
                    confirmedDose = confirmedCount
                }
                if let missedCount = reports["missed"] as? Int {
                    missedDose = missedCount
                }
                if let dates = reports["misseddates"] as? [String] {
                    missedDates = dates
                }
                if let dates = reports["seniordates"] as? [String] {
                    confirmedDates = dates
                }
                prevreports[date] = ["confirmed" : confirmedDose, "missed":missedDose, "misseddates":missedDates, "seniordates": confirmedDates]
                
            }
            
            let reportDatabase = database.child("reports")
            // Delete the medicine record from Firebase
            reportDatabase.child(id).child(prev).removeValue { error, _ in
                if let error = error {
                    print("Failed to delete report: \(error.localizedDescription)")
                } else {
                    print ("successs")
                    let reportDatabase2 = database.child("reports").child(id).child(med)
                    let data: [String: [String: Any]] = prevreports
                    
                    reportDatabase2.setValue(data) { error, _ in
                        if let error = error {
                            // Handle the error case
                            print("Failed to update report: \(error.localizedDescription)")
                            // Handle the error and show appropriate alert
                        } else {
                            print("Object created successfully")
                        }
                    }
                }
            }
        }
        
    }
    
    // This method updates the reports database when a medicine taker missed a dose for medicine and it update the count of how many times the
    // medicine taker missed their dose this week as well as the date and dose time that was missed.
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
            let id = UserDefaults.standard.string(forKey: "usernameKey")!
            
            var missedCount = 0
            var confirmedCount = 0
            var missedDates: [String] = []
            var confirmedDates: [String] = []
            

            let reportsReference = database.child("reports").child(id).child(med).child(formattedDate)
            reportsReference.observeSingleEvent(of: .value) { snapshot in
                guard let reportData = snapshot.value as? [String: Any] else {
                    let reportsReference2 = database.child("reports").child(id).child(med).child(formattedDate)
                    
                    let reports: [String: Any] = ["confirmed": 0, "missed":stringDates.count, "misseddates": stringDates, "seniordates": ["None"]]
                    
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
                    "seniordates": confirmedDates,
                    "confirmed": confirmedCount,
                    "missed": missedCount + stringDates.count,
                    "misseddates": missedDates
                ]
                
                reportsReference.updateChildValues(updatedData) { error, _ in
                    if let error = error {
                        // Handle the error case
                        print("Failed to update medicine: \(error.localizedDescription)")
                    }
                }
                
            }
            
            
        }
    }
    
    // This method alertifies the medicine taker and caretaker that they have missed their dose for a medicaion. If the current time
    // is 45 minutes after what the dosage time was scheduled at, it sends a Firebase push notificaiton to both. It also updates the reports to say
    // that today the medicine taker missed their dose.
    func sendMissedDose() {
        let login = UserDefaults.standard.object(forKey: "isLoggedIn") as? Bool ?? false
        if login
        {
            let user = UserDefaults.standard.string(forKey: "usernameKey") ?? "NO ID"
            let usersReference = database.child("users").child(user)
            
            fullname = ""
            apn = ""
            count = 0
            changeCount = false
            
            var repeats = false
            var missed: [Date] = []
            var dates: [Int: [Int: Date]] = [:]
            var confirmTime: Date = Date()
            var missedRestart: Date = Date()
            var idcount = 1
            
            usersReference.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    guard let usersData = snapshot.value as? [String: Any] else {
                        return
                    }
                    
                    fullname += UserDefaults.standard.string(forKey: "fname")!
                    fullname += " "
                    fullname += UserDefaults.standard.string(forKey: "lname")!
                    
                    if let id = usersData["apnsid"] as? String {
                        apn = id
                    }
                    
                    
                    let medicineDatabase = database.child("medicines").child(user)
                    let query2 = medicineDatabase.queryOrdered(byChild: "username").queryEqual(toValue: user)
                    
                    query2.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists() {
                            guard let medData = snapshot.value as? [String: [String: Any]] else {
                                return
                            }
                            
                            for (_, data) in medData {
                                if let med = data["medname"] as? String {
                                    // Do something with the medicine name
                                    
                                    let remindersReference = database.child("medicines").child(user)
                                    let remindersQuery = remindersReference.queryOrdered(byChild: "medname").queryEqual(toValue: med)
                                    
                                    remindersQuery.observeSingleEvent(of: .value) { snapshot in
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
                                            missed = []
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
                                                                    if count <= 2 && repeats == true
                                                                    {
                                                                        if apn != UserDefaults.standard.string(forKey: "apnsToken")! {
                                                                            sendPushNotification(body: "\(fullname) has missed their dose on \(dateToString(count: dateWithSameTime)) for \(med). They may still be able to confirm this dose late.", subtitle: "Missed Dose", phoneId: apn)
                                                                        }
                                                                        
                                                                        // Fetch the username from UserDefaults
                                                                        let content = UNMutableNotificationContent()
                                                                        content.title = "PillNotify"
                                                                        content.subtitle = "Missed Dose"
                                                                        content.body = "Hi \(fullname), you have missed your \(dateToString(count: dateWithSameTime)) dose for \(med) and your caretaker has been notified. You may still confirm this med."
                                                                        content.sound = UNNotificationSound.default
                                                                        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
                                                                        
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
                                                                        
                                                                        count += 1
                                                                        changeCount = true
                                                                        missed.append(dateWithSameTime)
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                if let username = UserDefaults.standard.object(forKey: "usernameKey") as? String {
                                                    if changeCount == true {
                                                        updateReportsMissed(med: med, date: missed)
                                                        let medicineRef = database.child("medicines").child(username).child(med)
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
                                                        let medicineRef = database.child("medicines").child(username).child(med)
                                                        let updatedData: [String: Any] = [
                                                            "count": count,
                                                            "repeatMissed": repeats
                                                        ]
                                                        
                                                        medicineRef.updateChildValues(updatedData) { error, _ in
                                                            if let error = error {
                                                                // Handle the error case
                                                                print("Failed to update medicine: \(error.localizedDescription)")
                                                            } else {
                                                                
                                                                print("success updated")
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
                            print ("No meds found")
                        }
                    }
                } else {
                    print("No data found in users node")
                }
            }
        }
    }


    // This method takes a Date object and turns it into a string with the form yyyy-mm-dd hh:mm:ss. It also calls sendmisseddose() to see if the
    // medicine taker missed their dose today
    func dateToString(count: Date) -> String
    {
        let date = count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Choose a format that suits your needs
        return dateFormatter.string(from: date)
    }
    
    func fetchMedicineRecords() {
        medicineRecords = [:]
        if let username = UserDefaults.standard.object(forKey: "usernameKey") as? String {
            let medicinesReference = database.child("medicines").child(username)
            
            medicinesReference.observeSingleEvent(of: .value) { snapshot in
                guard let medicinesData = snapshot.value as? [String: [String: Any]] else {
                    return
                }
                
                for (medicineId, medicineData) in medicinesData {
                    if let dusername = medicineData["username"] as? String, dusername == username {
                        medicineRecords[medicineId] = medicineData
                    }
                }
                
            }
        }
        sendMissedDose()
    }
    

}

// Also for the user to select mutliple days when choosing what days to schedule their med
struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
//Allow medicine taker to attach a image to a notification when it notifies them to take their meds
extension UNNotificationAttachment {
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let imageData = image.pngData()
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(identifier).png")
        do {
            try imageData?.write(to: url!, options: .atomicWrite)
            let attachment = try UNNotificationAttachment(identifier: identifier, url: url!, options: options)
            return attachment
        } catch {
            print("Error creating notification attachment: \(error.localizedDescription)")
        }
        return nil
    }
}

struct MedicationHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationHomeView()
    }
}
