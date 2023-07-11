//
//  CalendarDetailsVC.swift
//  Study Timer
//
//  Created by Darius Couti on 21.05.2023.
//

import UIKit
import CoreData

class CalendarDetailsVC: UIViewController {
    
    private var countLabel = UILabel()
    private var messageLabel = UILabel()
    private var goalLabel = UILabel()
    private var dissmisButton = UIButton()
    var dateComponents = DateComponents()
    private var selectedTodayCount: TodayCount? {
        let todayCount = CoreDataManager.shared.fetchTodayCountEntity(using: dateComponents)
        return todayCount
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLabels()
        view.backgroundColor = UIColor(red: 121/255, green: 210/255, blue: 220/255, alpha: 1)
    }
    
    private func createLabels() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.text = createTextCountLabel(from: dateComponents)
        view.addSubview(countLabel)
        
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        goalLabel.text = createTextGoalLabel()
        view.addSubview(goalLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = createTextmessageLabel()
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        view.addSubview(messageLabel)
        
        
        dissmisButton.translatesAutoresizingMaskIntoConstraints = false
        dissmisButton.setTitle("Dismiss", for: .normal)
        dissmisButton.setTitleColor(UIColor(red: 67/255, green: 154/255, blue: 151/255, alpha: 1.0), for: .normal)
        dissmisButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        dissmisButton.backgroundColor = UIColor(red: 140/255, green: 220/255, blue: 222/255, alpha: 1.0)
        dissmisButton.layer.cornerRadius = 20
        dissmisButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(dissmisButton)
        
        
        NSLayoutConstraint.activate([
            countLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -130),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 350),
            
            goalLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            goalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dissmisButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            dissmisButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dissmisButton.widthAnchor.constraint(equalToConstant: 150), // Adjust width as desired
            dissmisButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createTextCountLabel(from dateComponents: DateComponents) -> String {
        // transform the date into a string to show on label
        let dayManager = DayManager(dateComponents: dateComponents)
        let dateString = dayManager.transformDateIntoString()
        // change the text of the label depending if it exist an todayCount item created in that day or not
        guard let sesionsCount = selectedTodayCount?.count else {
            return "No history on \(dateString)"
        }
        return "\(dateString) study sessions: \(sesionsCount)"
    }
    
    private func createTextGoalLabel() -> String {
        // change the text of the label depending if it exist an todayCount item created in that day or not
        guard let goalSesions = selectedTodayCount?.goal else {
            return ""
        }
        if goalSesions == 0 {
            return "Set your daily goal and start learning"
        } else {
            return "Goal: \(goalSesions) sessions"
        }
    }
    
    private func createTextmessageLabel() -> String {
        // check to see if is an object saved in the selected date
        guard let todayCount = selectedTodayCount else {
            return ""
        }
        let count = todayCount.count
        let goal = todayCount.goal
        
        if count == 0 {
            return "Start the day by doing your first study session"
        } else if count < goal {
            let messageArray = [
                "You can do this",
                "There are not many, keep going",
                "Come on, don.t stop"
            ]
            
            let randomMessage = messageArray.randomElement() ?? ""
            return randomMessage
        } else {
            return "You reached your goal, congrats! Maybe set up a higher goal in the future"
        }
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
