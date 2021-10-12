//
//  ParseStatus.swift
//  kwikFM
//
//  Created by MacOS on 11/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import Foundation

/**
 
 The possible StatusCodes of the Parsing operation.
 
 */
enum ParseStatus {
    case success
    case empty
    case fail
    case forbidden
}
