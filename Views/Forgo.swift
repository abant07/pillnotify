//
//  Forgo.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/26/23.
//

import SwiftUI
import MessageUI
import Combine
import FirebaseDatabase
import FirebaseAuth

struct Forgo: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var emailAlert = false
    
    private var emailFilled: Bool
    {
        [email].contains(where: \.isEmpty)
    }
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationStack
        {
            if networkMonitor.isConnected
            {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0/255, green: 47/255, blue: 100/255),
                            Color.white,
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .foregroundStyle(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255), .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 1000, height: 400)
                        .rotationEffect(.degrees(135))
                        .offset(y: -350)
                    
                    VStack(spacing: 20) {
                        Text("Forgot Password")
                            .foregroundStyle(.white)
                            .font(.custom("SnellRoundhand-Bold", size: 40))
                            .offset(x: -100, y:-100)
                            .shadow(color: .black, radius: 5)
                        
                        
                        TextField("Account Email Address", text: $email)
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .placeholder(when: email.isEmpty) {
                                Text("Account Email Address")
                                    .foregroundStyle(.white)
                                    .bold()
                                    .shadow(color: .black, radius: 5)
                            }
                        
                        Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundStyle(.white)
                        
                        Button(action: {
                            sendPasswordResetEmail(email: email)
                        }, label: {
                            Text("Send Reset Email")
                                .bold()
                                .frame(width: 200, height: 40)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.linearGradient(colors: [Color(red: 0/255, green: 47/255, blue: 100/255)], startPoint: .top, endPoint: .bottomTrailing))
                                }
                                .foregroundStyle(.white)
                        })
                        .disabled(emailFilled)
                        .alert(isPresented: $showAlert) {
                            if emailAlert == true
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
                    .frame(width: 350)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            else {
                LoadingView()
            }
        }
    }
    
    func sendPasswordResetEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset email: \(error.localizedDescription)")
                showAlert = true
                
            } else {
                print("Password reset email sent successfully. Check your inbox.")
                emailAlert = true
                showAlert = true
                
            }
        }
    }
}

#Preview {
    Forgo()
}
