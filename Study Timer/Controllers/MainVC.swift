//
//  MainVC.swift
//  Study Timer
//
//  Created by Darius Couti on 09.05.2023.
//

import UIKit
import CoreData
import NotificationCenter

class MainVC: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var startSessionButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var countSessionsLabel: UILabel!
    @IBOutlet weak var timeRemainedLabel: UILabel!
    
    private var timer: Timer?
    private var timerManager = TimerManager()
    private var userTimer = UserDefaults.standard.userTimer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createNotificationCenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.isFirstLauch {
            UserDefaults.standard.isFirstLauch = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.performSegue(withIdentifier: "ToThePreviewVC", sender: self)
            }
        }
    }
    
    // MARK: - View methods
    
    private func createViews() {
        
        // button dimensions: 231 width, 231 height
        // button views
        startSessionButton.layer.cornerRadius = startSessionButton.frame.width / 2
        startSessionButton.layer.masksToBounds = true
        startSessionButton.layer.borderWidth = 2.0
        startSessionButton.layer.borderColor = UIColor(red: 74/255, green: 85/255, blue: 162/255, alpha: 1.0).cgColor
        
        // creating shadow gradient on button
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = startSessionButton.bounds
        gradientLayer.colors = [
            UIColor(red: 160/255, green: 191/255, blue: 224/255, alpha: 1.0).cgColor,
            UIColor(red: 69/255, green: 96/255, blue: 123/255, alpha: 1.0).cgColor,
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = startSessionButton.layer.cornerRadius
        startSessionButton.layer.addSublayer(gradientLayer)
        
        // adding shadow
        startSessionButton.layer.shadowColor = UIColor.darkGray.cgColor
        startSessionButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        startSessionButton.layer.shadowRadius = 2
        startSessionButton.layer.shadowOpacity = 0.5
        
        //creating play symbol
        buttonSymbol()
        
        // initial state of progression bar
        progressBar.progress = 0
        
        // slider settings
        timerSlider.value = Float(userTimer / 1)
        let timerBool = timerManager.getTimerIsOn()
        timerSlider.isUserInteractionEnabled = !timerBool
        
        // text of the timerLabel
        timerLabel.text = "\(userTimer) minutes"
        
        // modify the session label
        modifySessionLabel()
    }
    
    private func modifySessionLabel() {
        if let todayCount = CoreDataManager.shared.fetchTodayCountEntity() {
            countSessionsLabel.text = "Sessions done today: \(todayCount.count)"
        }
    }
    
    private func buttonSymbol() {
        let timerBool = timerManager.getTimerIsOn()
        if timerBool {
            let pauseSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 75)
            let pauseSymbol = UIImage(systemName: "pause.fill", withConfiguration: pauseSymbolConfiguration)?.withTintColor(UIColor(red: 74/255, green: 85/255, blue: 162/255, alpha: 1.0), renderingMode: .alwaysOriginal)
            startSessionButton.setImage(pauseSymbol, for: .normal)
            
        } else {
            let playSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 75)
            let playSymbol = UIImage(systemName: "play.fill", withConfiguration: playSymbolConfiguration)?.withTintColor(UIColor(red: 74/255, green: 85/255, blue: 162/255, alpha: 1.0), renderingMode: .alwaysOriginal)
            
            startSessionButton.setImage(playSymbol, for: .normal)
        }
    }
    
    // MARK: - Action methods
    
    @IBAction func startSesionButtonPressed(_ sender: UIButton) {
        let timerBool = timerManager.getTimerIsOn()
        if timerBool == false {
            checkForPermission()
            timerManager.setupStartTime()
            timerManager.changeTimerIsOn()
            UserDefaults.standard.timerIsOn = true
            startTimer()
            buttonSymbol()
        } else {
            alertDuringSesion()
            buttonSymbol()
        }
    }
    
    @IBAction func timerSliderChanged(_ sender: UISlider) {
        let timerBool = timerManager.getTimerIsOn()
        if timerBool {
            let alert = UIAlertController(title: "Slider Disabled", message: "You cannot change the slider during the study session.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert,animated: true)
            
        } else {
            let timer = String(format: "%.0f", sender.value)
            timerLabel.text = "\(timer) minutes"
            userTimer = Int(sender.value) * 1
            UserDefaults.standard.userTimer = userTimer
            timerManager.changeRemainingTime(newValue: userTimer)
        }
    }
    
    //MARK: - Timer methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer() {
        timerManager.increaseTimerCount()
        
        let timerCountForUI = timerManager.getTimerCountForUI()
        let timerCount = timerManager.getTimerCount()
        
        let percentageProgress = Float(timerCountForUI) / Float(userTimer)
        progressBar.progress = percentageProgress
        
        let timeRemained = Int(userTimer) - Int(timerCountForUI)
        timeRemainedLabel.text = "Time remained: \(timeRemained)"
        
        let remainingTime = timerManager.getRemainingTime()
        if timerCount >= remainingTime {
            alertFinalSesion()
            incrementSesionCount()
            resetTimer()
            progressBar.progress = 0
        }
    }
    
    
    private func alertFinalSesion() {
        let alert = UIAlertController(title: "Studying Session Finished", message: "Congratulations! You completed a studying session! Go take a well deserved break and come back for another session.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert,animated: true)
    }
    
    private func alertDuringSesion() {
        let alert = UIAlertController(title: "Cancel the current study session", message: "Are you sure you want to cancel this study session? All your progress will be lost. You have n minutes until you finish it, you can do it!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel it", style: .destructive) { _ in
            self.resetTimer()
        }
        
        let returnAction = UIAlertAction(title: "Return to session", style: .cancel) { _ in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(returnAction)
        present(alert, animated: true)
    }
    
    private func incrementSesionCount() {
        if let todayCount = CoreDataManager.shared.fetchTodayCountEntity() {
            todayCount.count += 1
            CoreDataManager.shared.saveContext()
        }
        modifySessionLabel()
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        timerManager.changeTimerIsOn()
        timerManager.reset()
        buttonSymbol()
        progressBar.progress = 0
        timeRemainedLabel.text = "Time remained:  "
        UserDefaults.standard.set(false, forKey: "timerIsOn")
        UserDefaults.standard.set(nil, forKey: "endDate")
    }
    
    //MARK: - NotificationCenter Methods
    
    private func createNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnteredBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillBeTerminated), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIScene.didActivateNotification, object: nil)
    }
    
    @objc func appDidEnteredBackground() {
        let timerBool = timerManager.getTimerIsOn()
        if timerBool {
            self.dismiss(animated: true, completion: nil)
            let remainingTime = timerManager.getRemainingTime()
            let currentCount = timerManager.getTimerCount()
            let differance = remainingTime - currentCount
            let endDate = timerManager.setupEndTime(differance)
            // create the notification if the user doesn't open the app
            createNotification(for: endDate)
            UserDefaults.standard.set(endDate, forKey: "endDate")
            timer?.invalidate()
            timer = nil
            timerManager.resetTimer()
        }
        
    }
    
    @objc func appWillBeTerminated() {
        let timerBool = timerManager.getTimerIsOn()
        if timerBool {
            let remainingTime = timerManager.getRemainingTime()
            let currentCount = timerManager.getTimerCount()
            let differance = remainingTime - currentCount
            let endDate = timerManager.setupEndTime(differance)
            // create the notification if the user doesn't open the app
            createNotification(for: endDate)
            UserDefaults.standard.set(endDate, forKey: "endDate")
            timer?.invalidate()
            timer = nil
            timerManager.resetTimer()
        }
    }
    
    @objc func appDidBecomeActive() {
        
        let timerBool = UserDefaults.standard.timerIsOn
        if let endDate = UserDefaults.standard.value(forKey: "endDate") as? Date,
           timerBool {
            
            let didFinish = timerManager.checkIfTimerDidFinish(for: endDate)
            if didFinish {
                incrementSesionCount()
                resetTimer()
            } else {
                deleteNotification()
                timerManager.getRemainingTimeAfterClosingApp(using: endDate)
                timerManager.setupTimerforUI()
                startTimer()
                buttonSymbol()
            }
        }
    }
    
    //MARK: - Local Notification Methods
    
    private func checkForPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("This is the error: \(error) ")
            }
        }
    }
    
    private func createNotification(for endDate: Date) {
        // create the content of notification request
        let content = UNMutableNotificationContent()
        content.title = "Study Session Finished"
        content.body = "Your study session has finished! Take a well deserved break"
        content.sound = .default
        // timeDifferance will be used to know the timeInterval for the trigger
        let currentDate = Date()
        let endDate = endDate
        let timeDifferance = endDate.timeIntervalSince(currentDate)
        // creating the trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeDifferance, repeats: false)
        // creating the request
        let request = UNNotificationRequest(identifier: "timerNotification", content: content, trigger: trigger)
        // registering the request
        UNUserNotificationCenter.current().add(request) { (error) in
        }
    }
    
    private func deleteNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerNotification"])
    }
}
