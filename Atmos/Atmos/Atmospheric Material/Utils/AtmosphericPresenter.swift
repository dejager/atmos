//
//  AtmosphericPresenter.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import MetalKit

protocol AtmosphericPresenter: MTKView {
    var renderer: AtmosphericRenderer! { get set }
    
    // Needs more atmospheric conditions! 👩🏽‍🚀
    func drizzle(device: MTLDevice?)
}

extension AtmosphericPresenter {
    func drizzle(device: MTLDevice? = MTLCreateSystemDefaultDevice()) {
        guard let device = device else { fatalError("Device loading error") }
        renderer = AtmosphericRenderer(device: device, functionName: "rain")
        shader.setRenderer(renderer)
    }
}

