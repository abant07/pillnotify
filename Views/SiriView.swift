import SwiftUI
import Intents
import IntentKit
import IntentsUI
import os.log

class SiriShortcutDelegate: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
    weak var presentingViewController: UIViewController?
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error as NSError? {
            print("Error adding voice shortcut: \(error)")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        presentingViewController?.dismiss(animated: true)
        controller.dismiss(animated: true, completion: nil)
    }
    
}

struct SiriView: View {
    private let siriShortcutDelegate = SiriShortcutDelegate()
    var body: some View {
        ScrollView {
            LazyVStack
            {
                Text("Siri Shortcuts")
                    .foregroundStyle(.white)
                    .font(.custom("AmericanTypewriter-Bold", size: 40))
                    .shadow(color: .black, radius: 5)
                
                Button(action: {
                    viewMedsShortcut()
                }) {
                    Text("Set-up View Medications")
                        .bold()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                        }
                        .foregroundStyle(.white)
                        .shadow(color: .white, radius: 5)
                        .padding(.bottom, 20)
                }
                
                Button(action: {
                    confirmMedsShortcut()
                }) {
                    Text("Set-up Confirm Medications")
                        .bold()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                        }
                        .foregroundStyle(.white)
                        .shadow(color: .white, radius: 5)
                        .padding(.bottom, 20)
                }
                
                Button(action: {
                    deleteMedsShortcut()
                }) {
                    Text("Set-up Delete Medications")
                        .bold()
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                        }
                        .foregroundStyle(.white)
                        .shadow(color: .white, radius: 5)
                        .padding(.bottom, 20)
                }
                
                Text("Note: Edit shortcuts in shortcut app")
                    .foregroundStyle(.white)
                    .font(.custom("AmericanTypewriter-Bold", size: 16))
                    .shadow(color: .black, radius: 5)
                    .padding(.bottom, 20)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0/255, green: 47/255, blue: 100/255),
                    Color.white,
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // allows the user to create their own siri shortcut that will allow them to view their meds via Siri
    func viewMedsShortcut() {
        if let shortcut = INShortcut(intent: ViewMyMedsIntent()) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = siriShortcutDelegate
            
            // Get the current active window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Get the window from the window scene
                if let window = windowScene.windows.first {
                    window.rootViewController?.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // allows the user to create their own siri shortcut that will allow them to confirm their meds via Siri
    func confirmMedsShortcut() {
        if let shortcut = INShortcut(intent: ConfirmMedsIntent()) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = siriShortcutDelegate
            
            // Get the current active window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Get the window from the window scene
                if let window = windowScene.windows.first {
                    window.rootViewController?.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // allows the user to create their own siri shortcut that will allow them to delete their meds via Siri
    func deleteMedsShortcut() {
        if let shortcut = INShortcut(intent: DeleteMedsIntent()) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = siriShortcutDelegate
            
            // Get the current active window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Get the window from the window scene
                if let window = windowScene.windows.first {
                    window.rootViewController?.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }


}


