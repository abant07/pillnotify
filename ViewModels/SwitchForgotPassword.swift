//
//  SwitchForgotPassword.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/29/23.
//

import SwiftUI
import MessageUI
import Combine
import FirebaseDatabase
import FirebaseAuth

// This struct allows the user to send a forgot password email for another account while they are in their current account
// This will be used for if they are trying to switch accounts but dont know the password for that account.
struct SwitchForgotPassword: View {
    @State private var email = ""
    @State private var successAlert = false
    @State private var passwordResetAlert = false
    
    private var emailFilled: Bool
    {
        [email].contains(where: \.isEmpty)
    }
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        if networkMonitor.isConnected
        {
            ScrollView {
                LazyVStack(spacing: 20) {
                    Text("Forgot Password")
                        .foregroundStyle(.white)
                        .font(.custom("AmericanTypewriter-Bold", size: 40))
                        .shadow(color: .black, radius: 5)
                    
                    
                    TextField("", text: $email)
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .padding(.leading, 20)
                        .placeholder(when: email.isEmpty) {
                            Text("Account Email Address")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.leading, 20)
                                .shadow(color: .black, radius: 5)
                        }
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width - 20, height: 1)
                        .foregroundStyle(.white)
                    
                    Button(action: {
                        passwordResetAlert = false
                        sendPasswordResetEmail(email: email)
                    }, label: {
                        Text("Send Reset Email")
                            .bold()
                            .frame(width: 200, height: 40)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                            }
                            .foregroundStyle(emailFilled ? .red : .green)
                    })
                    .disabled(emailFilled)
                    .alert(isPresented: $successAlert) {
                        if passwordResetAlert == true
                        {
                            return Alert(
                                title: Text("Success!"),
                                message: Text("Forgot password email sent"),
                                dismissButton: .default(Text("OK"),
                                action: {
                                    presentationMode.wrappedValue.dismiss()
                                })
                            )
                        }
                        else
                        {
                            return Alert(
                                title: Text("Error!"),
                                message: Text("Email Not Found"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        else {
            LoadingView()
        }
    }
    
    // sends an email to the account user's email which the user wants to reset for.
    // Firebase sends the email. If the user doesn't give a acurate email already existing, an error is thrown
    func sendPasswordResetEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset email: \(error.localizedDescription)")
                successAlert = true
                
            } else {
                print("Password reset email sent successfully. Check your inbox.")
                passwordResetAlert = true
                successAlert = true
                
            }
        }
    }
}

#Preview {
    SwitchForgotPassword()
}
