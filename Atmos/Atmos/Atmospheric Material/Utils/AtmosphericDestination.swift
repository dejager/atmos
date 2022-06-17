//
//  AtmosphericDestination.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import SwiftUI

struct AtmosphericDestination: ViewModifier {

    @EnvironmentObject var settings: AtmosphericSettings

    @State var cornerRadius: CGFloat

    private var frameView: some View {
        GeometryReader { geometry in
            settings.updateTargetFrame(geometry.frame(in: .global))
            settings.updateCornerRadius(cornerRadius) 
            return Color.clear
        }
    }

    init(cornerRadius: CGFloat = 0) {
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(frameView)
    }
}

extension View {
    func makeItRainHere(cornerRadius: CGFloat = 0) -> some View {
        modifier(AtmosphericDestination(cornerRadius: cornerRadius))
    }
}
