//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Jordan Doczy on 11/3/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    weak var dataSource:GraphViewDataSource?
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {

            let tapGestureRecognizer = UITapGestureRecognizer(target:graphView, action:Selector(GraphView.GestureRecognizer.ResetOrigin))
            tapGestureRecognizer.numberOfTapsRequired = 2
            
            graphView.dataSource = self
            graphView.addGestureRecognizer(tapGestureRecognizer)
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action:Selector(GraphView.GestureRecognizer.Scale+":")))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action:Selector(GraphView.GestureRecognizer.Pan+":")))
            graphView.contentMode = .redraw
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    func yForX(_ x:CGFloat) -> CGFloat? {
        return dataSource?.yForX(x)
    }
    
    
}
