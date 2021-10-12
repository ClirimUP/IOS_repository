//
//  FurnitureProperties.swift
//  kwikFM
//
//  Created by MacOS on 12/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

/**
 
 The FurnitureProperties model, holds the properties of the Furniture.
 
 */
struct FurnitureProperties: Decodable {
    
    var name: String
    
    var type: String
    
    var input: String?
}
