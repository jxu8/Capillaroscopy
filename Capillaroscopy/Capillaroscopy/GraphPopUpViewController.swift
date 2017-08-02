//
//  GraphPopUpViewController.swift
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 7/7/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

import UIKit
import Charts

class GraphPopUpViewController: UIViewController {

    var graphPopUpParent: GraphPopUpView!
    @IBOutlet weak var lineChartView: LineChartView!
    var mainParentViewController: ViewController!
    var unitName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Actions
    @IBAction func closePopUp(_ sender: UIButton) {
        graphPopUpParent.isHidden = true
        mainParentViewController.resetDrawViewWithoutButton()
    }
    
    //MARK: Methods
    func setUnitOfGraph (unitName: String) {
        self.unitName = unitName
    }
    
    func setChart(dataPoints: [Double], values: [Int]) {
        
        lineChartView.noDataText = "No profile has been drawn yet."
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.chartDescription?.text = self.unitName
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: dataPoints[i], y: Double(values[i]))
            dataEntries.append(dataEntry)
        
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: self.unitName)
            var dataSets = [IChartDataSet]()
            dataSets.append(lineChartDataSet)
            lineChartDataSet.circleRadius = 0
            lineChartDataSet.colors = [UIColor.init(red: 0.0, green: 0.0, blue: 1, alpha: 0.5)]
            
            let lineChartData = LineChartData(dataSets: dataSets)
            lineChartData.setDrawValues(false) //no values above line
            
            lineChartView.data = lineChartData
            
//github.com/danielgindi/Charts/issues/1502
            
        }
    }

}
