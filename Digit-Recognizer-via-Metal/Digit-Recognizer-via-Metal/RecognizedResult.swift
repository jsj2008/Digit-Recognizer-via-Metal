//
//  RecognizingResult.swift
//  Digit-Recognizer-via-Metal
//
//  Created by Andrey Morozov on 26.03.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import UIKit

/// Describe result of CNN.
struct RecognizedResult {
    /// Recognized digit
    let digit: Int
    
    /// Input image for CNN.
    let image: UIImage
}
