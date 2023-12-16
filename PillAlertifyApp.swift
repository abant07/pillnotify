//
//  PillAlertifyApp.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 7/15/23.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebaseMessaging
import AWSCore
import FirebaseDatabase
import BackgroundTasks
import OSLog

// Startup class that initializes everything before the app even loads
@main
struct PillAlertifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var path = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            if let login = UserDefaults.standard.object(forKey: "isLoggedIn") as? Bool
            {
                if login
                {
                    if let role = UserDefaults.standard.object(forKey: "role") as? Bool
                    {
                        
                        if role && login
                        {
                            StartCaretakerTab(path: $path)
                        }
                        else
                        {
                            StartSeniorTab(path: $path)
                            
                        }
                    }
                    else
                    {
                        HomeView()
                    }
                }
                else
                {
                    HomeView()
                    
                }
            }
            else
            {
                HomeView()
            }
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    private var accessKey = ""
    private var secretKey = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        UserDefaults.standard.addSuite(named: "group.com.amoghbantwal.PillAlertify")
    
        
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let configData = FileManager.default.contents(atPath: configPath),
            let config = try? PropertyListSerialization.propertyList(from: configData, options: [], format: nil) as? [String: Any] {
            if let sendGridAPIKey = config["AccessKey"] as? String {
                accessKey = sendGridAPIKey
            }
            if let sendGridAPIKey = config["SecretKey"] as? String {
                secretKey = sendGridAPIKey
            }
        }
        
        let credentials = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentials)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.amoghbantwal.PillAlertify.backgroundRefresh", using: nil) { task in
             self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        return true
    }
    
    func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: "com.amoghbantwal.PillAlertify.backgroundRefresh")
       // Fetch no earlier than 15 minutes from now.
       request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new refresh task.
        scheduleAppRefresh()

        // Start refresh of the app data
        let updateTask = Task {
            task.setTaskCompleted(success: true)
        }

        // Provide the background task with an expiration handler that cancels the operation.
        task.expirationHandler = {
            updateTask.cancel()
        }
    }
    
    // Handle registering a APNS token with Firebase
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()
    }

    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .badge, .sound])
    }
    
    // This method creates a new firebase APNS token for a user as they open the app.
    // Only if they delte the app will they be assigned a new one, otherwise it stays constant
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey: "apnsToken")
        
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

