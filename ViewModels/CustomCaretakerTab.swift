//
//  CustomTabView.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 11/29/23.
//

import SwiftUI

enum CaretakerTab: String, CaseIterable {
    case pill
    case folder
    case message
    case gearshape
}

struct CustomTabBar: View {
    @Binding var selectedTab: CaretakerTab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    private var tabColor: Color {
        switch selectedTab {
        case .pill:
            return .blue
        case .folder:
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
                ForEach(CaretakerTab.allCases, id: \.rawValue) { tab in
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
