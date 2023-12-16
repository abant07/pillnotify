//
//  LoadingView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 9/25/23.
//

import SwiftUI

// This is a loading screen circle that shows when the user has no internet connection
struct LoadingView: View {
    var body: some View {
        ProgressView("Check your connection")
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.3)
            .font(.custom("AmericanTypewriter-Bold", size: 17))
            .foregroundStyle(.black)
            .preferredColorScheme(.light)
            
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
