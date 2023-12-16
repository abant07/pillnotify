//
//  ViewMyMedsIntentHandler.swift
//  IntentKit
//
//  Created by Amogh Bantwal on 7/14/23.
//

import Foundation
import os.log
import Intents

public class ViewMyMedIntentHandler: NSObject, ViewMyMedsIntentHandling {
    
    public func confirm(intent: ViewMyMedsIntent, completion: @escaping (ViewMyMedsIntentResponse) -> Void) {
        completion(ViewMyMedsIntentResponse(code: .ready, userActivity: nil))
    }
    
    public func handle(intent: ViewMyMedsIntent, completion: @escaping (ViewMyMedsIntentResponse) -> Void) {
        let response = ViewMyMedsIntentResponse(code: .success, userActivity: nil)     
        completion(response)
    }
    
    
}
