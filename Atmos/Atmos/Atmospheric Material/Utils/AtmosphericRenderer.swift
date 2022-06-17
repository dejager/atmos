//
//  AtmosphericRenderer.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import MetalKit
import MetalPerformanceShaders

final class AtmosphericRenderer: NSObject {
    
    weak var device: MTLDevice?
    var library: MTLLibrary?
    var atmosTexture: AtmosphericTexture?
    
    let commandQueue: MTLCommandQueue?
    private var computePipelineState: MTLComputePipelineState?
    private var startDate: Date = Date()
    
    init(device: MTLDevice, functionName: String) {
        self.device = device
        library = device.makeDefaultLibrary()
        commandQueue = device.makeCommandQueue()

        super.init()

        atmosTexture = AtmosphericTexture(device: device)
        
        guard let library = library else {
            assertionFailure("MetalLibrary is missing 🫢.")
            return
        }
        
        guard let function = library.makeFunction(name: functionName) else {
            assertionFailure("Function named \(functionName) wasn't created 😬.")
            return
        }
        
        do {
            computePipelineState = try device.makeComputePipelineState(function: function)
        } catch {
            assertionFailure("computePipelineState: \(error) wasn't created 😬.")
            return
        }
    }
}

extension AtmosphericRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let computePipelineState = computePipelineState else {
            return
        }
        
        let threadsPerThreadgroup: MTLSize = MTLSize(width: 16, height: 16, depth: 1)
        let scale: CGFloat = UIScreen.main.nativeScale
        
        var threadgroupCount: MTLSize {
            let width = Int(ceilf(Float(view.frame.width * scale) / Float(threadsPerThreadgroup.width)))
            let height = Int(ceilf(Float(view.frame.height * scale) / Float(threadsPerThreadgroup.height)))
            return MTLSize(width: width, height: height, depth: 1)
        }
        
        var time = Float(Date().timeIntervalSince(startDate))
        
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            return assertionFailure("Command buffer wasn't created 😬.")
        }

        let blurredTexture = atmosTexture?.blurredTexture(commandBuffer: commandBuffer)

        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(computePipelineState)
        commandEncoder?.setTexture(drawable.texture, index: 0)
        commandEncoder?.setTexture(blurredTexture, index: 1)
        commandEncoder?.setBytes(&time, length: MemoryLayout<Float>.size * 1, index: 0)
        commandEncoder?.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder?.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
