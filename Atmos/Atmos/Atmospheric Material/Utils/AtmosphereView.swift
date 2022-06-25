//
//  AtmosphereView.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import UIKit
import Metal
import MetalKit

class AtmosphereView: UIView {

    var contentView: AtmosphericStack?

    private var atmosView: AtmosphericMTKView
    private var hasAPoopInTheShoot: Bool = false

    var cornerRadius: CGFloat {
        didSet {
            self.atmosView.layer.cornerRadius = cornerRadius
        }
    }

    var targetFrame: CGRect {
        didSet {
            atmosView.frame = targetFrame
            contentView?.targetFrame = targetFrame
        }
    }

    var sourceFrame: CGRect {
        didSet {
            let localBounds = AtmosphereView.boundsFor(frame: sourceFrame)
            frame = localBounds
            contentView?.frame = localBounds
        }
    }

    private static func boundsFor(frame: CGRect) -> CGRect {
        CGRect(origin: .zero, size: frame.size)
    }

    init(targetFrame: CGRect, sourceFrame: CGRect, cornerRadius: CGFloat) {
        self.targetFrame = targetFrame
        self.sourceFrame = sourceFrame
        self.cornerRadius = cornerRadius

        let localBounds = AtmosphereView.boundsFor(frame: sourceFrame)

        self.atmosView = AtmosphericMTKView(frame: targetFrame)
        self.atmosView.layer.cornerRadius = cornerRadius
        super.init(frame: localBounds)

        contentView = AtmosphericStack(targetFrame: targetFrame) { [weak self] in
            self?.setNeedsRendering()
        }

        addSubview(contentView!)
        addSubview(atmosView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setNeedsRendering() {
        if !hasAPoopInTheShoot {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.atmosView.renderer.atmosTexture?.render(view: self.contentView,
                                                             frame: self.targetFrame)
                self.atmosView.setNeedsDisplay(self.targetFrame)
                self.hasAPoopInTheShoot = false
            }
            hasAPoopInTheShoot = true
        }
    }
}

