//
//  ImageProvider.swift
//  Digit-Recognizer-via-Metal
//
//  Created by Andrey Morozov on 13.03.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import AVFoundation
import UIKit


/// Manage image preparing for CNN input.
class ImageProvider {
    private var rawData: [UInt8]
    private var imageWidth: Int
    private var imageHeight: Int
    private var cropSize: CGSize
    
    private let bitsPerComponent = 8
    private let bytesPerPixel = 1
    private let colorSpace = CGColorSpaceCreateDeviceGray()
    private let bitmapInfoRaw = CGImageAlphaInfo.none.rawValue
    
    init(rawData: [UInt8], imageWidth: Int, imageHeight: Int, cropSize: CGSize) {
        self.rawData = rawData
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.cropSize = cropSize
    }
    
    func createImage() -> CGImage? {
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * imageWidth
        let imageBytes = bytesPerRow * imageHeight
        
        
        let cgImage = rawData.withUnsafeBytes { data -> CGImage? in
            var imageRef: CGImage?
            let bitmapInfo = CGBitmapInfo(rawValue: bitmapInfoRaw).union(CGBitmapInfo())
            let releaseData: CGDataProviderReleaseDataCallback = {
                (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            }
            
            if let providerRef = CGDataProvider(dataInfo: nil, data: data.baseAddress!, size: imageBytes, releaseData: releaseData) {
                imageRef = CGImage(width: imageWidth,
                                   height: imageHeight,
                                   bitsPerComponent: bitsPerComponent,
                                   bitsPerPixel: bitsPerPixel,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpace,
                                   bitmapInfo: bitmapInfo,
                                   provider: providerRef,
                                   decode: nil,
                                   shouldInterpolate: false,
                                   intent: .defaultIntent)
            }
            
            return imageRef
        }
        
        return cgImage
    }
    
    func imageForCNN(from image: CGImage) -> CGImage? {
        let bytesPerRow = 28
        let cnnImageSize: (width: Int, height: Int) = (28, 28)
        let context = CGContext(data: nil, width: cnnImageSize.width, height: cnnImageSize.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfoRaw)!
        
        context.interpolationQuality = CGInterpolationQuality.high
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: cnnImageSize.width, height: cnnImageSize.height))
        
        let ratioSize = CGSize(width: image.width, height: image.height)
        let ratioRect = CGRect(origin: CGPoint.zero, size: cropSize)
        let drawRect = AVMakeRect(aspectRatio: ratioSize, insideRect: ratioRect)
        context.draw(image, in: context.convertToUserSpace(drawRect), byTiling: false)
        
        let croppedRect = CGRect(x: 0, y: 0, width: cnnImageSize.width, height: cnnImageSize.height)
        return context.makeImage()?.cropping(to: croppedRect)
    }
}