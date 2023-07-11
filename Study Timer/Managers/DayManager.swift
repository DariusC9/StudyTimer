//
//  DayManager.swift
//  Study Timer
//
//  Created by Darius Couti on 23.05.2023.
//

import Foundation

class DayManager {
    
    var dateComponents: DateComponents
    
    init(dateComponents: DateComponents) {
        self.dateComponents = dateComponents
    }
    
    func findSelectedDay() -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            return Date.now
        }
        
        return date
    }
    
    func transformDateIntoString() -> String {
        let date = findSelectedDay()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
