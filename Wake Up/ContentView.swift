//
//  ContentView.swift
//  Wake Up
//
//  Created by Robert Kutter on 10/22/21.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var interval = UserDefaults.standard.integer(forKey: "interval") // minutes
    @State private var variance = UserDefaults.standard.integer(forKey: "variance") // minutes
    @State private var length = UserDefaults.standard.integer(forKey: "length") // hours
    
    var sounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Pop", "Purr", "Sosumi", "Tink"]
    @State private var selectedSound = UserDefaults.standard.string(forKey: "sound") ?? "Default"
    @State private var soundEffect: AVAudioPlayer?
    
    @State private var helpText = ""
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var notifyMgr = LocalNotificationManager()

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Form {
                    Section {
                        Stepper("\(interval) minute interval", value: $interval, in: 1...60)
                            .onChange(of: interval) { newValue in
                                UserDefaults.standard.set(interval, forKey: "interval")
                            }
                        Stepper("\(variance) minute jitter", value: $variance, in: 0...15)
                            .onChange(of: variance) { newValue in
                                UserDefaults.standard.set(variance, forKey: "variance")
                            }
                        Stepper("\(length) hour length", value: $length, in: 1...8)
                            .onChange(of: length) { newValue in
                                UserDefaults.standard.set(length, forKey: "length")
                            }
                    }
                    Section {
                        Picker("Notification Sound", selection: $selectedSound) {
                            ForEach(sounds, id: \.self) {
                                Text($0)
                            }
                        }
                        .onChange(of: selectedSound) { newValue in
                            let path = Bundle.main.path(forResource: selectedSound+".caf", ofType:nil)!
                            let url = URL(fileURLWithPath: path)

                            do {
                                soundEffect = try AVAudioPlayer(contentsOf: url)
                                soundEffect?.play()
                            } catch {
                                print("failed to load sound file")
                            }
                            UserDefaults.standard.set(selectedSound, forKey: "sound")
                        }
                    }
                    Section {
                        Button("Start Timer") {
                            helpText = notifyMgr.startNotifications(interval: 60*Double(interval),
                                                                    variance: 60*Double(variance),
                                                                    length: 3600*Double(length),
                                                                    sound: selectedSound)
                        }
                        Button("Stop Timer") {
                            notifyMgr.stopNotifications()
                            helpText = "Timers stopped."
                        }
                    }
                    Section {
                        Text(helpText)
                    }
                }
            }
            .navigationTitle("Wake Up!")
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    helpText = "Press home to receive notifications."
                }
                else if phase == .background || phase == .inactive {
                    helpText = ""
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
