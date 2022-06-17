//
//  AtmosphericEffect.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import SwiftUI

public struct AtmosphericEffect<Content: View>: View {

    @EnvironmentObject var settings: AtmosphericSettings

    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Representable(targetFrame: settings.targetFrame,
                      sourceFrame: settings.sourceFrame,
                      cornerRadius: settings.cornerRadius,
                      content: ZStack {
            content
        })
            .accessibility(hidden: Content.self == EmptyView.self)
    }
}

// MARK: - Representable

extension AtmosphericEffect {
    struct Representable<Content: View>: UIViewRepresentable {

        var targetFrame: CGRect
        var sourceFrame: CGRect
        var cornerRadius: CGFloat
        var content: Content

        func makeUIView(context: Context) -> UIView {
            context.coordinator.atmosphereView
        }

        func updateUIView(_ view: UIView, context: Context) {
            context.coordinator.update(targetFrame: targetFrame,
                                       sourceFrame: sourceFrame,
                                       cornerRadius: cornerRadius,
                                       content: content)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(targetFrame: targetFrame,
                        sourceFrame: sourceFrame,
                        cornerRadius: cornerRadius,
                        content: content)
        }
    }
}

// MARK: - Coordinator

extension AtmosphericEffect.Representable {
    class Coordinator {

        let hostingController: UIHostingController<Content>
        var atmosphereView: AtmosphereView

        init(targetFrame: CGRect, sourceFrame: CGRect, cornerRadius: CGFloat, content: Content) {

            hostingController = UIHostingController(rootView: content)
            hostingController.view.frame = CGRect(origin: .zero, size: sourceFrame.size)
            hostingController.view.backgroundColor = nil

            atmosphereView = AtmosphereView(targetFrame: targetFrame,
                                            sourceFrame: sourceFrame,
                                            cornerRadius: cornerRadius)
            atmosphereView.contentView?.addSubview(hostingController.view)
        }

        func update(targetFrame: CGRect, sourceFrame: CGRect, cornerRadius: CGFloat, content: Content) {

            guard targetFrame != .zero else { return }

            atmosphereView.targetFrame = targetFrame
            atmosphereView.sourceFrame = sourceFrame
            atmosphereView.cornerRadius = cornerRadius
            hostingController.view.frame = CGRect(origin: .zero, size: sourceFrame.size)
            hostingController.rootView = content
            hostingController.view.setNeedsDisplay()
        }
    }
}
