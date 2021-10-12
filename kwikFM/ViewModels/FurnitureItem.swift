//
//  FurnitureItem.swift
//  kwikFM
//
//  Created by MacOS on 09/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

/**
 
 The FurnitureItem model, holds the data of the Furniture.
 
 */
struct FurnitureItem: Decodable {
    
    var id: Int
    
    var image: String
    
    var category: String?
    
    var comment: String?
    
    var updated: String
    
    var created: String
    
    var manufacturer: String?
    
    var model: String?
    
    var type: String?
    
    var item_nr: String?
    
    var minimum_holding: Int?
    
    var stock: Int
    
    var length: String?
    
    var width: String?
    
    var height: String?
    
    var diameter: String?
    
    var title: String?
    
    var not_assembled: Int
    
    var properties: [FurnitureProperties] = []
}
