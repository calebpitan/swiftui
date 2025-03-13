//
//  ContentView.swift
//  BetterRest
//
//  Created by Caleb Adepitan on 09/03/2025.
//

import CoreML
import SwiftUI

extension Binding {
    @MainActor
    func onChange(_ perform: @escaping (Value) -> Void) -> Binding<Value> {
        return .init(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                perform(newValue)
            }
        )
    }
}

struct SleepSettings: Equatable {
    let sleepAmount: Double
    let wakeUp: Date
    let coffeeAmount: Int
}

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1

    var sleepSettings: SleepSettings {
        SleepSettings(sleepAmount: sleepAmount, wakeUp: wakeUp, coffeeAmount: coffeeAmount)
    }

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        GroupBox("When do you want to wake up?") {
                            HStack {
                                Text("Time")
                                Spacer()
                                DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                        }

                        GroupBox("Desired amount of sleep") {
                            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4 ... 12, step: 0.25)
                        }

                        GroupBox("Daily coffee intake") {
                            HStack {
                                Picker(coffeeAmount == 1 ? "Cup" : "Cups", selection: $coffeeAmount) {
                                    ForEach(1 ... 20, id: \.self) { i in
                                        Text("\(i)").tag(i)
                                    }
                                }
                                .pickerStyle(.navigationLink)
                            }
                        }
                    }
                    .onChange(of: sleepSettings, initial: true) { _, _ in
                        calculateBedtime()
                    }
                    
                    Spacer()

                    VStack(alignment: .center, spacing: 20) {
                        Text(alertTitle)
                            .font(.title.weight(.light))
                        Text(alertMessage)
                            .font(.largeTitle.bold())
                    }
                    .padding()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("BetterRest")
        }
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let time = hhmm(wakeUp)
            let hour = time.0 * 60 * 60
            let minute = time.1 * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep

            alertTitle = "Your ideal bedtime is:"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error!"
            alertMessage = "There was a problem calculating your bedtime. Please try again later."
        }

        showingAlert = true
    }

    func hhmm(_ someDate: Date) -> (Int, Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: someDate)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        return (hour, minute)
    }
}

#Preview {
    ContentView()
}
