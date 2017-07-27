//
//  GraphPopUpViewController.swift
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 7/7/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

import UIKit

class GraphPopUpViewController: UIViewController {

    @IBOutlet weak var graphPopUpChild: GraphPopUpView!
    var graphPopUpParent: GraphPopUpView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Actions
    @IBAction func closePopUp(_ sender: UIButton) {
        graphPopUpParent.isHidden = true
    }

}
