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
    @IBOutlet weak var pictureNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let openCVWrapper = OpenCVWrapper()
        openCVWrapper.exampleOpenCVFunction()
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

}

