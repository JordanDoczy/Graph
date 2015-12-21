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
        
        
        return operations.reverse().joinWithSeparator(",")
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
        func addOp(let op:Op){
            knownOps[op.description] = op
        }
        
        addOp(Op.BinaryOperation(Variables.Multiply, *))
        addOp(Op.BinaryOperation(Variables.Divide, { $1 / $0 }))
        addOp(Op.BinaryOperation(Variables.Add, +))
        addOp(Op.BinaryOperation(Variables.Subtract, { $1 - $0 }))
        addOp(Op.UnaryOperation(Variables.SquareRoot, sqrt))
        addOp(Op.UnaryOperation(Variables.Sin, sin))
        addOp(Op.UnaryOperation(Variables.Cos, cos))
        addOp(Op.OperandSymbol(Variables.Pi, Double(M_PI)))
    }

    func reset(variables variables: Bool = true) {
        opStack.removeAll()
        if variables {
            variableValues.removeValueForKey(Variables.X)
        }
    }
    
    func performOperation(symbol:String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }

    
    func pushOperand(symbol: String) -> Double?{
        if let operand = variableValues[symbol] {
            opStack.append(Op.OperandSymbol(symbol, operand))
        } else {
            opStack.append(Op.OperandSymbol(symbol, nil))
        }
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
   
    private var knownOps = [String:Op]()
    private var opStack = [Op]()

    private enum Op: CustomStringConvertible{
        case Operand(Double)
        case OperandSymbol(String, Double?)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double)
        
        var description:String{
            get{
                switch self{
                    case .Operand(let operand): return "\(operand)"
                    case .OperandSymbol(let symbol, _): return symbol
                    case .UnaryOperation(let symbol, _): return symbol
                    case .BinaryOperation(let symbol, _): return symbol
                }
            }
        }
    }
    
    private func evaluate(ops:[Op]) -> (result:Double?, remainingOps:[Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps)
            case .OperandSymbol(let symbol, let value):
                if value == nil {
                    if let myVal = variableValues[symbol] {
                        return (myVal, remainingOps)
                    }
                }
                return (value, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
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
    
    
    private func getDescription(ops:[Op], previousSymbol:String? = nil) -> (result:String?, remainingOps:[Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .OperandSymbol(let symbol, _):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = getDescription(remainingOps)
                let operand = operandEvaluation.result ==  nil ? "?" : "\(operandEvaluation.result!)"
                return (symbol + "(" + operand + ")", operandEvaluation.remainingOps)
            case .BinaryOperation(let symbol, _):
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