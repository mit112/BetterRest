//
//  ContentView.swift
//  BetterRest
//
//  Created by Mit Sheth on 1/17/24.
//
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wake = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 2
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
        
    }
    var body: some View {
        NavigationStack {
            Form {
                VStack (alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Time to wake up", selection: $wake, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack (alignment: .leading, spacing: 0) {
                    Text("How much sleep would you like?")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 2...12, step: 0.25)
                }
                VStack (alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text($0, format: .number)
                        }
                    }
                    .pickerStyle(.menu)
//                    Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 0...20)
                }
                HStack (alignment: .center, spacing: 0) {
                    Spacer()
                    Button("Calculate", action: calculateBedtime)
                        .font(.title)
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .frame(maxWidth: 175)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12.0)
                                .stroke(Color.black)
                        )
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12.0))
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wake)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            let sleepTime = wake - prediction.actualSleep
            alertTitle = "Your ideal wake up time is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }
        catch {
            alertTitle = "Error"
            alertMessage = "There was an error calculating your bedtime."
        }
        showAlert = true
        }
    }

#Preview {
    ContentView()
}
