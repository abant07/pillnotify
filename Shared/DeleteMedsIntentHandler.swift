//
//  DeleteMedsIntentHandler.swift
//  IntentKit
//
//  Created by Amogh Bantwal on 7/21/23.
//

import Foundation
import Intents

public class DeleteMedsIntentHandler: NSObject, DeleteMedsIntentHandling {

    public func resolveMedicationName(for intent: DeleteMedsIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if intent.medicationName == "medicineName"
        {
            completion(INStringResolutionResult.needsValue())
        }
        else
        {
            completion(INStringResolutionResult.success(with: intent.medicationName ?? ""))
        }
    }
    
    public func confirm(intent: DeleteMedsIntent, completion: @escaping (DeleteMedsIntentResponse) -> Void) {
        completion(DeleteMedsIntentResponse(code: .ready, userActivity: nil))
    }

    public func handle(intent: DeleteMedsIntent, completion: @escaping (DeleteMedsIntentResponse) -> Void) {
        completion(DeleteMedsIntentResponse(code: .success, userActivity: nil))
    }
    
    
}

