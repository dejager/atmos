//
//  ShaderUtils.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import MetalKit

struct ShaderExtension<Base> {
    let base: Base

    init(_ base: Base) {
        self.base = base
    }
}

protocol ShaderExtendable {
    associatedtype Extendable

    static var shader: ShaderExtension<Extendable>.Type { get set }
    var shader: ShaderExtension<Extendable> { get set }
}

extension ShaderExtendable {
    static var shader: ShaderExtension<Self>.Type {
        get {
            return ShaderExtension<Self>.self
        }
        set {}
    }

    var shader: ShaderExtension<Self> {
        get {
            return ShaderExtension(self)
        }
        set {}
    }
}

extension NSObject: ShaderExtendable {}

extension ShaderExtension where Base: MTKView {
    func setRenderer(_ renderer: AtmosphericRenderer) {
        base.framebufferOnly = false
        base.drawableSize = base.frame.size
        base.delegate = renderer
    }
}
