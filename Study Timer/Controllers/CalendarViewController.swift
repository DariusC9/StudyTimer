//
//  CalendarViewController.swift
//  Study Timer
//
//  Created by Darius Couti on 18.05.2023.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController {
    
    private var goalOptions: [String] {
        var array = [String]()
        for number in 0...30 {
            array.append("\(number) sessions a day")
        }
        return array
    }
    private var selectedRow = 0
    let calendarView = UICalendarView()
    let pickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createCalendar()
        view.backgroundColor = UIColor(red: 160/255, green: 191/255, blue: 224/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        calendarView.reloadDecorations(forDateComponents: [dateComponents], animated: true)
    }
    
    private func createCalendar() {
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.layer.cornerRadius = 15
        calendarView.backgroundColor = UIColor(red: 197/255, green: 223/255, blue: 248/255, alpha: 1)
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        calendarView.delegate = self


        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendarView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    private func createViews() {
        
        let goalLabel = UILabel()
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        goalLabel.text = "Pick your studying goal"
        goalLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 20)
        goalLabel.textColor = UIColor(red: 74/255, green: 85/255, blue: 162/255, alpha: 1.0)

        view.addSubview(goalLabel)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
        goalLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
        goalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        pickerView.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 10)
        ])
        
        if let savedRow = UserDefaults.standard.value(forKey: "SelectedRow") as? Int {
            selectedRow = savedRow
            pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        }
    }
}

    // MARK: - CalendarView Protocols

extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {

        if let dateComp = dateComponents {
            let detailVC = CalendarDetailsVC()
            detailVC.dateComponents = dateComp
            
            if let sheet = detailVC.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            self.present(detailVC, animated: true)
        }
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
        
        let todayCountFetched = CoreDataManager.shared.fetchTodayCountEntity(using: dateComponents)

        // if there is not an item saved on that day the decoration will be default
        guard let todayCount = todayCountFetched else {
            return .default()
        }
        let count = todayCount.count
        let goal = todayCount.goal
        if count == 0 && goal == 0{
            return .default()
        } else if count < goal {
            return .default(color: .red.withAlphaComponent(0.7), size: .medium)
        } else {
            return .default(color: .green.withAlphaComponent(0.7), size: .medium)
        }
    }
}

    // MARK: - PickerView protocols

extension CalendarViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goalOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return goalOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: goalOptions[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 74/255, green: 85/255, blue: 162/255, alpha: 1.0)])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        UserDefaults.standard.setValue(selectedRow, forKey: "SelectedRow")
        UserDefaults.standard.synchronize()
        
        let todayCount = CoreDataManager.shared.fetchTodayCountEntity()
        todayCount?.goal = Int16(selectedRow)
        CoreDataManager.shared.saveContext()
        
        //refresh data for calendarView
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        calendarView.reloadDecorations(forDateComponents: [dateComponents], animated: true)
       
    }
}
