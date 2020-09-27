//
//  SecondViewController.swift
//  STOPWATCH
//
//  Created by Avi L on 7/27/20.
//  Copyright © 2020 avi leung. All rights reserved.
//

import UIKit
/*Secondary View Controller to View Stored Data*/
class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //The picker where the user can select the date/week
    @IBOutlet var picker: UIPickerView!
    //Button that allows the user to reset saved data
    @IBOutlet weak var resetButton: UIButton!
    //Displays the time worked in the selected period
    @IBOutlet weak var pickerDisplayTime: UILabel!
    //Displays the ratio for the value worked in selecteed period
    @IBOutlet weak var pickerDisplayRatioWorked: UILabel!
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
        //Initializes the display
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        initPickerDisplay()
    }
    override func viewDidAppear(_ animated: Bool) {
        //Checks if the user does not have any previous data and calls on pop up accordingly
        var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
        let theKeys = theDict?.keys
        let theKeysLength = theKeys?.count
        if (theKeysLength == 0)||(theDict == nil){
            noPreviousDataPopup()
        }
    }
    func initPickerDisplay(){
        /*
         Formats and initializes the values for the pickerDisplay and pickerDisplayRatioWorked, depending on length of the values
         */
        //"trackTotals" --- Dictionary linking date string value to rating of focus within specified interval
        var theRatioDict = UserDefaults.standard.object(forKey: "trackTotals") as? [String: Double]
        //"trackDates"  ---- Dictionary tracking date string value to amount of time worked as double value
        var theTimeDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
        let theKeys = theTimeDict?.keys
        let theKeysLength = theKeys?.count
        if (theKeysLength == 0)||(theTimeDict == nil){
            pickerDisplayTime.text=""
            pickerDisplayRatioWorked.text = ""
        } else if theKeysLength == 1{
            let first = theKeys?.first
            var a = Int((theTimeDict?[first!])!)
            var pickerDisplayStr = secondsToHoursMinutesSecondsForDisplay(seconds: a)
            pickerDisplayTime.text = pickerDisplayStr
            pickerDisplayRatioWorked.text = String(format: "%.1f",theRatioDict?[first!] as! CVarArg)
        } else{
            var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
            let data = Array((theDict?.keys.sorted())!)
            let temp = data[0]
            let temp2 = theDict![temp]
            let msg = secondsToHoursMinutesSecondsForDisplay(seconds: Int(temp2!))
            pickerDisplayTime.text = msg
            pickerDisplayRatioWorked.text = String(format: "%.1f",theRatioDict?[temp] as! CVarArg)
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //Sets the numebr of componenets/columns in picker view
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        /*Sets the number of rows in the picker view */
        if UserDefaults.standard.object(forKey: "trackDates") == nil{
            var emptyDict: [String: Double] = [:]   //["Check Previous Work Info":0]
            UserDefaults.standard.set(emptyDict, forKey: "trackDates")
            return 0
        } else{
            var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
            let data = Array((theDict?.keys)!)
            return data.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
        /*Displays the date/week value*/
        var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
        let data = Array((theDict?.keys.sorted())!)
        let string = data[row]
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.brown])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        /*Function called when a row is selected.
        This function updates the number of hours worked, and the hours worked ratio under their corresponding labels*/
        var checkDic = UserDefaults.standard.object(forKey: "trackDates") as! [String:Double]
        var ar = checkDic.keys.count
        if ar == 0{
            var emptyDict: [String: Double] = [:]// ["Sele":0]
            UserDefaults.standard.set(emptyDict, forKey: "trackDates")
        } else{
            var theDict = UserDefaults.standard.object(forKey: "trackDates") as? [String: Double]
            let data = Array((theDict?.keys.sorted())!)
            let temp = data[row]
            let temp2 = theDict![temp]
            let msg = secondsToHoursMinutesSecondsForDisplay(seconds: Int(temp2!))
            pickerDisplayTime.text = msg
            var theDict3 = UserDefaults.standard.object(forKey: "trackTotals") as? [String: Double]
            var temp4 = theDict3![temp]
            pickerDisplayRatioWorked.text = String(format: "%.1f",temp4 as! CVarArg) //left3 + ":" + mid3 + ":" + right3
        }
    }
    @IBAction func noPreviousDataPopup() {
        //Called when user has no data to view
        let alert = UIAlertController(title: "No Previous Data",
        message: "You have no data. The app will begin displaying your previous work data after the first day.",
        preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok",
                                          style: .default) { (action) in}
        alert.addAction(defaultAction)
        self.present(alert, animated: true) {
              // The alert was presented
           }
    }
    @IBAction func resetValues(_ sender: Any) {
        /*Called when the reset button is clicked*/
        resetPopUp()
    }
    @IBAction func resetPopUp() {
        //Called when user clicks reset button
        let alert = UIAlertController(title: "Confirm",
        message: "Would you like to clear the data from today, or all stored data?",
        preferredStyle: .alert)
        // Create the action buttons for the alert.
        let defaultAction = UIAlertAction(title: "Today's Data",
        style: .default) { (action) in
            if UserDefaults.standard.object(forKey: "weeklySumAppUse") == nil{
                UserDefaults.standard.set(0, forKey: "weeklySumAppUse")
            }
            if UserDefaults.standard.object(forKey: "useKey") == nil{
                UserDefaults.standard.set(0, forKey: "useKey")
            }
            if UserDefaults.standard.object(forKey: "weeklySum") == nil{
                UserDefaults.standard.set(0, forKey: "weeklySum")
            }
            if UserDefaults.standard.object(forKey: "Key") == nil{
                UserDefaults.standard.set(0, forKey: "Key")
            }
            var weekSumUse = UserDefaults.standard.object(forKey: "weeklySumAppUse") as! Double
            var useKey = UserDefaults.standard.object(forKey: "useKey") as! Double
            var weekSum = UserDefaults.standard.object(forKey: "weeklySum") as! Double
            var timeKey = UserDefaults.standard.object(forKey: "Key") as! Double
            weekSumUse = weekSumUse - useKey
            weekSum = weekSum - timeKey
            UserDefaults.standard.set(weekSumUse, forKey: "weeklySumAppUse")
            UserDefaults.standard.set(weekSum, forKey: "weeklySum")
            UserDefaults.standard.set(0, forKey: "Key")
            UserDefaults.standard.set(0, forKey: "useKey")
            self.viewDidLoad()
        }
        let cancelAction = UIAlertAction(title: "All Data",
        style: .cancel) { (action) in
            UserDefaults.standard.removeObject(forKey: "trackDates")
            UserDefaults.standard.removeObject(forKey: "Key")
            UserDefaults.standard.removeObject(forKey: "date")
            UserDefaults.standard.removeObject(forKey: "weeklySum")
            UserDefaults.standard.removeObject(forKey: "mostRecentMonday")
            UserDefaults.standard.removeObject(forKey: "trackTotals")
            UserDefaults.standard.removeObject(forKey: "weeklySumAppUse")
            UserDefaults.standard.removeObject(forKey: "useKey")
            self.viewDidLoad()
        }
        // Create and configure the alert controller.
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true) {
            // The alert was presented
        }
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
