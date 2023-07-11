//
//  TimerManager.swift
//  Study Timer
//
//  Created by Darius Couti on 27.06.2023.
//

import Foundation
import UIKit

struct TimerManager {
    
    private var timerIsOn: Bool = false
    private var start: Double = 0
    private var timerCount = 0
    private var elapsedTime: Double = 0
    private var elapsedTimerCount = 0
    private var endDate: Date?
    private var remainingTime = UserDefaults.standard.userTimer
    
    
    mutating func setupStartTime() {
        start = Date().timeIntervalSinceReferenceDate
    }
    
    mutating func setupEndTime(_ remainingTime: Int) -> Date {
        let timeInterval = TimeInterval(remainingTime)
        endDate = Date().addingTimeInterval(timeInterval)
        guard let endDate = endDate else {return Date()}
        return endDate
    }
    
    mutating func setupTimerforUI() {
        elapsedTimerCount = Int(Date().timeIntervalSinceReferenceDate - start)
    }
    
    mutating func checkIfTimerDidFinish(for date: Date) -> Bool {
        let currentDate = Date()
        endDate = date
        if currentDate > endDate ?? Date() {
            return true
        } else {
            return false
        }
    }
    
    mutating func getRemainingTimeAfterClosingApp(using date: Date) {
        let currentDate = Date()
        endDate = date
        let differance = Int(endDate?.timeIntervalSince(currentDate) ?? 0)
        
        remainingTime = differance
    }
    
    mutating func increaseTimerCount() {
        timerCount += 1
    }
    
    mutating func timerWasPaused() {
        elapsedTime = Date().timeIntervalSinceReferenceDate - start

        remainingTime -= Int(elapsedTime)
        elapsedTimerCount += timerCount
        timerCount = 0
    }
    
    mutating func resetTimer() {
        timerCount = 0
    }
    
    mutating func reset() {
        start = 0
        resetTimer()
        elapsedTime = 0
        elapsedTimerCount = 0
        endDate = nil
        remainingTime = UserDefaults.standard.userTimer
    }
    
    mutating func changeTimerIsOn() {
        timerIsOn.toggle()
    }
    
    mutating func changeRemainingTime(newValue: Int) {
        remainingTime = newValue
    }
    
    func getTimerCountForUI() -> Int {
        return timerCount + elapsedTimerCount
    }
    
    func getTimerCount() -> Int {
        return timerCount
    }
    
    func getTimerIsOn() -> Bool {
        return timerIsOn
    }
    
    func getRemainingTime() -> Int {
        return remainingTime
    }
}

