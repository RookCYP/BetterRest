//
//  ContentView.swift
//  BetterRest
//
//  Created by Rook on 10.07.2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationStack{
            Form {
                VStack(alignment: .leading,spacing: 0) {
                    Text("Когда ты хочешь просыпаться?")
                        .font(.headline)
                    
                    DatePicker("Введи время", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading,spacing: 0) {
                    
                    Text("Сколько необходимо спать")
                    Stepper("\(sleepAmount.formatted() ) часов", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading,spacing: 0) {
                    Text("Количество выпиваемых энергетиков в день")
                        .font(.headline)
                  
                    Picker("Количество кружек", selection : $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.navigationLink)
                    //  Stepper("\(coffeeAmount) шт", value: $coffeeAmount, in: 1...20)
                    
                    Section{
                    
                    }
                }
            }
            .navigationTitle("Лучший отдых")
            .toolbar {
               Button("Расчитать", action: calculateBadTime)
               }
          .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
           } message: {
                Text(alertMessage)
            }
            }
        }
 func calculateBadTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from : wakeUp)
            let hour = (components.minute ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Наилучшее время лечь спать"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Ошибка"
            alertMessage = "Не удалось выполнить расчет"
            }
        showingAlert = true
        }
    }


#Preview {
    ContentView()
}
