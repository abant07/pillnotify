//
//  CustomTabView2.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/29/23.
//

import SwiftUI

enum SeniorTab: String, CaseIterable {
    case pill
    case waveform
    case message
    case gearshape
}

struct CustomTabView2: View {
    @Binding var selectedTab: SeniorTab
    private var fillImage: String {
        if selectedTab.rawValue == "waveform"
        {
            return selectedTab.rawValue
        }
        return selectedTab.rawValue + ".fill"
    }
    private var tabColor: Color {
        switch selectedTab {
        case .pill:
            return .blue
        case .waveform:
            return .indigo
        case .message:
            return .green
        case .gearshape:
            return .orange
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                ForEach(SeniorTab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                        .foregroundColor(tab == selectedTab ? tabColor : .gray)
                        .font(.system(size: 20))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .background(.thinMaterial)
            .cornerRadius(20)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
    }
}

