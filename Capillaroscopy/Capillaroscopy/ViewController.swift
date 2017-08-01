//
//  ViewController.swift
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 6/22/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var drawViewCanvas: DrawView!
    @IBOutlet weak var graphPopUp: GraphPopUpView!
    let arrayXCoordinates = NSMutableArray()
    let arrayYCoordinates = NSMutableArray()
    var arrayOfIntensityValuesInSwiftAsNSMutableArray = NSMutableArray()
    var arrayOfIntensityValuesInSwiftAsIntegerArray :[Int] = []
    var graphPopUpViewController = GraphPopUpViewController ()
    var arrayOfDistanceForXAxis: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphPopUp.isHidden = true
        
        //Dragging the graph pop up view
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.wasDragged(_:)))
        graphPopUp.addGestureRecognizer(gesture)
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
        
    }

    @IBAction func getCoordinates(_ sender: UIButton) {
        //print(drawViewCanvas.coordinates)
        //print(photoImageView.frame.width, ", ", photoImageView.frame.height)
        
        //will only show coordinates if array for linechart is empty so data is not duplicated
        if arrayOfIntensityValuesInSwiftAsIntegerArray.isEmpty{
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

            //create an array that can be used for x axis and x axis starts at 0
            for i in 0 ..< arrayOfIntensityValuesInSwiftAsIntegerArray.count{
                arrayOfDistanceForXAxis.append(i)
            }
            
            //pass data to graph pop up view controller (child container view controller) and tell it to draw the chart
            self.graphPopUpViewController.setChart(dataPoints: arrayOfDistanceForXAxis, values: arrayOfIntensityValuesInSwiftAsIntegerArray)
            
            //show graph pop up
            graphPopUp.isHidden = false
        }
    }
}

