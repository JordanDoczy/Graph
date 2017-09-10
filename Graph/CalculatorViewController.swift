//
//  ViewController.swift
//  GraphingCalculator
//
//  Created by Jordan Doczy on 11/3/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operationLabel: UILabel!
    
    fileprivate var isUserTyping = false
    fileprivate var model = CalculatorBrain()
    fileprivate var spacer:CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destination = segue.destination
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }
        
        if let controller = destination as? GraphViewController {
            controller.title = model.description.components(separatedBy: ",").last
            controller.dataSource = self
        }
    }
    
    
    // (handles all digits and decimal point)
    @IBAction func appendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if isUserTyping {
            if digit != "." || !display.text!.contains(".") {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            isUserTyping = true
        }
    }
    
    @IBAction func appendVariable(_ sender: UIButton) {
        if let result = model.pushOperand(sender.currentTitle!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    // clears the model, displayValue, and history
    @IBAction func clear(_ sender: UIButton) {
        model.reset()
        displayValue = nil
        isUserTyping = false
        operationLabel.text = ""
    }
    
    // pushes a operation or operand onto the model
    @IBAction func enter() {
        isUserTyping = false
        if displayValue != nil {
            if let result = model.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }
    
    // handles ×,÷,+,−,√,sin,cos,pi
    @IBAction func operate(_ sender: UIButton) {
        if isUserTyping {
            enter()
        }
        
        if let operation = sender.currentTitle {
            displayValue = model.performOperation(operation)
        } else {
            displayValue = nil
        }
    }
    
    // sets a var on the model
    @IBAction func setVarialbe(_ sender: UIButton) {
        model.variableValues[CalculatorBrain.Variables.X] = displayValue
        isUserTyping = false
        displayValue = model.evaluate()
    }
    
    
    var displayValue: Double? {
        get {
            if display.text == nil { return nil }
            if let value = NumberFormatter().number(from: display.text!)?.doubleValue{
                return value
            }
            return nil
        }
        set{
            display.text = newValue == nil ? " " : "\(newValue!)"
            display.sizeToFit()
            operationLabelText = model.description + "="
        }
    }
    
    var operationLabelText: String{
        get {
            return operationLabel.text!
        }
        set{
            operationLabel.text = newValue
            operationLabel.sizeToFit()
        }
    }
    
    func yForX(_ x:CGFloat) -> CGFloat? {
        var value:CGFloat? = nil
        let m = model.variableValues[CalculatorBrain.Variables.X]
        model.variableValues[CalculatorBrain.Variables.X] = Double(x)
        if let eval = model.evaluate(){
            value = CGFloat(eval)
        }
        model.variableValues[CalculatorBrain.Variables.X] = m
        return value
    }
    
    
}

