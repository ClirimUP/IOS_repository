//
//  Reservation.swift
//  kwikFM
//
//  Created by MacOS on 27/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

/**
 
 The Reservation model, holds the reservations of the Furniture.
 
 */
struct Reservation: Decodable {
    
    var id: Int
    
    var customer: String
    
    var timelineId: String?
    
    var designation: String
    
    var created: String
    
    var updated: String
    
    var reproach_date: String
    
    var status: String
    
    var comment: String?
}
