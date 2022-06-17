//
//  AtmosphericStack.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import UIKit

typealias OnChange = (() ->Void)?

class AtmosphericStack: UIView {

    var onChange: OnChange

    var targetFrame: CGRect {
        didSet {
            frame = AtmosphericStack.boundsFor(frame: targetFrame)
            onChange?()
        }

    }

    init(targetFrame: CGRect, onChange: OnChange) {
        self.onChange = onChange
        self.targetFrame = targetFrame

        super.init(frame: AtmosphericStack.boundsFor(frame: targetFrame))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func boundsFor(frame: CGRect) -> CGRect {
        CGRect(origin: .zero, size: frame.size)
    }
}
