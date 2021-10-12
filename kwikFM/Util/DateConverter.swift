//
//  DateConvertor.swift
//  kwikFM
//
//  Created by MacOS on 31/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import Foundation

class DateConverter {
    
    /**
     
     Converts the date to a readable String format.
     
     - parameter date: The date that needs to be converted.
     
     */
    static func convertToReadable(date: String) -> String {
    
        let dateString = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        if let dateInDateFormat = dateFormatter.date(from: dateString) {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateInStringFormat = dateFormatter.string(from: dateInDateFormat)
            
            return dateInStringFormat
        }
        else {
            return ""
        }
    }
    
    /**
     
     Converts the date to a readable String format.
     
     - parameter date: The date that needs to be converted.
     - note: Only the date is returned with this method, time is not included.
     
     */
    static func convertToShort(date: String) -> String {
        
        let dateString = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        if let dateInDateFormat = dateFormatter.date(from: dateString) {
            dateFormatter.dateStyle = .long
            let dateInStringFormat = dateFormatter.string(from: dateInDateFormat)
            
            return dateInStringFormat
        }
        else {
            return ""
        }
    }
}
