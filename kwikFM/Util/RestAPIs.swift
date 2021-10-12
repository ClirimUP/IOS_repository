//
//  RestAPIs.swift
//  kwikFM
//
//  Created by MacOS on 20/09/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import Foundation

class RestAPIs {
    
    // All the REST APIs the application uses
    static let loginAPI = "/api/login?version=1.0"
    static let furnitureItemsAPI = "/api/furnitureItems?version=1.0&ean="
    static let reservationsAPI = "/api/reservations?version=1.0&furnitureId="
    static let assignToReservationAPI = "/api/reservations/assign?version=1.0&lang=de"
    static let requestTimeoutInterval: Double = 5
    
    /**
     
     Creates the ReservationRequest with the right Authorization and Content-Type.
     
     - parameter furnitureId: The ID of the Furniture that we're creating the request for.
     
     */
    static func getReservationRequest(withFurnitureId furnitureId: Int) -> URLRequest {
        
        // Get the stored credentials
        let defaults: UserDefaults = UserDefaults.standard
        let serverUrl: String! = defaults.string(forKey: "ServerURL")
        
        let reservationsUrl = URL(string: serverUrl + reservationsAPI + String(furnitureId))!
        // Prepare the furnitureItems request, by default the method type is GET
        var reservationsUrlRequest = URLRequest(url: reservationsUrl)
        reservationsUrlRequest = setRequestAuthorization(for: reservationsUrlRequest)
        
        return reservationsUrlRequest
    }
    
    /**
     
     Creates the FurnitureItemRequest with the right Authorization and Content-Type.
     
     - parameter furnitureEan: The EanCode of the Furniture that we're creating the request for.
     
     */
    static func getFurnitureItemRequest(withFurnitureEan furnitureEan: String) -> URLRequest {
        
        // Get the stored credentials
        let defaults: UserDefaults = UserDefaults.standard
        let serverUrl: String! = defaults.string(forKey: "ServerURL")
        
        // Get the furnitureItems API URL unwrapped
        let furnitureItemsUrl = URL(string: serverUrl + furnitureItemsAPI + furnitureEan)!
        // Prepare the furnitureItems request, by default the method type is GET
        var furnitureItemsUrlRequest = URLRequest(url: furnitureItemsUrl)
        furnitureItemsUrlRequest = setRequestAuthorization(for: furnitureItemsUrlRequest)
        
        return furnitureItemsUrlRequest
    }
    
    /**
     
     Creates the AssignToReservationRequest with the right Authorization and Content-Type.
     
     - parameter reservationId: The Reservation ID that we're creating the request for.
     - parameter furnitureEanCodes: The Furniture EanCodes that we're going to assign to that reservation.
     
     */
    static func getAssignToReservationRequest(withId reservationId: Int, for furnitureEanCodes: [String]) -> URLRequest {
        
        // Get the stored credentials
        let defaults: UserDefaults = UserDefaults.standard
        let serverUrl: String! = defaults.string(forKey: "ServerURL")
    
        let assignToReservationUrl = URL(string: serverUrl + assignToReservationAPI)!
        // Prepare the furnitureItems request, by default the method type is GET
        var assignToReservationUrlRequest = URLRequest(url: assignToReservationUrl)
        assignToReservationUrlRequest.timeoutInterval = RestAPIs.requestTimeoutInterval
        // Set the headers for the given request
        assignToReservationUrlRequest = setRequestAuthorization(for: assignToReservationUrlRequest)
        assignToReservationUrlRequest.httpMethod = "POST"
        
        let assignRequestInJson = ReservationToJson(reservation_id: String(reservationId), furniture_items: furnitureEanCodes)
        do {
            let jsonData = try JSONEncoder().encode(assignRequestInJson)
            assignToReservationUrlRequest.httpBody = jsonData
        }
        catch {
            // Set the body of the UrlRequest as nil
            assignToReservationUrlRequest.httpBody = nil
        }
        
        return assignToReservationUrlRequest
    }
    
    /**
     
     Sets the right authorization and defines the content type of the request.
     
     - parameter request: The request that we're going to edit with the right authorization and content-type.
     
     */
    static func setRequestAuthorization(for request: URLRequest) -> URLRequest {
        
        // Get the stored credentials
        let defaults: UserDefaults = UserDefaults.standard
        let encodedCredentials = defaults.data(forKey: "EncodedCredentials")
        
        var request = request
        
        request.timeoutInterval = requestTimeoutInterval
        // Set the headers for the given request
        request.setValue("Basic \(String(data: encodedCredentials!, encoding: .utf8)!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
