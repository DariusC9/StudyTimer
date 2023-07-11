//
//  UserDefaults.swift
//  Study Timer
//
//  Created by Darius Couti on 04.07.2023.
//

import Foundation
import UIKit

extension UserDefaults {
    var userTimer: Int {
        get {
            // TODO: Change 1 to 60
            UserDefaults.standard.value(forKey: "userTimer") as? Int ?? 40 * 1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userTimer")
        }
    }
    
    var isFirstLauch: Bool {
        get {
            UserDefaults.standard.object(forKey: "isFirstLaunch") == nil ? true : UserDefaults.standard.bool(forKey: "isFirstLaunch")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFirstLaunch")
        }
    }
    
    var timerIsOn: Bool {
        get {
            UserDefaults.standard.object(forKey: "timerIsOn") == nil ? false : UserDefaults.standard.bool(forKey: "timerIsOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "timerIsOn")
        }
    }
}
