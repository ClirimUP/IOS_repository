//
//  ScanningFeatures.swift
//  kwikFM
//
//  Created by MacOS on 14/11/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import AVFoundation
import UIKit

class ScanningFeatures {
    // Supported codes that the application can scan.
    static let supportedCodeTypes : [AVMetadataObject.ObjectType] = [
        .upce, .code39, .code39Mod43, .code93, .code128, .ean8, .ean13
    ]
    
    // Special attribute for the labels to have black borders.
    static let strokeTextAttributes: [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.strokeColor : UIColor.black,
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.strokeWidth : -2.0,
        ]
}

