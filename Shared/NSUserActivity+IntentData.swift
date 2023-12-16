//
//  NSUserActivity+IntentData.swift
//  IntentKit
//
//  Created by Amogh Bantwal on 7/14/23.
//

import Foundation
import Intents

extension NSUserActivity {
    
    public static let viewMyMedsActivityType = "com.amoghbantwal.IntentKit.ViewMyMeds"
    
    public static var viewMyMedsActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: NSUserActivity.viewMyMedsActivityType)
        
        userActivity.title = "View My Current Medications"
        userActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(NSUserActivity.viewMyMedsActivityType)
        userActivity.isEligibleForPrediction = true
        userActivity.suggestedInvocationPhrase = "View My Meds"
        
        return userActivity
    }
}
