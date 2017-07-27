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
    var arrayOfIntensityValuesInSwift = NSMutableArray()
    
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
    
    //MARK: Methods
    
        //Give access to parent graph pop up view to child graph pop up view controller so that it can be closed from the child graph pop up view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let graphPopUpViewController = segue.destination as! GraphPopUpViewController
        graphPopUpViewController.graphPopUpParent = graphPopUp
    }
    
    //Dragging graph pop up view method
    func wasDragged(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self.view)
        let popUp = gesture.view!
        popUp.center = CGPoint(x: popUp.center.x + translation.x, y: popUp.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
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
        drawViewCanvas.resetDrawView()
    }

    @IBAction func getCoordinates(_ sender: UIButton) {
        //print(drawViewCanvas.coordinates)
        //print(photoImageView.frame.width, ", ", photoImageView.frame.height)
        
        for Coordinate in drawViewCanvas.coordinates{
            //x and y are the scaled locations on the image view, which will then be multiplied by the size of the actual photo
            let x = (Float(Coordinate.x))/(Float(photoImageView.frame.width))
            arrayXCoordinates.add(x)
            let y = (Float(Coordinate.y))/(Float(photoImageView.frame.height))
            arrayYCoordinates.add(y)
        }
        
        arrayOfIntensityValuesInSwift = OpenCVWrapper.getPixelIntensity(photoImageView.image, withEndpointsX:arrayXCoordinates, withEndpointsY:arrayYCoordinates)
        for i in 0..<arrayOfIntensityValuesInSwift.count {
            print (arrayOfIntensityValuesInSwift[i])
        }
    }

    @IBAction func showGraphPopUp(_ sender: UIButton) {
        graphPopUp.isHidden = false
    }
}

