//
//  ViewController.swift
//  STOPWATCH
//
//  Created by avi leung on 7/9/20.
//  Copyright © 2020 avi leung. All rights reserved.
//

import UIKit
/*Main(Default) View Controller*/
class ViewController: UIViewController {
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var workedLabel: UILabel!
    var percent = 10    //necessary for deepWorkFocus function
    var counter = 0.0
    var timer = Timer()
    var isPlaying = false
    var disableButtons = false
    //STORED USERDEFAULT VALUES
    //** VARIABLES THAT CHECK BETWEEN DAYS**
    //"trackDates"  ---- Dictionary tracking date string value to amount of time worked as double value
    //"Key" ---- Value storing double with amount of hours worked today
    //"date" ---- Previous date value meaning last date user opened the application
    //**VARIABLES THAT CHECK BETWEEN WEEKS**
    //"mostRecentMonday" --- Variable containing the date of the first monday of this week
    //"weeklySum" --- variable containing the sum of hours worked for this week
    //TOTAL TIME STOPWATCH HAS RUN FOR PERIOD
    //"trackTotals" --- Dictionary linking date string value to rating of focus within specified interval
    //"weeklySumAppUse" --- variable containing the sum of hours user has used the app
    //"useKey" --- Value storing double with amount of hours app used today
    //METHOD OF APPROACH PERCENT FOCUS
    //for daily
    //set "useKey" to count in the stop method
    //in check timer values, after if statement assign use key to date in "trackTotals"
    //reset "useKey" to 0 or count
    //for totals
    //In check week put "key" / "useKey" in value for the week
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNotificationCenter()
        initTimeLabel()
        checkTimerValues()
        pauseButton.isEnabled = false
    }
    func initTimeLabel(){
        /*INITIALIZES THE TIME WORKED LABEL*/
        //"trackDates"  ---- Dictionary tracking date string value to amount of time worked as double value
        var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
        let theKeys = theDict?.keys
        let theKeysLength = theKeys?.count
        //Initializes timeLabel
        timeLabel.text = "00:00:00.0"
        //"Key" ---- Value storing double with amount of hours worked today
        let worked = UserDefaults.standard.double(forKey: "Key")
        //Format and Display hours worked today
        let msg = secondsToHoursMinutesSecondsForDisplay(seconds: Int(worked))
        workedLabel.text = msg
    }
    func setUpNotificationCenter(){
        //Set up functions for when app goes into background and comes back into foreground
        NotificationCenter.default.addObserver(self, selector: #selector(pauseWhenBackground(noti:)), name:UIApplication.didEnterBackgroundNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(noti:)), name:UIApplication.willEnterForegroundNotification , object: nil)
    }
    @IBAction func instructionalPopUp() {
        /* Called if the user tries to hit the next button white the timer is running. */
        let alert = UIAlertController(title: "Work Session In Progress",
        message: "You cannot scroll between pages while a work session is in progress as it takes away from focus. Please Stop the timer if you would like to perform the action.",
        preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok",
                                          style: .default) { (action) in}
        alert.addAction(defaultAction)
        self.present(alert, animated: true) {
              // The alert was presented
           }
    }
    @IBAction func deepWorkFocus() {
       /* Called after the user finishes a deep work session to prompt user for their rating of focus. */
       let alert = UIAlertController(title: "Focus Check",
        message: "On a Scale of 0 to 10, 0 being not working and 10 being completely focused, what level of focus were you at?",
        preferredStyle: .alert)
       // Create the action buttons for the alert.
       let defaultAction = UIAlertAction(title: "Ok",
                            style: .default) { (action) in
                                let userInput = alert.textFields?.first?.text
                                let userInputInteger = Int(userInput!)
                                if userInput!.isInt && userInputInteger! >= 0 && userInputInteger! <= 10 {
                                    self.percentFocusInputted(userInputInteger: userInputInteger!)
                                } else{
                                    //If the input is invalid call the function again
                                    self.deepWorkFocus()
                                }
       }
       let cancelAction = UIAlertAction(title: "I did not work",
                            style: .cancel) { (action) in
                                self.userDidNotWork()
       }
       // Create and configure the alert controller.
       alert.addAction(defaultAction)
       alert.addAction(cancelAction)
       alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Any number between 0 and 10."
        })
       self.present(alert, animated: true) {
          // The alert was presented
       }
    }
    func percentFocusInputted(userInputInteger: Int){
        /*Called when user inputs a valid rating for their level of focus, and updates values accordingly*/
        if UserDefaults.standard.double(forKey: "useKey") == nil{
            UserDefaults.standard.set(0.0,forKey: "useKey")
        }
        let used = UserDefaults.standard.double(forKey: "useKey")
        UserDefaults.standard.set(used + self.counter, forKey: "useKey")
        let worked = UserDefaults.standard.double(forKey: "Key")
        let actualTimeFocused = Int(self.counter) * userInputInteger/10
        let converstion = worked + Double(actualTimeFocused)
        let weeklySum = UserDefaults.standard.object(forKey: "weeklySum")
        let weeklySumAppUse = UserDefaults.standard.object(forKey: "weeklySumAppUse")
        UserDefaults.standard.set(weeklySum as! Double + converstion, forKey: "weeklySum")
        UserDefaults.standard.set(weeklySumAppUse as! Double + self.counter, forKey: "weeklySumAppUse")
        UserDefaults.standard.set(converstion, forKey: "Key")
        self.isPlaying = false
        self.counter = 0.0
        self.timeLabel.text = "00:00:00.0"
        let msg = self.secondsToHoursMinutesSecondsForDisplay(seconds: Int(converstion))
        self.workedLabel.text = msg
    }
    func userDidNotWork(){
        /*Called when user did not do any work in that session*/
        if UserDefaults.standard.double(forKey: "useKey") == nil{
            UserDefaults.standard.set(0.0, forKey: "useKey")
        }
        let used = UserDefaults.standard.double(forKey: "useKey")
        let weeklySumAppUse = UserDefaults.standard.object(forKey: "weeklySumAppUse")
        UserDefaults.standard.set(weeklySumAppUse as! Double + self.counter, forKey: "weeklySumAppUse")
        UserDefaults.standard.set(used + self.counter, forKey: "useKey")
        self.isPlaying = false
        self.counter = 0.0
        self.timeLabel.text = "00:00:00.0"
    }
    @IBAction func startTimer(_ sender: Any) {
        if(isPlaying) {
            return
        }
        startButton.isEnabled = false
        pauseButton.isEnabled = true
        disableButtons = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
    }
    @IBAction func pauseTimer(_ sender: AnyObject) {
        startButton.isEnabled = true
        pauseButton.isEnabled = false
        disableButtons = false
        timer.invalidate()
        checkTimerValues()
        deepWorkFocus()
    }
    @IBAction func disableNextButton(_ sender: AnyObject){
        /*Makes sure user is not pressing invalid buttons while timer is running*/
        if disableButtons == true{
            instructionalPopUp()
        }
    }
    func checkTimerValues() {
        //Checks current date and compares it to previous date variable. Proceeds to assign values to userdefaults(cache) accordingly.
        checkWeek()
        let today = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if UserDefaults.standard.object(forKey: "date") == nil{
            UserDefaults.standard.set(NSDate(), forKey: "date")
        }
        let prevDate = UserDefaults.standard.object(forKey: "date") //as! NSDate
        let stoday = dateFormatter.string(from: today as Date)
        let sprevday = dateFormatter.string(from: prevDate as! Date) // as Date
        if stoday.compare(sprevday) == .orderedDescending {
            workedLabel.text = "00:00"
            if UserDefaults.standard.object(forKey: "trackDates") == nil{
                var emptyDict: [String: Double] = [:]
                UserDefaults.standard.set(emptyDict, forKey: "trackDates")
            }
            if UserDefaults.standard.object(forKey: "trackTotals") == nil{
                var trackTotals: [String: Double] = [:]
                UserDefaults.standard.set(trackTotals, forKey: "trackTotals")
            }
            if UserDefaults.standard.object(forKey: "useKey") == nil{
                UserDefaults.standard.set(0.0, forKey: "useKey")
            }
            var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
            var theDictUse = UserDefaults.standard.object(forKey: "trackTotals") as? [String: Double]
            let worked = UserDefaults.standard.double(forKey: "Key")
            let used = UserDefaults.standard.double(forKey: "useKey")
            theDictUse?[sprevday] = worked / used
            theDict?[sprevday] = worked
            UserDefaults.standard.set(theDict, forKey: "trackDates")
            UserDefaults.standard.set(theDictUse, forKey: "trackTotals")
            UserDefaults.standard.set(0, forKey: "Key")
            UserDefaults.standard.set(0, forKey: "useKey")
            UserDefaults.standard.set(NSDate(), forKey: "date")
        }
    }
    func checkWeek() {
        //Checks current week and compares it to previous week variable. Proceeds to assign values to userdefaults(cache) accordingly.
        let today = NSDate()
        let mon = Date().currentWeekMonday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if UserDefaults.standard.object(forKey: "mostRecentMonday") == nil{
            UserDefaults.standard.set(mon, forKey: "mostRecentMonday")
        }
        if UserDefaults.standard.object(forKey: "weeklySumAppUse") == nil{
            UserDefaults.standard.set(0, forKey: "weeklySumAppUse")
        }
        if UserDefaults.standard.object(forKey: "trackDates") == nil{
            var emptyDict: [String: Double] = [:]
            UserDefaults.standard.set(emptyDict, forKey: "trackDates")
        }
        if UserDefaults.standard.object(forKey: "weeklySum") == nil{
            UserDefaults.standard.set(0, forKey: "weeklySum")
        }
        if UserDefaults.standard.object(forKey: "trackTotals") == nil{
            var trackTotals: [String: Double] = [:]
            UserDefaults.standard.set(trackTotals, forKey: "trackTotals")
        }
        let prevMon = UserDefaults.standard.object(forKey: "mostRecentMonday")
        let weeklySum = UserDefaults.standard.object(forKey: "weeklySum") as! Double
        var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
        let weekSumAppUse = UserDefaults.standard.double(forKey: "weeklySumAppUse")
        var theDictUse = UserDefaults.standard.object(forKey: "trackTotals") as? [String: Double]
        /*If the closest monday to today is different than the closest monday to the last time the app was used, we know that it is a new week*/
        if mon.compare(prevMon as! Date) == .orderedDescending{
            let theKey = "Week of " + dateFormatter.string(from: prevMon as! Date)
            theDict![theKey] = weeklySum
            theDictUse![theKey] = weeklySum/weekSumAppUse
            UserDefaults.standard.set(mon, forKey: "mostRecentMonday")
            UserDefaults.standard.set(theDict, forKey: "trackDates")
            UserDefaults.standard.set(theDictUse, forKey: "trackTotals")
            UserDefaults.standard.set(0, forKey: "weeklySum")
            UserDefaults.standard.set(0, forKey: "weeklySumAppUse")
        }
    }
    @objc func pauseWhenBackground(noti: Notification){
        UserDefaults.standard.set(NSDate(),forKey: "backgroundTrackDate")
    }
    @objc func willEnterForeground(noti: Notification){
        let savedDate = UserDefaults.standard.object(forKey: "backgroundTrackDate")
        let elapsed = Date().timeIntervalSince(savedDate as! Date) //String(elapsed)
        if (counter > 0){
            counter = counter + elapsed
        }
    }
    @objc func UpdateTimer() {
        counter = counter + 0.1
        let msg = secondsToHoursMinutesSeconds(seconds: Int(counter))
        var left = String(msg.0)
        var mid = String(msg.1)
        if msg.0 < 10{
            left = "0" + String(msg.0)
        }
        if msg.1 < 10{
            mid = "0" + String(msg.1)
        }
        let right = Double(counter.truncatingRemainder(dividingBy: 1.00)) + Double(msg.2)
        timeLabel.text = left + ":" + mid + ":" + String(format: "%.1f",right)
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func secondsToHoursMinutesSecondsForDisplay (seconds : Int) -> (String) {
        let msg = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        var left = String(msg.0)
        var mid = String(msg.1)
        var right = String(msg.2)
        if msg.0 < 10{
            left = "0" + String(msg.0)
        }
        if msg.1 < 10{
            mid = "0" + String(msg.1)
        }
        if msg.2 < 10{
            right = "0" + String(msg.2)
        }
        return left + ":" + mid + ":" + right
    }
}
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}
extension Date {
    /*Gives the most recent monday(in date format) to the inputted date*/
    var currentWeekMonday: Date {
        return Calendar.iso8601.date(from: Calendar.iso8601.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}
