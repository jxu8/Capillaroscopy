//
//  ViewController.swift
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 6/22/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var drawViewCanvas: DrawView!
    @IBOutlet weak var graphPopUp: GraphPopUpView!
    @IBOutlet weak var setLengthTextField: UITextField!
    @IBOutlet weak var setUnitTextField: UITextField!
    @IBOutlet weak var calibrateSlider: UISlider!
    
    let arrayXCoordinates = NSMutableArray()
    let arrayYCoordinates = NSMutableArray()
    var arrayOfIntensityValuesInSwiftAsNSMutableArray = NSMutableArray()
    var arrayOfIntensityValuesInSwiftAsIntegerArray :[Int] = []
    var arrayOfIntensityValuesInSwiftAsDoubleArray: [Double] = []
    var signalsViewController: [Int] = []
    var graphPopUpViewController = GraphPopUpViewController ()
    var arrayOfDistanceForXAxis: [Double] = []
    var lengthOfImage: Double? = nil
    var unitOfGraph: String? = ""
    var calibrateZeroesCounter: Int = 20
    var curveAlgorithm = CurveAlgorithm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphPopUp.isHidden = true
        
        //Dragging the graph pop up view
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.wasDragged(_:)))
        graphPopUp.addGestureRecognizer(gesture)
        
        //Handle the length and unit that the user inputs
        setLengthTextField.delegate = self
        setUnitTextField.delegate = self
        setLengthTextField.tag = 1
        setUnitTextField.tag = 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        //Dismiss the picker if the user canceled.
        dismiss (animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        //The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage else{
                fatalError("Expected a dictionary containing an image, but was provided the follow: \(info)")
        }
        
        //Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == 1){
            lengthOfImage = Double(textField.text!)
        }
        
        if (textField.tag == 2){
            unitOfGraph = textField.text!
        }
        
    }
    
    //MARK: Methods - this triggers before actions
    
    //Allow child viewcontroller (graph pop up viewcontroller) and parent viewcontroller to interact
    //spin.atomicobject.com/2016/03/30/ios-container-view-pass-data/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let graphPopUpViewController = segue.destination as! GraphPopUpViewController
        
        //give access to parent viewcontroller to child viewcontroller
        graphPopUpViewController.graphPopUpParent = graphPopUp
        graphPopUpViewController.mainParentViewController = self
        
        //give access to child viewcontroller to parent viewcontroller
        self.graphPopUpViewController = graphPopUpViewController
    }
    
    //Dragging graph pop up view method
    func wasDragged(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self.view)
        let popUp = gesture.view!
        popUp.center = CGPoint(x: popUp.center.x + translation.x, y: popUp.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }
    
    //same as resetDrawView but without connection to @IBAction
    func resetDrawViewWithoutButton(){
        //resets lines
        drawViewCanvas.resetDrawView()
        
        //resets data - these arrays of coordinates are where the data begins and passed to opencv, so emptying these will make sure opencv starts anew as well
        arrayXCoordinates.removeAllObjects()
        arrayYCoordinates.removeAllObjects()
        
        //empties arrays passed to line chart
        arrayOfDistanceForXAxis.removeAll()
        arrayOfIntensityValuesInSwiftAsIntegerArray.removeAll()
        
        arrayOfIntensityValuesInSwiftAsDoubleArray.removeAll()
        curveAlgorithm.signalsClassLevel.removeAll()
        
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UIButton) {
        
        //UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        //Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        //Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func resetDrawView(_ sender: UIButton) {
        //resets lines
        drawViewCanvas.resetDrawView()
        
        //resets data - these arrays of coordinates are where the data begins and passed to opencv, so emptying these will make sure opencv starts anew as well
        arrayXCoordinates.removeAllObjects()
        arrayYCoordinates.removeAllObjects()
        
        //empties arrays passed to line chart
        arrayOfDistanceForXAxis.removeAll()
        arrayOfIntensityValuesInSwiftAsIntegerArray.removeAll()
        
        arrayOfIntensityValuesInSwiftAsDoubleArray.removeAll()
        curveAlgorithm.signalsClassLevel.removeAll()
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        calibrateZeroesCounter = Int(sender.value)
    }
    
    @IBAction func getCoordinates(_ sender: UIButton) {
        //print(drawViewCanvas.coordinates)
        //print(photoImageView.frame.width, ", ", photoImageView.frame.height)
        
        //will only show coordinates if array for linechart is empty so data is not duplicated and if user inputted length of image for x axis scale
        if arrayOfIntensityValuesInSwiftAsIntegerArray.isEmpty && lengthOfImage != nil {
            for Coordinate in drawViewCanvas.coordinates{
                //x and y are the scaled locations on the image view, which will then be multiplied by the size of the actual photo
                let x = (Float(Coordinate.x))/(Float(photoImageView.frame.width))
                arrayXCoordinates.add(x)
                let y = (Float(Coordinate.y))/(Float(photoImageView.frame.height))
                arrayYCoordinates.add(y)
            }
            
            //call opencv function
            arrayOfIntensityValuesInSwiftAsNSMutableArray = OpenCVWrapper.getPixelIntensity(photoImageView.image, withEndpointsX:arrayXCoordinates, withEndpointsY:arrayYCoordinates)
            
            //convert NSNumber in NSMutableArray to Swift Integer Array
            for i in 0 ..< arrayOfIntensityValuesInSwiftAsNSMutableArray.count{
                arrayOfIntensityValuesInSwiftAsIntegerArray.append((arrayOfIntensityValuesInSwiftAsNSMutableArray[i] as AnyObject).integerValue)
            }
            //stackoverflow.com/questions/34012122/how-to-convert-swift-optional-nsnumber-to-optional-int-any-improvements-on-my
            
            //make black the peak, so capillaries the maximums instead of the minimums, i.e. 3 = 252
            for i in 0 ..< arrayOfIntensityValuesInSwiftAsIntegerArray.count{
                arrayOfIntensityValuesInSwiftAsIntegerArray[i] = (255 - arrayOfIntensityValuesInSwiftAsIntegerArray[i])
            }
            
            if !arrayOfIntensityValuesInSwiftAsIntegerArray.isEmpty{ //if press plot after reset without new selection
                //create an array that can be used as scale for x axis and x axis starts at 0
                let lengthOfEachPixel: Double = (lengthOfImage!)/(Double((photoImageView.image?.size.height)!))
                var sumOfPixelsAlongLine: Double = 0.0
                arrayOfDistanceForXAxis.append(sumOfPixelsAlongLine)
                for _ in 1 ..< arrayOfIntensityValuesInSwiftAsIntegerArray.count{ //start at 1 because first value of zero was already added
                    sumOfPixelsAlongLine += lengthOfEachPixel
                    arrayOfDistanceForXAxis.append(sumOfPixelsAlongLine)
                }
                
                //convert integer array into double array for curve algorithm
                for i in 0 ..< arrayOfIntensityValuesInSwiftAsIntegerArray.count {
                    arrayOfIntensityValuesInSwiftAsDoubleArray.append(Double(arrayOfIntensityValuesInSwiftAsIntegerArray[i]))
                }
                
                //only run threshold if enough pixels are selected because of how the lag parameter
                //in the algorithm is used (array can be too big)
                if arrayOfIntensityValuesInSwiftAsIntegerArray.count > 10 {
                    // Run thresold
                    curveAlgorithm.ThresholdingAlgo(y: arrayOfIntensityValuesInSwiftAsDoubleArray, lag: 10, threshold: 3, influence: 0.9)
                    signalsViewController = curveAlgorithm.signalsClassLevel
                }
                
                //algorithm to count signals
                var signalsCounter: Int = 0
                var zeroesCounter: Int = 0
                for i in 0..<signalsViewController.count{
                    if signalsViewController[i] == 1 {
                        
                        if zeroesCounter > calibrateZeroesCounter || signalsCounter == 0 { //after first signal, only count if there are enough zeroes in between signals to prevent false positives
                            signalsCounter +=  1
                            zeroesCounter = 0 //reset zero counter for next signal search
                        }
                        
                        if signalsViewController[i+1] == 0 {
                            zeroesCounter += 1 //begin zero counter to search for next signal
                        }
                        
                    }
                    else{
                        if signalsCounter >= 1 { //only count zeroes after the first signal is detected
                            zeroesCounter += 1
                        }
                    }
                }
                
                //set unit of graph
                self.graphPopUpViewController.setUnitOfGraph(unitName: unitOfGraph!, signals: signalsCounter, distanceSelected: arrayOfDistanceForXAxis[arrayOfIntensityValuesInSwiftAsIntegerArray.count - 1])
                
                //reset signal counter
                signalsCounter = 0
                zeroesCounter = 0
                
                //pass data to graph pop up view controller (child container view controller) and tell it to draw the chart
                self.graphPopUpViewController.setChart(dataPoints: arrayOfDistanceForXAxis, values: arrayOfIntensityValuesInSwiftAsIntegerArray)
                
                //show graph pop up
                graphPopUp.isHidden = false
            }
        }
        
        //Black = 0; white = 255
    }
    
}
