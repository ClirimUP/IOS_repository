//
//  AssignedToReservation.swift
//  kwikFM
//
//  Created by MacOS on 06/11/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

/**
 
 The AssignedToReservation structure, holds the reservations assigned to the Furniture.
 
 */
struct AssignedToReservation: Decodable {
    
    var ean: Int
    
    var furnitureName: String
    
    var status: Bool
    
    var reason: String?
}
