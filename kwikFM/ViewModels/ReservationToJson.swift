//
//  ReservationToJson.swift
//  kwikFM
//
//  Created by MacOS on 01/11/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

/**
 
 The ReservationToJson structure, holds the reservations that are going to be parsed to JSON.
 
 */
struct ReservationToJson: Codable {
    
    var reservation_id: String
    
    var furniture_items: [String]
}
