//
//  AtmosphericSettings.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import SwiftUI
import UIKit

class AtmosphericSettings: ObservableObject {

    @Published private(set) var targetFrame: CGRect = .zero
    @Published private(set) var sourceFrame: CGRect = UIScreen.main.bounds
    @Published private(set) var cornerRadius: CGFloat = 0

    func updateTargetFrame(_ frame: CGRect) {
        guard targetFrame != frame else { return }
        targetFrame = frame
    }

    func updateSourceFrame(_ frame: CGRect) {
        guard sourceFrame != frame else { return }
        sourceFrame = frame
    }

    func updateCornerRadius(_ cornerRadius: CGFloat) {
        guard self.cornerRadius != cornerRadius else { return }
        self.cornerRadius = cornerRadius
    }
}
