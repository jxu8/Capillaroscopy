//
//  CalibrateViewController.swift
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 8/7/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

import UIKit

protocol calibrationProtocol {
    func setLengthTextField(valueSent: Double)
    func setUnitTextField (valueSent: String)
    func setZeroesCounter (valueSent: Int)
    func setThreshold (valueSent: Double)
}

//need to figure out why class variables are reset to false each time calibrate screen is accesssed
//find a way to not have global variables
var wasLengthChanged: Bool = false
var wasUnitChanged: Bool = false
var wasZeroSliderChanged: Bool = false
var wasThresholdSliderChanged: Bool = false

class CalibrateViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var setLengthTextField: UITextField!
    @IBOutlet weak var setUnitTextField: UITextField!
    @IBOutlet weak var calibrateZeroesCounterSlider: UISlider!
    @IBOutlet weak var calibrateThresholdSlider: UISlider!
    
    //labels
    @IBOutlet weak var setLengthTextFieldLabel: UILabel!
    @IBOutlet weak var setUnitTextFieldLabel: UILabel!
    @IBOutlet weak var setCalibrateZeroesCounterSliderLabel: UILabel!
    @IBOutlet weak var setCalibrateThresholdSliderLabel: UILabel!
    var setLengthTextFieldInitialLabel: String = "Set the length of the image. The length is: "
    var setUnitTextFieldInitialLabel: String = "Set the units. The unit is: "
    var setCalibrateZeroesCounterInitialLabel:String = "Adjust slider based on distance between capillaries. Leftmost indicates close distance. You have chosen: "
    var setCalibrateThresholdSliderInitialLabel: String = "Adjust slider based on contrast in the image. Leftmost indicates low contrast. You have chosen: "
    
    //add calibration properties to this view controller so that inputs are saved
    var length: Double = 0
    var unit: String = ""
    var zeroesCounter: Int = 20
    var threshold: Double = 3
    
    //check if values were entered before (so default values when first loaded, but no longer afterwards)
    
    var calibrationDelegate: calibrationProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Handle the length and unit that the user inputs
        setLengthTextField.delegate = self
        setUnitTextField.delegate = self
        setLengthTextField.tag = 1
        setUnitTextField.tag = 2
        
        //set initial labels
        if !setLengthTextField.hasText {
            setLengthTextFieldLabel.text = setLengthTextFieldInitialLabel
        }
        if !setUnitTextField.hasText {
            setUnitTextFieldLabel.text = setUnitTextFieldInitialLabel
        }
        if calibrateZeroesCounterSlider.value == 20 {
            setCalibrateZeroesCounterSliderLabel.text = setCalibrateZeroesCounterInitialLabel + String (20)
        }
        if calibrateThresholdSlider.value == 3 {
            setCalibrateThresholdSliderLabel.text = setCalibrateThresholdSliderInitialLabel + String (3)
        }
    }

    //data is saved in this view controller, but storyboard updates the view each time this viewcontroller shows up
    override func viewWillAppear(_ animated: Bool) {
        if wasLengthChanged{
            setLengthTextFieldLabel.text = setLengthTextFieldInitialLabel + String(length)
        }
        if wasUnitChanged {
            setUnitTextFieldLabel.text = setUnitTextFieldInitialLabel + unit
        }
        if wasZeroSliderChanged{
            setCalibrateZeroesCounterSliderLabel.text = setCalibrateZeroesCounterInitialLabel + String(zeroesCounter)
            calibrateZeroesCounterSlider.value = Float(zeroesCounter)
        }
        if wasThresholdSliderChanged {
            setCalibrateThresholdSliderLabel.text = setCalibrateThresholdSliderInitialLabel + String (threshold)
            calibrateThresholdSlider.value = Float (threshold)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == 1 && textField.text != nil){
            calibrationDelegate?.setLengthTextField(valueSent: Double(textField.text!)!)
            length = Double(textField.text!)!
            setLengthTextFieldLabel.text = setLengthTextFieldInitialLabel + String(length)
            wasLengthChanged = true
        }
        
        if (textField.tag == 2 && textField.text != nil){
            calibrationDelegate?.setUnitTextField(valueSent: textField.text!)
            unit = textField.text!
            setUnitTextFieldLabel.text = setUnitTextFieldInitialLabel + unit
            wasUnitChanged = true
        }
        
    }

    @IBAction func sliderValuechanged(_ sender: UISlider) {
        calibrationDelegate?.setZeroesCounter(valueSent: Int(sender.value))
        zeroesCounter = Int(sender.value)
        setCalibrateZeroesCounterSliderLabel.text = setCalibrateZeroesCounterInitialLabel + String(zeroesCounter)
        wasZeroSliderChanged = true
    }
    
    @IBAction func thresholdSliderValueChanged(_ sender: UISlider) {
        calibrationDelegate?.setThreshold(valueSent: Double(sender.value))
        setCalibrateThresholdSliderLabel.text = setCalibrateThresholdSliderInitialLabel + String(sender.value)
        wasThresholdSliderChanged = true
    }
    
}
