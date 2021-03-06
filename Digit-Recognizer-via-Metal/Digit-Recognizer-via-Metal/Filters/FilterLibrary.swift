//
//  FilterLibrary.swift
//  Digit-Recognizer-via-Metal
//
//  Created by Andrey Morozov on 10.03.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import MetalPerformanceShaders


/// Collection of availables filters.
class FilterLibrary {
    
    /// Number of exists filters
    var count: Int {
        return filters.count
    }

    private let filters: [Filter]
    
    init(metalDevice device: MTLDevice) {
        let blur = MPSImageGaussianBlur(device: device, sigma: 1.2)
        let threshold = MPSImageThresholdBinaryInverse(device: device, thresholdValue: 0.5, maximumValue: 1.0, linearGrayColorTransform: nil)
        
        let weights: [Float] = [0.3, 0, 0.3,
                                0,   0, 0,
                                0.3, 0, 0.3]
        let erode = MPSImageErode(device: device, kernelWidth: 3, kernelHeight: 3, values: weights)
        let dilate = MPSImageDilate(device: device, kernelWidth: 3, kernelHeight: 3, values: weights)
        
        filters = [Filter(name: "Blur", kernel: blur),
                   Filter(name: "Threshold", kernel: threshold),
                   Filter(name: "Dilate", kernel: dilate),
                   Filter(name: "Erode", kernel: erode)]
    }
    
    subscript(position: Int) -> Filter {
        return filters[position]
    }
}
