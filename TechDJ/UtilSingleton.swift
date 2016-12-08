//
//  UtilSingleton.swift
//  TechDJ
//
//  Created by Emanuel Azage on 12/2/16.
//  Copyright © 2016 Emanuel Azage. All rights reserved.
//

import Foundation


/*
 This is for useful functinons that can be called by any part of the program such as debug statements 
 Also for global constants
 */
class UtilSingleton : NSObject {
    
    static let kDefaultListKey = "defaultsonglist"
    
    
    private override init(){}
    
    // general useful functions such as debug statements
    
    static func printDebug(_ statemtent : String){
        // specific formatting
    }
}
