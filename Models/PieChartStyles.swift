//
//  File.swift
//
//
//  Created by András Samu on 2019. 07. 19..
//

import Foundation
import SwiftUI


public struct Styles {
    public static let pieChartStyleOne = ChartStyle(
        backgroundColor: Color.white,
        accentColor: Color.orange,
        secondGradientColor: Color.orange,
        textColor: Color.black,
        legendTextColor: Color.gray,
        dropShadowColor: Color.gray)
}

public struct ChartForm {
    public static let small = CGSize(width:180, height:120)
    public static let medium = CGSize(width:180, height:240)
    public static let large = CGSize(width:360, height:120)
    public static let detail = CGSize(width:180, height:120)
    
    
}

public class ChartStyle {
    public var backgroundColor: Color
    public var accentColor: Color
    public var gradientColor: Color
    public var textColor: Color
    public var legendTextColor: Color
    public var dropShadowColor: Color
    public weak var darkModeStyle: ChartStyle?
    
    public init(backgroundColor: Color, accentColor: Color, secondGradientColor: Color, textColor: Color, legendTextColor: Color, dropShadowColor: Color){
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.gradientColor = accentColor
        self.textColor = textColor
        self.legendTextColor = legendTextColor
        self.dropShadowColor = dropShadowColor
    }
    
    public init(backgroundColor: Color, accentColor: Color, gradientColor: Color, textColor: Color, legendTextColor: Color, dropShadowColor: Color){
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.gradientColor = gradientColor
        self.textColor = textColor
        self.legendTextColor = legendTextColor
        self.dropShadowColor = dropShadowColor
    }
    
    public init(formSize: CGSize){
        self.backgroundColor = Color.white
        self.accentColor = Color.orange
        self.gradientColor = Color.orange
        self.legendTextColor = Color.gray
        self.textColor = Color.black
        self.dropShadowColor = Color.gray
    }
}


