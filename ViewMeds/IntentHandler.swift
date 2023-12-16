//
//  IntentHandler.swift
//  ViewMeds
//
//  Created by Amogh Bantwal on 7/15/23.
//

import Intents
import IntentKit
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is ViewMyMedsIntent {
            return ViewMyMedIntentHandler()
        }
        if intent is ConfirmMedsIntent {
            return ConfirmMedsIntentHandler()
        }
        if intent is DeleteMedsIntent {
            return DeleteMedsIntentHandler()
        }

            fatalError("Unhandled intent type: \(intent)")
        }
}
