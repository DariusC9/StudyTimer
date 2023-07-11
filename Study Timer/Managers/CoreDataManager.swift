//
//  CoreDataManager.swift
//  Study Timer
//
//  Created by Darius Couti on 19.05.2023.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Study_Timer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func fetchTodayCountEntity() -> TodayCount? {
        let fetchRequest: NSFetchRequest<TodayCount> = TodayCount.fetchRequest()
        
        // Set the predicate to filter by the current day
        fetchRequest.predicate = createPredicate(for: Date())
        
        do {
            let todayCounts = try mainContext.fetch(fetchRequest)
            return todayCounts.first
        } catch {
            fatalError("Failed to fetch TodayCount entity: \(error)")
        }
    }
    
     func fetchTodayCountEntity(from date: Date) -> TodayCount? {
        
        let fetchRequest: NSFetchRequest<TodayCount> = TodayCount.fetchRequest()
         
        // Set the predicate to filter by the date we search for
        fetchRequest.predicate = createPredicate(for: date)
        
        do {
            let todayCounts = try mainContext.fetch(fetchRequest)
            return todayCounts.first
        } catch {
            fatalError("Failed to fetch TodayCount entity: \(error)")
        }
    }
    
    func fetchTodayCountEntity(using dateComponents: DateComponents) -> TodayCount? {
        // create a Date from DateComponents
        let dayManager = DayManager(dateComponents: dateComponents)
        let date = dayManager.findSelectedDay()
        
        let fetchRequest: NSFetchRequest<TodayCount> = TodayCount.fetchRequest()
         
        // Set the predicate to filter by the date we search for
        fetchRequest.predicate = createPredicate(for: date)
        
        do {
            let todayCounts = try mainContext.fetch(fetchRequest)
            return todayCounts.first
        } catch {
            fatalError("Failed to fetch TodayCount entity: \(error)")
        }
    }

    
    func createTodayCountEntityIfNeeded() {
        
        let fetchRequest: NSFetchRequest<TodayCount> = TodayCount.fetchRequest()
        
        // Set the predicate to filter by the current day
        fetchRequest.predicate = createPredicate(for: Date())
        
        do {
            let todayCounts = try mainContext.fetch(fetchRequest)
            if todayCounts.isEmpty {
                guard let entity = NSEntityDescription.entity(forEntityName: "TodayCount", in: mainContext) else {
                    fatalError("Failed to retrieve entity description for TodayCount")
                }
                
                let todayCount = TodayCount(entity: entity, insertInto: mainContext)
                todayCount.count = 0
                todayCount.date = Date()
                if let userSelectedGoal = UserDefaults.standard.value(forKey: "SelectedRow") as? Int {
                    todayCount.goal = Int16(userSelectedGoal)
                } else {
                    todayCount.goal = 0
                }
                saveContext()
            }
        } catch {
            fatalError("Failed to fetch TodayCount entity: \(error)")
        }
    }
    
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Private methods
    
    private func createPredicate(for date: Date) -> NSPredicate {
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? Date.now

        return NSPredicate(format: "(date >= %@) AND (date < %@)", startDate as NSDate, endDate as NSDate)
    }
}
