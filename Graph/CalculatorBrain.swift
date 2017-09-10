//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Jordan Doczy on 10/21/15.
//  Copyright (c) 2015 Jordan Doczy. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    var variableValues = [String:Double]()
    
    var description: String {
        
        var operations = [String]()
        var remainingOps = opStack
        while(remainingOps.count > 0){
            let result = getDescription(remainingOps)
            if let operation = result.result {
                operations.append(operation)
            }
            remainingOps = result.remainingOps
        }
        
        
        return operations.reversed().joined(separator: ",")
    }
    
    struct Variables {
        static let X: String = "X"
        static let Pi: String = "π"
        static let Sin: String = "sin"
        static let Cos: String = "cos"
        static let Multiply: String = "×"
        static let Divide: String = "÷"
        static let Add: String = "+"
        static let Subtract: String = "−"
        static let SquareRoot: String = "√"
    }
    
    func evaluate() ->Double? {
        let (result,_) = evaluate(opStack)
        //print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    init(){
        func addOp(_ op:Op){
            knownOps[op.description] = op
        }
        
        addOp(Op.binaryOperation(Variables.Multiply, *))
        addOp(Op.binaryOperation(Variables.Divide, { $1 / $0 }))
        addOp(Op.binaryOperation(Variables.Add, +))
        addOp(Op.binaryOperation(Variables.Subtract, { $1 - $0 }))
        addOp(Op.unaryOperation(Variables.SquareRoot, sqrt))
        addOp(Op.unaryOperation(Variables.Sin, sin))
        addOp(Op.unaryOperation(Variables.Cos, cos))
        addOp(Op.operandSymbol(Variables.Pi, .pi))
    }

    func reset(variables: Bool = true) {
        opStack.removeAll()
        if variables {
            variableValues.removeValue(forKey: Variables.X)
        }
    }
    
    func performOperation(_ symbol:String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }

    
    func pushOperand(_ symbol: String) -> Double?{
        if let operand = variableValues[symbol] {
            opStack.append(Op.operandSymbol(symbol, operand))
        } else {
            opStack.append(Op.operandSymbol(symbol, nil))
        }
        return evaluate()
    }
    
    func pushOperand(_ operand: Double) -> Double?{
        opStack.append(Op.operand(operand))
        return evaluate()
    }
    
   
    fileprivate var knownOps = [String:Op]()
    fileprivate var opStack = [Op]()

    fileprivate enum Op: CustomStringConvertible{
        case operand(Double)
        case operandSymbol(String, Double?)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation(String, (Double,Double) -> Double)
        
        var description:String{
            get{
                switch self{
                    case .operand(let operand): return "\(operand)"
                    case .operandSymbol(let symbol, _): return symbol
                    case .unaryOperation(let symbol, _): return symbol
                    case .binaryOperation(let symbol, _): return symbol
                }
            }
        }
    }
    
    fileprivate func evaluate(_ ops:[Op]) -> (result:Double?, remainingOps:[Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .operand(let operand):
                return (operand, remainingOps)
            case .operandSymbol(let symbol, let value):
                if value == nil {
                    if let myVal = variableValues[symbol] {
                        return (myVal, remainingOps)
                    }
                }
                return (value, remainingOps)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    
    fileprivate func getDescription(_ ops:[Op], previousSymbol:String? = nil) -> (result:String?, remainingOps:[Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .operand(let operand):
                return ("\(operand)", remainingOps)
            case .operandSymbol(let symbol, _):
                return (symbol, remainingOps)
            case .unaryOperation(let symbol, _):
                let operandEvaluation = getDescription(remainingOps)
                let operand = operandEvaluation.result ==  nil ? "?" : "\(operandEvaluation.result!)"
                return (symbol + "(" + operand + ")", operandEvaluation.remainingOps)
            case .binaryOperation(let symbol, _):
                let op1Evaluation = getDescription(remainingOps, previousSymbol: symbol)
                let operand1 = op1Evaluation.result ==  nil ? "?" : "\(op1Evaluation.result!)"
                let op2Evaluation = getDescription(op1Evaluation.remainingOps)
                let operand2 = op2Evaluation.result ==  nil ? "?" : "\(op2Evaluation.result!)"
                var operation = operand2 + symbol + operand1
                if previousSymbol != nil {
                    if previousSymbol != symbol || previousSymbol == Variables.Divide {
                        operation = "(" + operation + ")"
                    }
                }
                
                return (operation, op2Evaluation.remainingOps)
            }
        }
        return (nil, ops)
    }
    
    
}
