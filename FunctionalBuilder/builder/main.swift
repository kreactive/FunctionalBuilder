//
//  main.swift
//  FunctionalBuilder
//
//  Created by Antoine Palazzolo on 21/10/15.
//  Copyright © 2015 Kreactive. All rights reserved.
//

import Foundation


func searchOption(name : String) -> String? {
    for (index,arg) in NSProcessInfo.processInfo().arguments.enumerate() {
        if name == arg && NSProcessInfo.processInfo().arguments.count >= index {
            return NSProcessInfo.processInfo().arguments[index+1]
        }
    }
    return nil
}


let minRange = 3

guard let templateDirectory : NSString = searchOption("-templateDirectory") else {fatalError("missing -templateDirectory option")}
guard let maxCompose = (searchOption("-composeCount").flatMap({Int($0)})) where maxCompose >= minRange else {fatalError("missing or bad -composeCount value (should be int and >= \(minRange))")}
guard let output = searchOption("-targetFile") else {fatalError("missing -targetFile option")}

let numRange = 2...maxCompose

let structTemplate = try! String(contentsOfFile: templateDirectory.stringByAppendingPathComponent("ComposedStructTemplate.txt"))
let ivarTemplate = try! String(contentsOfFile: templateDirectory.stringByAppendingPathComponent("IVarTemplate.txt"))
let composeNextTemplate = try! String(contentsOfFile: templateDirectory.stringByAppendingPathComponent("ComposeNextTemplate.txt"))
let composeResultTemplate = try! String(contentsOfFile: templateDirectory.stringByAppendingPathComponent("ComposeResultTemplate.txt"))
let composeResultCollectTemplate = try! String(contentsOfFile: templateDirectory.stringByAppendingPathComponent("ResultCollectTemplate.txt"))
let operatorFunctionTemplate = try! String(contentsOfFile: templateDirectory.stringByAppendingPathComponent("OperatorFunctionTemplate.txt"))

extension String {
    mutating func replaceTag(tag : String, with : String) {
        while let range = self.rangeOfString("[<\(tag)>]") {
            self.replaceRange(range, with: with)
        }
    }
}


var structs = [String]()
var operatorFuncs = [String]()

for num in numRange {
    var structT = structTemplate
    structT.replaceTag("NUM", with: String(num))
    let types = (1...num).map(String.init).map {"T\($0)"}
    structT.replaceTag("TYPES", with: types.joinWithSeparator(","))
    
    let ivars = types.enumerate().map {(name : "f\($0+1)", type : $1)}
    
    let ivarsBuild = ivars.map { v -> String in
        var ivar = ivarTemplate
        ivar.replaceTag("IVAR_NAME", with: v.name)
        ivar.replaceTag("IVAR_TYPE", with: v.type)
        return ivar
    }
    structT.replaceTag("FUNCTION_VARS", with: ivarsBuild.joinWithSeparator("\n"))
    
    
    if num != numRange.last! {
        let nextNum = num+1
        var composeNext = composeNextTemplate
        composeNext.replaceTag("NEXT_NUM", with: String(nextNum))
        composeNext.replaceTag("TYPES", with:  types.joinWithSeparator(","))
        composeNext.replaceTag("COMPOSE_CURRENT_PARAMS", with:  ivars.map {"\($0.name) : \($0.name)"}.joinWithSeparator(", "))
        structT.replaceTag("COMPOSE_FUNC", with: composeNext)
        
        var operatorFunction = operatorFunctionTemplate
        operatorFunction.replaceTag("TYPES", with: types.joinWithSeparator(","))
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
    structT.replaceTag("COMPOSE_RESULTS", with: composeResult.joinWithSeparator(",\n"))
    
    let resultCollect = composeResult.enumerate().map { (index,_) -> String in
        var resultCollect = composeResultCollectTemplate
        resultCollect.replaceTag("RESULT_INDEX", with: String(index))
        return resultCollect
    }
    structT.replaceTag("RESULT_COLLECT", with: resultCollect.joinWithSeparator(",\n"))
    structT.replaceTag("RESULT_COLLECT_VALUE", with: resultCollect.map{$0+".value"}.joinWithSeparator(",\n"))

    structs.append(structT)
}


let all = structs+operatorFuncs

let outputData = NSData(data: (all.joinWithSeparator("\n\n")).dataUsingEncoding(NSUTF8StringEncoding)!)
outputData.writeToFile(output, atomically: true)


