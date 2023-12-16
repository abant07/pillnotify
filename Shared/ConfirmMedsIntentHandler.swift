//
//  ConfirmMedsIntentHandler.swift
//  IntentKit
//
//  Created by Amogh Bantwal on 7/21/23.
//

import Foundation
import os.log
import Intents

public class ConfirmMedsIntentHandler: NSObject, ConfirmMedsIntentHandling {
    
    public func resolveMedicationName(for intent: ConfirmMedsIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if intent.medicationName == "medicationName"
        {
            completion(INStringResolutionResult.needsValue())
        }
        else
        {
            completion(INStringResolutionResult.success(with: intent.medicationName ?? ""))
        }
    }
    
    public func confirm(intent: ConfirmMedsIntent, completion: @escaping (ConfirmMedsIntentResponse) -> Void) {
        completion(ConfirmMedsIntentResponse(code: .ready, userActivity: nil))
    }

    public func handle(intent: ConfirmMedsIntent, completion: @escaping (ConfirmMedsIntentResponse) -> Void) {
        completion(ConfirmMedsIntentResponse(code: .success, userActivity: nil))
    }
}
