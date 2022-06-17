//
//  GaussianBlur.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import Metal
import MetalPerformanceShaders

class GaussianBlur {
    let gaussian: MPSImageGaussianBlur

    required init?(device: MTLDevice?) {
        guard let device = device else { return nil }
        gaussian = MPSImageGaussianBlur(device: device, sigma: 7.0)
    }

    func encode(to commandBuffer: MTLCommandBuffer,
                sourceTexture: MTLTexture,
                destinationTexture: MTLTexture) {
        gaussian.encode(commandBuffer: commandBuffer,
                        sourceTexture: sourceTexture,
                        destinationTexture: destinationTexture)
    }
}
