//
//  SetTimesView.swift
//  PillNotify
//
//  Created by Amogh Bantwal on 5/31/23.
//

import SwiftUI

// This view displays the dates and times a user can choose from on the medication home sheet
struct SetTimesView: View {
    @Binding var timeDay1M: Date
    @Binding var timeDay1Tu: Date
    @Binding var timeDay1W: Date
    @Binding var timeDay1Th: Date
    @Binding var timeDay1F: Date
    @Binding var timeDay1Sa: Date
    @Binding var timeDay1Su: Date
    
    @Binding var timeDay2M: Date
    @Binding var timeDay2Tu: Date
    @Binding var timeDay2W: Date
    @Binding var timeDay2Th: Date
    @Binding var timeDay2F: Date
    @Binding var timeDay2Sa: Date
    @Binding var timeDay2Su: Date

    @Binding var timeDay3M: Date
    @Binding var timeDay3Tu: Date
    @Binding var timeDay3W: Date
    @Binding var timeDay3Th: Date
    @Binding var timeDay3F: Date
    @Binding var timeDay3Sa: Date
    @Binding var timeDay3Su: Date
    
    @Binding var timesDayM: Int
    @Binding var timesDayTu: Int
    @Binding var timesDayW: Int
    @Binding var timesDayTh: Int
    @Binding var timesDayF: Int
    @Binding var timesDaySa: Int
    @Binding var timesDaySu: Int
    
    @State var days: String
    let numbers: [Int] = Array(1...3).map { Int($0) }
    
    
    var body: some View {
        Section
        {
            if days == "Monday"
            {
                Picker("Number of Dosages:", selection: $timesDayM)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDayM == 1
                {
                    DatePicker("Monday Dosage Time 1", selection: $timeDay1M, displayedComponents: .hourAndMinute)
                }
                else if timesDayM == 2
                {
                    DatePicker("Monday Dosage Time 1", selection: $timeDay1M, displayedComponents: .hourAndMinute)
                    DatePicker("Monday Dosage Time 2", selection: $timeDay2M, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Monday Dosage Time 1", selection: $timeDay1M, displayedComponents: .hourAndMinute)
                    DatePicker("Monday Dosage Time 2", selection: $timeDay2M, displayedComponents: .hourAndMinute)
                    DatePicker("Monday Dosage Time 3", selection: $timeDay3M, displayedComponents: .hourAndMinute)
                }
            }
            
            if days == "Tuesday"
            {
                Picker("Number of Dosages:", selection: $timesDayTu)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDayTu == 1
                {
                    DatePicker("Tuesday Dosage Time", selection: $timeDay1Tu, displayedComponents: .hourAndMinute)
                }
                else if timesDayTu == 2
                {
                    DatePicker("Tuesday Dosage Time", selection: $timeDay1Tu, displayedComponents: .hourAndMinute)
                    DatePicker("Tuesday Dosage Time", selection: $timeDay2Tu, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Tuesday Dosage Time", selection: $timeDay1Tu, displayedComponents: .hourAndMinute)
                    DatePicker("Tuesday Dosage Time", selection: $timeDay2Tu, displayedComponents: .hourAndMinute)
                    DatePicker("Tuesday Dosage Time", selection: $timeDay3Tu, displayedComponents: .hourAndMinute)
                }
            }
            
            if days == "Wednesday"
            {
                Picker("Number of Dosages:", selection: $timesDayW)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDayW == 1
                {
                    DatePicker("Wednesday Dosage Time", selection: $timeDay1W, displayedComponents: .hourAndMinute)
                }
                else if timesDayW == 2
                {
                    DatePicker("Wednesday Dosage Time", selection: $timeDay1W, displayedComponents: .hourAndMinute)
                    DatePicker("Wednesday Dosage Time", selection: $timeDay2W, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Wednesday Dosage Time", selection: $timeDay1W, displayedComponents: .hourAndMinute)
                    DatePicker("Wednesday Dosage Time", selection: $timeDay2W, displayedComponents: .hourAndMinute)
                    DatePicker("Wednesday Dosage Time", selection: $timeDay3W, displayedComponents: .hourAndMinute)
                }
                
                
                    
            }
            
            if days == "Thursday"
            {
                Picker("Number of Dosages:", selection: $timesDayTh)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDayTh == 1
                {
                    DatePicker("Thursday Dosage Time", selection: $timeDay1Th, displayedComponents: .hourAndMinute)
                }
                else if timesDayTh == 2
                {
                    DatePicker("Thursday Dosage Time", selection: $timeDay1Th, displayedComponents: .hourAndMinute)
                    DatePicker("Thursday Dosage Time", selection: $timeDay2Th, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Thursday Dosage Time", selection: $timeDay1Th, displayedComponents: .hourAndMinute)
                    DatePicker("Thursday Dosage Time", selection: $timeDay2Th, displayedComponents: .hourAndMinute)
                    DatePicker("Thursday Dosage Time", selection: $timeDay3Th, displayedComponents: .hourAndMinute)
                }
            }
            
            if days == "Friday"
            {
                Picker("Number of Dosages:", selection: $timesDayF)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDayF == 1
                {
                    DatePicker("Friday Dosage Time", selection: $timeDay1F, displayedComponents: .hourAndMinute)
                }
                else if timesDayF == 2
                {
                    DatePicker("Friday Dosage Time", selection: $timeDay1F, displayedComponents: .hourAndMinute)
                    DatePicker("Friday Dosage Time", selection: $timeDay2F, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Friday Dosage Time", selection: $timeDay1F, displayedComponents: .hourAndMinute)
                    DatePicker("Friday Dosage Time", selection: $timeDay2F, displayedComponents: .hourAndMinute)
                    DatePicker("Friday Dosage Time", selection: $timeDay3F, displayedComponents: .hourAndMinute)
                }
                
                    
                    
                
            }
            
            if days == "Saturday"
            {
                Picker("Number of Dosages:", selection: $timesDaySa)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDaySa == 1
                {
                    DatePicker("Saturday Dosage Time", selection: $timeDay1Sa, displayedComponents: .hourAndMinute)
                }
                else if timesDaySa == 2
                {
                    DatePicker("Saturday Dosage Time", selection: $timeDay1Sa, displayedComponents: .hourAndMinute)
                    DatePicker("Saturday Dosage Time", selection: $timeDay2Sa, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Saturday Dosage Time", selection: $timeDay1Sa, displayedComponents: .hourAndMinute)
                    DatePicker("Saturday Dosage Time", selection: $timeDay2Sa, displayedComponents: .hourAndMinute)
                    DatePicker("Saturday Dosage Time", selection: $timeDay3Sa, displayedComponents: .hourAndMinute)
                }
                    
                    
            }
            
            if days == "Sunday"
            {
                Picker("Number of Dosages:", selection: $timesDaySu)
                {
                    ForEach(numbers, id:\.self)
                    {
                        Text("\($0)")
                    }
                }
                
                if timesDaySu == 1
                {
                    DatePicker("Sunday Dosage Time", selection: $timeDay1Su, displayedComponents: .hourAndMinute)
                }
                else if timesDaySu == 2
                {
                    DatePicker("Sunday Dosage Time", selection: $timeDay1Su, displayedComponents: .hourAndMinute)
                    DatePicker("Sunday Dosage Time", selection: $timeDay2Su, displayedComponents: .hourAndMinute)
                }
                else
                {
                    DatePicker("Sunday Dosage Time", selection: $timeDay1Su, displayedComponents: .hourAndMinute)
                    DatePicker("Sunday Dosage Time", selection: $timeDay2Su, displayedComponents: .hourAndMinute)
                    DatePicker("Sunday Dosage Time", selection: $timeDay3Su, displayedComponents: .hourAndMinute)
                }
                    
            }
        }
    }
}
