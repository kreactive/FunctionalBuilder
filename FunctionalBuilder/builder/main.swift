//
//  main.swift
//  FunctionalBuilder
//
//  Created by Antoine Palazzolo on 21/10/15.
//
//

import Foundation


func searchOption(_ name : String) -> String? {
    for (index,arg) in ProcessInfo.processInfo.arguments.enumerated() {
        if name == arg && ProcessInfo.processInfo.arguments.count >= index {
            return ProcessInfo.processInfo.arguments[index+1]
        }
    }
    return nil
}


let minRange = 3

guard let templateDirectory : NSString = (searchOption("-templateDirectory") as NSString?) else {fatalError("missing -templateDirectory option")}
guard let maxCompose = (searchOption("-composeCount").flatMap({Int($0)})), maxCompose >= minRange else {fatalError("missing or bad -composeCount value (should be int and >= \(minRange))")}
guard let output = searchOption("-targetFile") else {fatalError("missing -targetFile option")}

let numRange = 2...maxCompose

let structTemplate = try! String(contentsOfFile: templateDirectory.appendingPathComponent("ComposedStructTemplate.txt"))
let ivarTemplate = try! String(contentsOfFile: templateDirectory.appendingPathComponent("IVarTemplate.txt"))
let composeNextTemplate = try! String(contentsOfFile: templateDirectory.appendingPathComponent("ComposeAndNextTemplate.txt"))
let composeResultTemplate = try! String(contentsOfFile: templateDirectory.appendingPathComponent("ComposeResultTemplate.txt"))
let composeResultCollectTemplate = try! String(contentsOfFile: templateDirectory.appendingPathComponent("ResultCollectTemplate.txt"))
let operatorFunctionTemplate = try! String(contentsOfFile: templateDirectory.appendingPathComponent("OperatorFunctionTemplate.txt"))

extension String {
    mutating func replaceTag(_ tag : String, with : String) {
        while let range = self.range(of : "[<\(tag)>]") {
            self.replaceSubrange(range, with: with)
        }
    }
}


var structs = [String]()
var operatorFuncs = [String]()

for num in numRange {
    var structT = structTemplate
    structT.replaceTag("NUM", with: String(num))
    let types = (1...num).map(String.init).map {"T\($0)"}
    structT.replaceTag("TYPES", with: types.joined(separator: ","))
    
    let ivars = types.enumerated().map {(name : "f\($0+1)", type : $1)}
    
    let ivarsBuild = ivars.map { v -> String in
        var ivar = ivarTemplate
        ivar.replaceTag("IVAR_NAME", with: v.name)
        ivar.replaceTag("IVAR_TYPE", with: v.type)
        return ivar
    }
    structT.replaceTag("FUNCTION_VARS", with: ivarsBuild.joined(separator:"\n"))
    
    
    if num != numRange.last! {
        let nextNum = num+1
        var composeNext = composeNextTemplate
        composeNext.replaceTag("NEXT_NUM", with: String(nextNum))
        composeNext.replaceTag("TYPES", with:  types.joined(separator:","))
        composeNext.replaceTag("COMPOSE_CURRENT_PARAMS", with:  ivars.map {"\($0.name) : \($0.name)"}.joined(separator:", "))
        structT.replaceTag("COMPOSE_FUNC", with: composeNext)
        
        var operatorFunction = operatorFunctionTemplate
        operatorFunction.replaceTag("TYPES", with: types.joined(separator: ","))
        operatorFunction.replaceTag("NUM", with: String(num))
        operatorFunction.replaceTag("NEXT_NUM", with: String(nextNum))
        operatorFuncs.append(operatorFunction)
        
    } else {
        structT.replaceTag("COMPOSE_FUNC", with: "")
    }
    
    let composeResult = ivars.map { v -> String in
        var composeResult = composeResultTemplate
        composeResult.replaceTag("IVAR_NAME", with: v.name)
        return composeResult
    }
    structT.replaceTag("COMPOSE_RESULTS", with: composeResult.joined(separator: ",\n"))
    
    let resultCollect = composeResult.enumerated().map { (index,_) -> String in
        var resultCollect = composeResultCollectTemplate
        resultCollect.replaceTag("RESULT_INDEX", with: String(index))
        return resultCollect
    }
    structT.replaceTag("RESULT_COLLECT", with: resultCollect.joined(separator: ",\n"))
    structT.replaceTag("RESULT_COLLECT_VALUE", with: resultCollect.map{$0+".value"}.joined(separator: ",\n"))

    structs.append(structT)
}


let all = structs+operatorFuncs

let outputData = NSData(data: (all.joined(separator: "\n\n")).data(using: String.Encoding.utf8)!)
outputData.write(toFile: output, atomically: true)


