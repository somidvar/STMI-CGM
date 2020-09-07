//
//  PhonetoWatch.swift
//  continousHeartRateMonitor
//
//  Created by iMac on 3/9/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import Foundation
import WatchConnectivity
// ryan is here again

var session: WCSession!

class PhonetoWatch: NSObject, WCSessionDelegate, ObservableObject {
    @Published var watchLatitude = ""
    @Published var watchLongitude = ""
    @Published var watchAltitude = ""
    @Published var HeartRate = -99
    @Published var watchRoll = ""
    @Published var watchPitch = ""
    @Published var watchYaw = ""
    
    // Assign to local variable (can't update published variables with a delegate
    var wLatitude = ""
    var wLongitude = ""
    var wAltitude = ""
    var wRoll = ""
    var wPitch = ""
    var wYaw = ""
    var wHR = ""
    
    internal func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { 
        print("Message coming through")
        wLatitude = message["latitude"]! as! String
        wLongitude = message["longitude"]! as? String ?? "--"
        wAltitude = message["altitude"]! as! String
        wRoll = message["roll"]! as! String
        wPitch = message["pitch"]! as! String
        wYaw = message["yaw"]! as! String
        wHR = message["HR"]! as! String
        print("Phone received: \(wLatitude), \(wLongitude), \(wAltitude)")
    }
    
    func updateUI() {
        watchLatitude = wLatitude //Double(wLatitude)!.roundTo(places: 1)
        watchLongitude = wLongitude
        watchAltitude = wAltitude
        watchYaw = wYaw
        watchRoll = wRoll
        watchPitch = wPitch
        HeartRate = Int(wHR) ?? 0
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            print("WC session not supported)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    func sessionDidDeactivate(_ session: WCSession) {
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}