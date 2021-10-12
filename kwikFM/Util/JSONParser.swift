//
//  JSONParser.swift
//  kwikFM
//
//  Created by MacOS on 11/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import Foundation

class JSONParser {
    
    /**
     
     Decodes the JSON data to a FurnitureItem struct, or returns nil if an error occurred.
     
     - parameter data: The data that need to be parsed.
     - note: FurnitureItem struct is type of Decodeable
     
     */
    static func parseFurnitureItems(data: Data) -> FurnitureItem? {
        
        do {
            // JSONDecodor used in Swift4 decodes the JSON data to a class/struct
            let furniture: FurnitureItem = try JSONDecoder().decode(FurnitureItem.self, from: data)
            return furniture
            
        } catch {
            // Return nil if an error occurred.
            return nil
        }
    }
    
    /**
     
     Decodes the JSON data to an array of Reservation structs, or returns nil if an error occurred.
     
     - parameter data: The data that need to be parsed.
     - note: Reservation struct is type of Decodeable
     
     */
    static func parseReservations(data: Data) -> [Reservation]? {
        do {
            // JSONDecodor used in Swift4 decodes the JSON data to a class/struct
            let reservation: [Reservation] = try JSONDecoder().decode([Reservation].self, from: data)
            return reservation
            
        } catch {
            // Return nil if an error occurred.
            return nil
        }
    }
    
    /**
     
     Decodes the JSON data to an array of AssignedToReservation structs, or returns nil if an error occurred.
     
     - parameter data: The data that need to be parsed.
     - note: AssignedToReservation struct is type of Decodeable
     
     */
    static func parseReservationsResponse(data: Data) -> [AssignedToReservation]? {        
        do {
            // JSONDecodor used in Swift4 decodes the JSON data to a class/struct
            let assignedToReservationResult = try JSONDecoder().decode([AssignedToReservation].self, from: data)
            return assignedToReservationResult
            
        } catch {
            // Return nil if an error occurred.
            return nil
        }
    }
}
