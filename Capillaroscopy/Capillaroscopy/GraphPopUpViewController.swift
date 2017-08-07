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
    @IBOutlet weak var densityLabel: UILabel!
    var mainParentViewController: ViewController!
    var unitName: String = ""
    var numberOfCapillaries: Int = 0
    var distanceSelected: Double = 0
    
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
    func setUnitOfGraph (unitName: String, signals: Int, distanceSelected: Double) {
        self.unitName = unitName
        self.numberOfCapillaries = signals
        self.distanceSelected = distanceSelected
    }
    
    func setChart(dataPoints: [Double], values: [Int]) {
        
        lineChartView.noDataText = "No profile has been drawn yet."
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.chartDescription?.enabled = false
        
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: dataPoints[i], y: Double(values[i]))
            dataEntries.append(dataEntry)
            
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "No label")
            var dataSets = [IChartDataSet]()
            dataSets.append(lineChartDataSet)
            lineChartDataSet.circleRadius = 0
            lineChartDataSet.colors = [UIColor.init(red: 0.0, green: 0.0, blue: 1, alpha: 0.5)]
            
            let lineChartData = LineChartData(dataSets: dataSets)
            lineChartData.setDrawValues(false) //no values above line
            
            lineChartView.data = lineChartData
            
            densityLabel.text = "Density = " + String(self.numberOfCapillaries) + " capillaries/" + String(self.distanceSelected) + " " + self.unitName
            
            //github.com/danielgindi/Charts/issues/1502
            //www.appcoda.com/ios-charts-api-tutorial/
            
        }
    }
    
    
}
