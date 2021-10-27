//
//  LocalNotificationManager.swift
//  Wake Up
//
//  Created by Robert Kutter on 10/23/21.
//

import Foundation
import SwiftUI

class LocalNotificationManager: ObservableObject {
    
    //var notifications = [Notification]()
    
    init() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    print("Notifications permitted")
                } else {
                    print("Notifications not permitted")
                }
            }
        }
    
    func startNotifications(interval: Double, variance: Double, length: Double) -> String {
        
        // cancel any previous notifications we added
        stopNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Wake Up!"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName.init("blow.caf"))
        
        var lowerBound = interval - variance
        if lowerBound <= 0 {
            lowerBound = interval
        }
        let upperBound = interval + variance
        var count = 0
        var nextInterval = length
        
        repeat {
            if count == 0 {
                content.body = "Completed"
            }
            else {
                content.body = String(count+1)
            }
            print(content.body+" at "+String(format: "%.2f", nextInterval/60))
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: nextInterval,
                                                            repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
            // ensure we don't exceed app limit
            count += 1
            if count == 50 {
                return "Max 50 timers set. Increase interval for full length."
            }
            
            if variance > 0 {
                nextInterval -= Double.random(in: lowerBound..<upperBound)
            }
            else {
                nextInterval -= interval
            }
        } while (nextInterval > 0.0)
        
        return "Press home to receive notifications."
     }
    
    func stopNotifications() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
     }

}
