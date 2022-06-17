//
//  AtmosphericTexture.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import UIKit
import SwiftUI
import Metal
import MetalPerformanceShaders

class AtmosphericTexture: NSObject {

    weak var device: MTLDevice?
    
    private(set) var rawTexture: MTLTexture?
    private(set) var texture: MTLTexture?

    private var needsBlur: Bool = false

    private var blur: GaussianBlur?

    init(device: MTLDevice) {
        self.device = device
        blur = GaussianBlur(device: device)
    }

    func render(view: UIView?, frame: CGRect) {
        guard frame != .zero else { return }
        
        guard let view = view else {
            return assertionFailure("View is missing 🫢.")
        }

        guard let device = device else {
            return assertionFailure("Metal Device is missing 🫢.")
        }

        // Don't use the device scale because we're going to blur the texture anyway.
        let scale = 1.0
        let width = Int(frame.size.width * scale)
        let height = Int(frame.size.height * scale)

        let pixelRowAlignment = device.minimumTextureBufferAlignment(for: .bgra8Unorm)
        let bytesPerRow = width * pixelRowAlignment

        let pagesize = Int(getpagesize())
        var bytes: UnsafeMutableRawPointer? = nil
        let result = posix_memalign(&bytes, pagesize, bytesPerRow * height)
        if result != noErr {
            return assertionFailure("Something bad happened during allocation 💀.")
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).union(.byteOrder32Little)

        guard let context = CGContext(data: bytes,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return assertionFailure("Could not create CGContext 🪦.")
        }

        let snapshotFrame = CGRect(origin: CGPoint(x: -frame.origin.x,
                                                   y: view.layer.bounds.height - frame.maxY),
                                   size: view.layer.bounds.size)
        context.scaleBy(x: scale, y: scale)
        UIGraphicsPushContext(context)
        let flip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: view.layer.bounds.size.height)
        context.concatenate(flip)
        view.drawHierarchy(in: snapshotFrame, afterScreenUpdates: false)
        UIGraphicsPopContext()

        if (rawTexture == nil || rawTexture?.width != width || rawTexture?.height != height) {
            rawTexture = backingTexture(device: device,
                                        width: context.width,
                                        height: context.height)
        }

        if (texture == nil || texture?.width != width || texture?.height != height) {
            texture = displayTexture(texture: rawTexture)
        }

        rawTexture!.replace(region: MTLRegionMake2D(0, 0, width, height),
                            mipmapLevel: 0,
                            withBytes: bytes!,
                            bytesPerRow: bytesPerRow)

        needsBlur = true

        free(bytes)
    }

    func blurredTexture(commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        guard let blur = blur,
              let sourceTexture = rawTexture,
              let destinationTexture = texture else { return nil }
        if needsBlur {
            blur.encode(to: commandBuffer,
                        sourceTexture: sourceTexture,
                        destinationTexture: destinationTexture)
            needsBlur = false
        }
        return destinationTexture
    }

    private func backingTexture(device: MTLDevice, width: Int, height: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor
            .texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                 width: width,
                                 height: height,
                                 mipmapped: true)
        descriptor.usage = .shaderRead
        //        descriptor.usage = .shaderRead.union(.shaderWrite)
        descriptor.storageMode = .shared
        return device.makeTexture(descriptor: descriptor)
    }

    private func displayTexture(texture: MTLTexture?) -> MTLTexture? {
        guard let texture = texture else { return  nil}
        let descriptor = MTLTextureDescriptor
            .texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                 width: texture.width,
                                 height: texture.height,
                                 mipmapped: false)
        descriptor.usage = .shaderRead.union(.shaderWrite)

        return device?.makeTexture(descriptor: descriptor)
    }
}

