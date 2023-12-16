//
//  BottomTextView.swift
//  Medimory
//
//  Created by Amogh Bantwal on 12/31/22.
//

import SwiftUI

// This view shows a oval button on the home screen
struct BottomTextView: View {
    let str: String
    var body: some View {
        HStack
        {
            Spacer()
            Text(str)
                .foregroundColor(.white)
                .font(.title)
                .bold()
                .padding()
            Spacer()
        }.background(Color(red: 0/255, green: 47/255, blue: 100/255))
    }
}

struct BottomTextView_Previews: PreviewProvider {
    static var previews: some View {
        BottomTextView(str: "Okay")
    }
}
