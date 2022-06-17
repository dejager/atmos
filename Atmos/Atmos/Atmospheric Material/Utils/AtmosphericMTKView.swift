//
//  AtmosphericMTKView.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import MetalKit

class AtmosphericMTKView: MTKView, AtmosphericPresenter {
    var renderer: AtmosphericRenderer!

    required init(frame: CGRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        layer.masksToBounds = true
        drizzle()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderer(forDevice device: MTLDevice, functionName: String) -> AtmosphericRenderer {
        return AtmosphericRenderer(device: device, functionName: functionName)
    }
}
